#include "Session.hpp"

namespace IMLib {
    using namespace boost;
    using namespace IMLib;
    using namespace std;

    Session::Session (
            const string &caller_uri,
            const string &password
        )
     : _caller_uri(caller_uri),
       _password(password)
    {
    }

    void Session::start ( )
    {
        _sip_client.start( _caller_uri, _password );
        _sip_client.registerMe( "sip:sip2sip.info" );
    }

    void Session::stop ( )
    {
        _sip_client.stop( );
    }

    void Session::sendMessage (
            const string &to_uri,
            const string &message
        )
    {
        _sip_client.sendMessage( to_uri, message );
    }

}
