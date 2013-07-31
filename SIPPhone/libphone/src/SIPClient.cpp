/* 
 * File:   SIPClient.cpp
 * Author: manuna
 * 
 * Created on February 9, 2013, 10:31 PM
 */

/**
 * Boost
 */
#include <boost/bind.hpp>

/**
 * clib
 */
#include <cassert>

/**
 * STL
 */
#include <list>
#include <sstream>
#include <stdexcept>

/**
 * SIP
 */
#include <sofia-sip/soa.h>
#include <sofia-sip/su.h>
#include <sofia-sip/su_localinfo.h>
#include <sofia-sip/sip.h>
#include <sofia-sip/sip_tag.h>
#include <sofia-sip/sip_protos.h>
#include <sofia-sip/sip_status.h>
#include <sofia-sip/tport_tag.h>

/**
 * Local
 */
#include "Logger.hpp"
#include "SIPClient.hpp"
#include "SIPTask.hxx"

#if ENABLE_SOFIA_SIP_LOGGING == 1
#include "SIPLogging.hpp"
#endif /* ENABLE_SOFIA_SIP_LOGGING */

#define STREAM_URL_PRINT_ARGS(u) \
  ((u)->url_scheme ? (u)->url_scheme : "") <<	\
  ((u)->url_type != url_any && (u)->url_scheme && (u)->url_scheme[0] \
    ? ":" : "") << \
  ((u)->url_root && ((u)->url_host || (u)->url_user) ? "//" : "") << \
  ((u)->url_user ? (u)->url_user : "") << \
  ((u)->url_user && (u)->url_password ? ":" : "") << \
  ((u)->url_user && (u)->url_password ? (u)->url_password : "") << \
  ((u)->url_user && (u)->url_host ? "@" : "") << \
  ((u)->url_host ? (u)->url_host : "") << \
  ((u)->url_host && (u)->url_port ? ":" : "") << \
  ((u)->url_host && (u)->url_port ? (u)->url_port : "") << \
  ((u)->url_root && (u)->url_path ? "/" : "") << \
  ((u)->url_path ? (u)->url_path : "") << \
  ((u)->url_params ? ";" : "") << ((u)->url_params ? (u)->url_params : "") << \
  ((u)->url_headers ? "?" : "") << ((u)->url_headers ? (u)->url_headers : "") << \
  ((u)->url_fragment ? "#" : "") << ((u)->url_fragment ? (u)->url_fragment : "")

namespace IMLib {

    using namespace boost;
    using namespace logging;
    using namespace std;

    namespace impl {

    		static string chooseNetInterface ( )
    	    {
    			su_localinfo_t* p_info;
    	    	su_localinfo_t  hints = { 0 };
    	    	hints.li_flags  = LI_NUMERIC | LI_CANONNAME;
    	    #ifdef IOS_BUILD
    	    	hints.li_flags |= LI_IFNAME;
    	    #endif
    	    	hints.li_family = AF_INET;
    	    	hints.li_scope  = LI_SCOPE_LINK | LI_SCOPE_SITE | LI_SCOPE_GLOBAL;
    	    	su_getlocalinfo( &hints, &p_info );
    	    	su_localinfo_t *p_curr_info = p_info;

    	    	list<string> addrs;
    	    	while ( NULL != p_curr_info )
    	    	{
    	    		string addr = p_curr_info->li_canonname ? p_curr_info->li_canonname : "";
    	    		string ifname = p_curr_info->li_ifname ? p_curr_info->li_ifname : "";
    	    		if ( addr != "127.0.0.1" ) {
    	    			if ( ifname.find( "en" ) == string::npos ) { // This is mobile network
    	    				addrs.push_front( addr );
    	    			} else { // This is Wi-FI network - make it first in list
    	    				addrs.push_back( addr );
    	    			}
    	    			INFO(
    	    				"Discovered net interface: " << ifname <<
    	    				" - " << addr
    	    			);
    	    		}

    	    		p_curr_info = p_curr_info->li_next;
    	    	}

    	    	su_freelocalinfo( p_info );
    	    	return addrs.front( );
    	    }

    	}

