#ifndef ANDROID_NDK

/**
 * System includes
 */
#include <iostream>

/**
 * Local includes
 */
#include "Logger.hpp"

namespace IMLib {
namespace logging {

    using namespace std;

    namespace impl {
        
        static void
        logConsolePrint (
                const Logger::Level level,
                const char *msg,
                const char *formatted_msg )
        {
            (void)level;
            (void)msg;

            cout << formatted_msg << endl;
        }
        
    }

    void
    Logger::_registerHandlers ( )
    {
        on_print.connect( impl::logConsolePrint );
    }

} } // namespaces

#endif /* ANDROID_NDK */
