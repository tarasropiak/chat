#ifdef ANDROID_NDK

/**
 * Android includes
 */
#include <android/log.h>

#include "Logger.hpp"

namespace IMLib {
namespace logging {

    namespace impl {

        static void
        androidLogPrint (
                const Logger::Level level,
                const char *msg,
                const char *formatted_msg )
        {
            // Map internal log level to android log level
            static const int l2p[] = {
                ANDROID_LOG_VERBOSE,
                ANDROID_LOG_DEBUG,
                ANDROID_LOG_INFO,
                ANDROID_LOG_WARN,
                ANDROID_LOG_FATAL
            };
            static const size_t l2p_count = sizeof( l2p ) / sizeof( l2p[ 0 ] );

            if ( level >= 0 && level < l2p_count ) {
                ::__android_log_write( l2p[ level ], "STDOUT", msg  );
            } else {
                ::__android_log_write( ANDROID_LOG_DEBUG, "STDOUT", msg );
            }
        }

    }

    void
    Logger::_registerHandlers ( )
    {
        on_print.connect( impl::androidLogPrint );
    }

} } // namespaces

#endif /* ANDROID_NDK */