    //
    // Context
    //

    SIPClient::Context::Context ( )
     : su_root( NULL ),
       nua( NULL ),
       engine( NULL )
    {
    }

    //
    // SIPClient
    //

    SIPClient::SIPClient ( )
     : _nh_register( NULL )
    {
        _context.engine = this;
        _initEventMap();
    }

    SIPClient::~SIPClient ( )
    {
        _context.engine = NULL;
    }
    
    bool
    SIPClient::started ( ) const
    {
        return true;
    }
    
    void
    SIPClient::start (
            const std::string &caller_uri,
            const std::string &password
        )
    {
        if ( _thread ) {
            throw runtime_error( "SIP thread already started" );
        }

        EVENT( "Starting SIP engine" );
        _caller_uri = caller_uri;
        _password = password;
        _init_barrier.reset( new boost::barrier( 2 ) );

        _thread.reset( new thread( bind( &SIPClient::_main, this ) ) );
        _init_barrier->wait();
    }

    void
    SIPClient::stop ( )
    {
        if ( ! _thread ) {
            throw runtime_error( "SIP thread is not running" );
        }

        EVENT( "Stopping SIP engine" );
        post( bind( &SIPClient::_doShutdown, this ) );
    }

    void
    SIPClient::wait ( )
    {
        if ( ! _thread ) {
            throw runtime_error( "SIP thread is not running" );
        }
        _thread->join( );
        _thread.reset( );
    }

    void
    SIPClient::registerMe ( const std::string &registrar_uri )
    {
        post( bind( &SIPClient::_doRegister, this, registrar_uri ) );
    }

    void
    SIPClient::unregister ( )
    {
        post( bind( &SIPClient::_doUnregister, this, "" ) );
    }

    void
    SIPClient::sendMessage ( const string &to_uri, const string &msg_text)
    {
        post( bind( &SIPClient::_doSendMessage, this, to_uri, msg_text ) );

    }

    void
    SIPClient::startCall ( const string &to_uri )
    {
        post( bind( &SIPClient::_doStartCall, this, to_uri ) );
    }

    void
    SIPClient::stopCall ( )
    {
        post( bind( &SIPClient::_doStopCall, this ) );
    }
    
    void
    SIPClient::_initEventMap ( )
    {
        _event_map[ nua_r_invite ] = bind( &SIPClient::_nua_r_invite, this, _1 );
        _event_map[ nua_i_invite ] = bind( &SIPClient::_nua_i_invite, this, _1 );
        _event_map[ nua_r_bye ] = bind( &SIPClient::_nua_r_bye, this, _1 );
        _event_map[ nua_i_bye ] = bind( &SIPClient::_nua_i_bye, this, _1 );
        _event_map[ nua_r_message ] = bind( &SIPClient::_nua_r_message, this, _1 );
        _event_map[ nua_i_message ] = bind( &SIPClient::_nua_i_message, this, _1 );
        _event_map[ nua_r_register ] = bind( &SIPClient::_nua_r_register, this, _1 );
        _event_map[ nua_r_unregister ] = bind( &SIPClient::_nua_r_unregister, this, _1 );
        _event_map[ nua_r_shutdown ] = bind( &SIPClient::_nua_r_shutdown, this, _1 );
    }

    void
    SIPClient::_post ( const SIPTaskBase *p_sip_task )
    {
        try {
            int ret;
            su_msg_r msg = SU_MSG_R_INIT;

            ret = ::su_msg_new( msg, sizeof( p_sip_task ) );
            if ( ret != 0 ) {
                throw runtime_error( "su_msg_new failed" );
            }

            ::memcpy( ::su_msg_data( msg ), &p_sip_task, sizeof( p_sip_task ) );

            ret = ::su_msg_send_to(
                msg,
                ::su_root_task( _context.su_root ),
                _onMessage
            );
            if ( ret != 0 ) {
                ::su_msg_destroy( msg );
                throw runtime_error( "su_msg_send_to failed" );
            }
        } catch ( const std::exception &e ) {
            FATAL( "notify caught exception: " << e.what( ) );
            throw;
        }
    }

