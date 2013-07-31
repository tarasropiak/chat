/**
 * Sofia-SIP includes
 */
#include <sofia-sip/su_debug.h>

/**
 * System includes includes
 */
#include <cstdio>
#include <cstdarg>
#include <string>

/**
 * Local includes
 */
#include "Logger.hpp"
#include "SIPLogging.hpp"

SOFIAPUBVAR su_log_t nua_log[];
SOFIAPUBVAR su_log_t nea_log[];
SOFIAPUBVAR su_log_t nta_log[];
SOFIAPUBVAR su_log_t tport_log[];
SOFIAPUBVAR su_log_t su_log_default[];
SOFIAPUBVAR su_log_t sresolv_log[];

namespace IMLib {
namespace logging {

    using namespace std;

    namespace impl {

        static void
        sofiaLogCallback ( void *logarg, char const *format, va_list ap )
        {
            string buff( 512, '\0' );

            // Get log message
            // If log message if too long to be copied into buff - increase
            // buffer size
            do {
                int length = ::vsnprintf(
                    &buff[ 0 ], buff.size( ), format, ap
                );
                if ( length < buff.size( ) ) {
                    buff.resize( length );
                    break;
                }
                buff.resize( buff.size( ) * 2, '\0' );
            } while ( true );

            EVENT( " * sofia-sip: " << buff );
        }

    }

    void
    SIPLogging::enable ( int level )
    {
        ::su_log_soft_set_level( nua_log, level );
		::su_log_soft_set_level( su_log_default, level );
		::su_log_soft_set_level( nea_log, level );
		::su_log_soft_set_level( nta_log, level );
		::su_log_soft_set_level( tport_log, level );
		::su_log_soft_set_level( sresolv_log, level );

        su_logger_f *p_log_callback = impl::sofiaLogCallback;
		::su_log_redirect( nua_log, p_log_callback, NULL);
		::su_log_redirect( su_log_default, p_log_callback, NULL);
		::su_log_redirect( nea_log, p_log_callback, NULL);
		::su_log_redirect( nta_log, p_log_callback, NULL);
		::su_log_redirect( tport_log, p_log_callback, NULL);
		::su_log_redirect( sresolv_log, p_log_callback, NULL);
    }

} } // namespaces
