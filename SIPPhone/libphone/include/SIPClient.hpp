/* 
 * File:   SIPClient.hpp
 * Author: manuna
 *
 * Created on February 9, 2013, 10:31 PM
 */

#ifndef _SIPCLIENT_HPP
#define	_SIPCLIENT_HPP

/**
 * Boost
 */
#include <boost/function.hpp>
#include <boost/signals2.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>
#include <boost/thread/barrier.hpp>

/**
 * SIP
 */
#include <sofia-sip/nua.h>

/**
 * SIP
 */
#include <list>
#include <map>
#include <set>
#include <string>

/**
 * Local includes
 */
#include "SIPTask.hxx"

namespace IMLib {

    class SIPClient
    {
    public:

    	enum Operation
    	{
    		REGISTER,
    		UNREGISTER,
    		MESSAGE
    	};

        typedef boost::signals2::signal<void (
                const std::string &from_uri,
                const std::string &from_name,
                const std::string &message )>         MessageReceivedCallback;
        
        typedef boost::signals2::signal<void (
				const Operation operation,
				int status,
				const std::string &phrase )>          OperationStatusCallback;

        
        typedef boost::signals2::signal<void (
                                              const std::string &from_uri,
                                              const std::string &from_name,
                                              const int &SSN )>         MessageStatusChangedCallback;
        
        
        typedef boost::signals2::signal<void (
        		int code
                                              )>         ErrorCallback;
       

        MessageReceivedCallback on_message_received;
        OperationStatusCallback on_operation_status;
        MessageStatusChangedCallback on_message_status_changed;
        ErrorCallback on_error;

        SIPClient ( );
        ~SIPClient ( );

        bool started ( ) const;
        void start (
                const std::string &caller_uri,
                const std::string &password = ""
            );
        void stop ( );
        void wait ( );

        // Register client in network

        void registerMe ( const std::string &registrar_uri );
        void unregister ( );

        //

        //  Messaging

        void sendMessage (
                const std::string &to_uri,
                const std::string &msg_text
            );

        //

        // Calls
        
        void startCall ( const std::string &to_uri );
        void stopCall ( );

        //

    protected:

        template<class Handler>
        void post ( const Handler &handler );

    private:

        struct Context
        {
            su_home_t     su_home[1];	/**< Our memory home */
            su_root_t    *su_root;
            nua_t        *nua;
            SIPClient    *engine;

            Context ( );
        };

        struct EventArgs
        {
            nua_event_t   event;
            int           status;
            char const   *phrase;
            nua_t        *nua;
            nua_magic_t  *magic;
            nua_handle_t *nh;
            nua_hmagic_t *hmagic;
            sip_t const  *sip;
            tagi_t       *tags;
        };

        typedef boost::function<
                void (
                    const EventArgs &args
                )
            > EventHandlerFn;

        typedef std::map<nua_event_t, EventHandlerFn>         EventMap;
        typedef std::set<intptr_t>                            HandleSet;

        boost::shared_ptr<boost::thread> _thread;
        boost::shared_ptr<boost::barrier> _init_barrier;
        Context _context;
        std::string _caller_uri;
        std::string _password;
        HandleSet _authenticating_handles;

        EventMap _event_map;

        // TODO, amykhayl: Implement method stack as it is in sofsip example
        nua_handle_t *_nh_register;

        void _initEventMap ( );

        void _post ( const SIPTaskBase *p_sip_task );

        void _main ( );

        static void _onMessage (
                su_root_magic_t *magic,
                su_msg_r msg,
                su_msg_arg_t *msg_arg
            );

        static void _onEvent (
                nua_event_t   event,
                int           status,
                char const   *phrase,
                nua_t        *nua,
                nua_magic_t  *magic,
                nua_handle_t *nh,
                nua_hmagic_t *hmagic,
                sip_t const  *sip,
                tagi_t        tags[]
            );

        void _processEvent ( const EventArgs &args );

        // Event handlers

        // Calls
        
        void _doStartCall ( const std::string &to_uri );

        void _nua_r_invite ( const EventArgs &args );

        void _nua_i_invite ( const EventArgs &args );

        void _doStopCall ( );

        void _nua_r_bye ( const EventArgs &args );

        void _nua_i_bye ( const EventArgs &args );

        //

        // Message handlers

        void _doSendMessage (
                const std::string to_uri,
                const std::string msg_body
            );

        void _nua_r_message ( const EventArgs &args );

        void _nua_i_message ( const EventArgs &args );
        
        //

        // Registration

        void _doRegister ( const std::string &registrar_uri );

        void _nua_r_register ( const EventArgs &args );

        void _doUnregister ( const std::string &registrar_uri );

        void _nua_r_unregister ( const EventArgs &args );
        
        

        //

        // Shutdown

        void _doShutdown ( );

        void _nua_r_shutdown ( const EventArgs &args );

        //

        // Authentication

        void _authenticate_op (
                nua_handle_t *nh,
                sip_t const *sip,
                tagi_t tags[]
            );

    bool _isAuthenticating ( nua_handle_t *nh );

		void _startAuthentication (
				nua_handle_t *nh,
				sip_t const *sip,
				tagi_t tags[]
			);

		void _endAuthentication ( nua_handle_t *nh );

        //

    };

    template<class Handler> void
    SIPClient::post ( const Handler &handler )
    {
        const SIPTask<Handler> *p_sip_task = NULL;
        try {
            // NOTE, amykhayl: SIPMessage will be deleted in _onMessage after
            // processing it
            p_sip_task = new SIPTask<Handler>( handler );
            _post( p_sip_task );
        } catch ( ... ) {
            if ( p_sip_task != NULL ) {
                delete p_sip_task;
            }
            throw;
        }
    }

}

#endif	/* _SIPCLIENT_HPP */