    void
    SIPClient::_main ( )
    {
        bool su_init_succeeded = false;
        try {
            int ret;
            
            ret = ::su_init();
            if ( ret != 0 ) {

                throw runtime_error( "su_init failed" );
            }
            su_init_succeeded = true;
       
#if ENABLE_SOFIA_SIP_LOGGING == 1
            SIPLogging::enable( );
#endif

            ret = ::su_home_init( _context.su_home );
            if ( ret != 0 ) {
 
                throw runtime_error( "su_home_init failed" );
            }

            _context.su_root = ::su_root_create( &_context );
            if ( _context.su_root == NULL ) {

                throw runtime_error( "su_root_create failed" );
                
            }

            const string if_addr = impl::chooseNetInterface( );
            ostringstream nua_url;
            nua_url << "sip:" << if_addr << ":0;transport=tcp";

            // Create NUA stack
            EVENT( "Starting NUA with caller id: " << _caller_uri );

            _context.nua = ::nua_create(
                _context.su_root,
                _onEvent,
                &_context,
                NUTAG_URL( nua_url.str( ).c_str( ) ),
                SIPTAG_FROM_STR( _caller_uri.c_str( ) ),
                TAG_NULL()
            );
            
            if ( _context.nua == NULL ) {
                throw runtime_error( "nua_create failed" );
            }

            ::nua_set_params(
                _context.nua,
                NUTAG_ENABLEMESSAGE( 1 ),
                NUTAG_ENABLEINVITE( 1 ),
                NUTAG_AUTOALERT( 1 ),
                NUTAG_SESSION_TIMER( 0 ),
                NUTAG_AUTOANSWER( 0 ),
                TAG_NULL( )
            );
            
//            ::nua_get_params( _context.nua, TAG_ANY( ), TAG_NULL( ) );
            
            INFO( "SIP engine finished initialization" );
            _init_barrier->wait();

            INFO( "Starting SIP engine event processing" );
            ::su_root_run( _context.su_root );
            INFO( "Finished SIP engine event processing" );

            // Destroy NUA stack
            ::nua_destroy( _context.nua );
            
                

            // Destroy event loop
            ::su_root_destroy( _context.su_root );
            INFO( "SIP engine event processing stopped" );
            
        } catch ( const std::exception &e ) {
            
            _init_barrier->wait();
         on_error(1000);
            FATAL( "_main caught exception: " << e.what( ) );
        
           

          
            
        }
       
        
        
        
        if ( su_init_succeeded ) {
            ::su_deinit( );
        }
    }

    void
    SIPClient::_onMessage (
            su_root_magic_t *magic,
            su_msg_r msg,
            su_msg_arg_t *msg_arg
        )
    {
        SIPTaskBase *p_sip_task = *reinterpret_cast<SIPTaskBase **>( msg_arg );
        if ( p_sip_task != NULL ) {
            p_sip_task->exec( );
            delete p_sip_task;
        }
    }

    void
    SIPClient::_onEvent (
            nua_event_t   event,
            int           status,
            char const   *phrase,
            nua_t        *nua,
            nua_magic_t  *magic,
            nua_handle_t *nh,
            nua_hmagic_t *hmagic,
            sip_t const  *sip,
            tagi_t        tags[]
        )
    {
        Context *context = reinterpret_cast<Context *>( magic );
        SIPClient *engine = context->engine;
        
        EventArgs args = {
            event,
            status,
            phrase,
            nua,
            magic,
            nh,
            hmagic,
            sip,
            tags
        };
        engine->_processEvent( args );
    }

