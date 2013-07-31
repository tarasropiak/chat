/**
 * System includes
 */
#include <cstdlib>
#include <iomanip>
#include <string>
#include <sstream>

#include "Logger.hpp"

namespace IMLib {
namespace logging {

    using namespace std;

    static Logger *s_loggerInstance;

    namespace impl {
        
        static void
        destroyInstance ( )
        {
            if ( s_loggerInstance != NULL ) {
                delete s_loggerInstance;
                s_loggerInstance = NULL;
            }
        }

        static string
        logLevelToString ( const Logger::Level level )
        {
            static const string l2s[] = {
                "VERBOSE",
                "INFO",
                "EVENT",
                "WARNING",
                "FATAL"
            };
            static const size_t l2s_count = sizeof( l2s ) / sizeof( l2s[ 0 ] );
            
            assert( level >= 0 && level < l2s_count &&
                    "log level is not valid" );
            
            return l2s[ level ];
        }

        static string
        formatMessage ( const Logger::Level level, const char *msg ) {
            ostringstream formatted_msg;
            formatted_msg << setw( 7 ) << left <<
                    logLevelToString( level ) << "| " << msg;
            return formatted_msg.str( );
        }
        
    }

    Logger &
    Logger::instance ( )
    {
        if ( s_loggerInstance == NULL ) {
            s_loggerInstance = new Logger( );
            ::atexit( impl::destroyInstance );
        }
        return *s_loggerInstance;
    }

    void
    Logger::print ( const Level level, const char *msg )
    {
        if ( ! _verifyLevel( level ) || msg == NULL ) {
            return;
        }

        string formatted_msg = impl::formatMessage( level, msg );
        on_print( level, msg, formatted_msg.c_str( ) );
    }
    
    void
    Logger::verbose ( const char *msg )
    {
        print( VERBOSE, msg );
    }

    void
    Logger::info ( const char *msg )
    {
        print( INFO, msg );
    }

    void
    Logger::event ( const char *msg )
    {
        print( EVENT, msg );
    }

    void
    Logger::warning ( const char *msg )
    {
        print( WARNING, msg );
    }

    void
    Logger::fatal ( const char *msg )
    {
        print( FATAL, msg );
    }

    Logger::Logger ( )
     : _level_filter( INFO )
    {
        _registerHandlers( );
    }

    bool
    Logger::_verifyLevel ( const Level level ) const
    {
        return level >= _level_filter;
    }

} } // namespaces
