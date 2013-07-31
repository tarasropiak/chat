#ifndef _SESSION_HPP
#define	_SESSION_HPP

/**
 * STL includes
 */
#include <string>

/**
 * Local includes
 */
#include "SIPClient.hpp"

namespace IMLib {

    class Session {
    public:
        
        Session (
                const std::string &caller_uri,
                const std::string &password
            );
        
        void start ( );
        
        void stop ( );
        
        void sendMessage (
                const std::string &to_uri,
                const std::string &message
            );
        
    private:
        
        SIPClient _sip_client;
        std::string _caller_uri;
        std::string _password;
    };
}

#endif	/* _SESSION_HPP */