    void
    SIPClient::_processEvent ( const EventArgs &args )
    {
        nua_event_t event = args.event;
        const char *event_name = ::nua_event_name( event );
        INFO( event_name << ": " << args.phrase << " " << args.status );

        EventMap::iterator it = _event_map.find( event );
        if ( it == _event_map.end( ) ) {
            INFO( "Skipping unknown nua event: " << event_name );
        } else {
            // Call event handler
            it->second( args );

            // Error handling
            bool endAuthentication = true;
            if ( args.status == 401 || args.status == 407 )
            { // Receive 'Access Denied' or 'Authentication Required'
            	if ( ! _isAuthenticating( args.nh ) ) {
            		_startAuthentication( args.nh, args.sip, args.tags );
            		endAuthentication = false;
            	}
            } else if ( args.status >= 300 ) { // Error occured
                if ( args.nh != NULL ) {
                    ::nua_handle_destroy( args.nh );
                }
            }

            if ( endAuthentication ) {
            	_endAuthentication( args.nh );
            }
        }
    }

    void
    SIPClient::_doStartCall ( const string &to_uri )
    {
        EVENT( "Starting call to: " << to_uri );

        sip_to_t *p_to_addr = ::sip_to_make(
            _context.su_home,
            to_uri.c_str( )
        );
        nua_handle_t *nua_handle = ::nua_handle(
            _context.nua,
            this,
            SIPTAG_TO( p_to_addr ),
			TAG_END()
        );
        if ( nua_handle == NULL ) {
            throw runtime_error( "nua_handle returned NULL" );
        }

        ::nua_invite( nua_handle, TAG_END() );
    }

    void
    SIPClient::_nua_r_invite ( const EventArgs &args )
    {
        ::nua_ack(
            args.nh,
            TAG_END()
        );
    }

    void
    SIPClient::_nua_i_invite ( const EventArgs &args )
    {
        ::nua_respond(
            args.nh,
            200,
            "OK",
            TAG_END()
        );
    }

    void
    SIPClient::_doStopCall ( )
    {
    }

    void
    SIPClient::_nua_r_bye ( const EventArgs &args )
    {
    }

    void
    SIPClient::_nua_i_bye ( const EventArgs &args )
    {
    }

    void
    SIPClient::_doSendMessage ( const string to_uri, const string msg_body )
    {

        
        EVENT( "Sending message to: " << to_uri );
        
        nua_handle_t *nua_handle = ::nua_handle(
            _context.nua,
            this,
            SIPTAG_TO_STR( to_uri.c_str( ) ),
			TAG_END()
        );
        if ( nua_handle == NULL ) {
            throw runtime_error( "nua_handle returned NULL" );
        }

        ::nua_message(
            nua_handle,
            SIPTAG_CONTENT_TYPE_STR( "text/plain" ),
            SIPTAG_PAYLOAD_STR( msg_body.c_str( ) ),
            TAG_END( )
        );
       
        
    }

    void
    SIPClient::_nua_r_message ( const EventArgs &args )
    {
   
        string a = "2323";
        string b = "2323";
        on_message_status_changed(a,b,1);
    
    }

    void
    SIPClient::_nua_i_message ( const EventArgs &args )
    {
        sip_from_t *from = args.sip->sip_from;

        stringstream from_uri;
        from_uri << STREAM_URL_PRINT_ARGS( from->a_url );
        const string &from_name = from->a_display ? string( from->a_display ) : "";
        const string &message = string(
            args.sip->sip_payload->pl_data,
            static_cast<size_t>( args.sip->sip_payload->pl_len )
        );

        on_message_received( from_uri.str( ), from_name, message );
    }

    void
    SIPClient::_doRegister ( const string &registrar_uri )
    {
        if ( registrar_uri.empty( ) && _nh_register != NULL ) {
            EVENT( "REGISTER: updating registration" );
            ::nua_register( _nh_register, TAG_NULL( ) );
        } else {
            EVENT( "REGISTER: registering client at: " << registrar_uri );

            nua_handle_t *nua_handle = ::nua_handle(
                _context.nua,
                this,
                NUTAG_URL( _caller_uri.c_str( ) ),
                TAG_END()
            );
            if ( nua_handle == NULL ) {
                throw runtime_error( "nua_handle returned NULL" );
            }

            ::nua_register(
                nua_handle,
                NUTAG_REGISTRAR( registrar_uri.c_str( ) ),
                NUTAG_M_FEATURES("expires=180"),
                NUTAG_M_DISPLAY( "" ),
                SIPTAG_EXPIRES_STR("600"),
                TAG_NULL()
            );
        }
    }

