/* 
 * File:   Logger.hpp
 * Author: manuna
 *
 * Created on February 9, 2013, 10:59 PM
 */

#ifndef _LOGGER_HPP
#define	_LOGGER_HPP

/**
 * STL includes
 */

#include <sstream>
/**
 * Boost includes
 */
#include <boost/noncopyable.hpp>
#include <boost/signals2.hpp>

#if (DEBUG == 1)
#define __LOG_MAKE_MSG(s,x) \
    do { \
        std::ostringstream _msg; \
        _msg << x; \
        s = _msg.str( ); \
    } while ( false );

#define LOG_PRINT(l,x) \
    do { \
        std::string msg; \
        __LOG_MAKE_MSG( msg, x ); \
        IMLib::logging::Logger::instance( ).print( l, msg.c_str( ) ); \
    } while ( false );

#define VERBOSE(x) LOG_PRINT( IMLib::logging::Logger::VERBOSE, x )
#define INFO(x)    LOG_PRINT( IMLib::logging::Logger::INFO, x )
#define EVENT(x)   LOG_PRINT( IMLib::logging::Logger::EVENT, x )
#define WARN(x)    LOG_PRINT( IMLib::logging::Logger::WARNING, x )
#define FATAL(x)   LOG_PRINT( IMLib::logging::Logger::FATAL, x )
#else
#define VERBOSE(x)
#define INFO(x)
#define EVENT(x)
#define WARN(x)
#define FATAL(x)
#endif

// TODO(amykhayl): make this work via VERBOSE
#define TRACE_ENTER() \
    do { \
        INFO( __FUNCTION__ << ": entering" ); \
    } while ( false );


namespace IMLib {
namespace logging {

    class Logger : public boost::noncopyable
    {
    public:

        enum Level
        {
            VERBOSE,
            INFO,
            EVENT,
            WARNING,
            FATAL,
            LEVEL_MAX
        };

        typedef boost::signals2::signal<void (
                const Level level,
                const char *msg,
                const char *formatted_msg )>         LogPrintCallback;

        LogPrintCallback on_print;

        static Logger & instance ( );

        Level getLevelFilter ( ) const;

        void setLevelFilter ( const Level level );

        void print ( const Level level, const char *msg );
        
        void verbose ( const char *msg );

        void info ( const char *msg );

        void event ( const char *msg );

        void warning ( const char *msg );

        void fatal ( const char *msg );

    private:

        Level _level_filter;

        Logger ( );

        bool _verifyLevel ( const Level level ) const;

        void _registerHandlers ( );

    };

} } // namespaces

#endif	/* _LOGGER_HPP */