    void
    SIPClient::_nua_r_register ( const EventArgs &args )
    {
        on_error(args.status);
        if ( args.status != 200 ) { // Operation is not succeeded yet
            
            return;
        }
        _nh_register = args.nh;
       
    }

    void
    SIPClient::_doUnregister ( const string &registrar_uri )
    {
        if ( registrar_uri.empty( ) && _nh_register != NULL ) {
            EVENT( "UNREGISTER: unregistering client" );
            on_error(999);
            ::nua_unregister( _nh_register, TAG_NULL( ) );
        } else {
            // TODO, amykhayL: implement this
            WARN( "UNREGISTER: unregistering from custom registrar is not implemented yet" );
        }
    }

    void
    SIPClient::_nua_r_unregister ( const EventArgs &args )
    {
       
        if ( args.status != 200 ) { // Operation is not succeeded yet
            return;
        }
        
        if ( args.nh == _nh_register ) {
            _nh_register = NULL;
            
        }
    }

    void
    SIPClient::_doShutdown ( )
    {
       
        ::nua_shutdown( _context.nua );
    }

    void
    SIPClient::_nua_r_shutdown ( const EventArgs &args )
    {
        // Operation is in progress
        if ( args.status < 200 ) {
            return;
        }
       
        ::su_root_break( _context.su_root );
         
    }

    bool
    SIPClient::_isAuthenticating (
    		nua_handle_t *nh
    	)
    {
    	return _authenticating_handles.count(
    			reinterpret_cast<intptr_t>( nh ) ) > 0;
    }

    void
    SIPClient::_startAuthentication (
    		nua_handle_t *nh,
			sip_t const *sip,
			tagi_t tags[]
    	)
    {
    	_authenticate_op( nh, sip, tags );
    	_authenticating_handles.insert( reinterpret_cast<intptr_t> ( nh ) );
    }

    void
    SIPClient::_endAuthentication (
    		nua_handle_t *nh
    	)
    {
    	_authenticating_handles.erase( reinterpret_cast<intptr_t>( nh ) );
    }

    void
    SIPClient::_authenticate_op (
    		nua_handle_t *nh,
    		sip_t const *sip,
    		tagi_t tags[]
    	)
    {
        sip_from_t const *sipfrom = sip->sip_from;
        sip_www_authenticate_t const *wa = sip->sip_www_authenticate;
        sip_proxy_authenticate_t const *pa = sip->sip_proxy_authenticate;

        tl_gets(
            tags,
            SIPTAG_WWW_AUTHENTICATE_REF(wa),
            SIPTAG_PROXY_AUTHENTICATE_REF(pa),
            TAG_NULL()
        );

        msg_auth_s const *auth_list[] = { wa, pa };
        size_t auth_list_count = sizeof( auth_list ) / sizeof( auth_list[ 0 ] );
        for ( size_t i = 0; i < auth_list_count; i++ ) {
            msg_auth_s const *p_auth = auth_list[ i ];
            if ( p_auth == NULL ) {
                continue;
            }

            const char *realm = msg_params_find( p_auth->au_params, "realm=" );
            const char *username = sipfrom->a_url->url_user;

            ostringstream auth_builder;
            auth_builder << p_auth->au_scheme << ":" << realm <<
                    ":" << username << ":" << _password;
            string auth_string = auth_builder.str( );
            INFO( "Authenticating with " << auth_string );

            ::nua_handle_ref( nh );
            ::nua_authenticate(
                nh,
                NUTAG_AUTH( auth_string.c_str( ) ),
                TAG_END( )
            );
            ::nua_handle_unref( nh );
        }
    }

}
