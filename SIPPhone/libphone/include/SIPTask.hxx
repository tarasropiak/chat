/* 
 * File:   SIPTask.hxx
 * Author: manuna
 *
 * Created on February 9, 2013, 11:40 PM
 */

#ifndef _SIPTASK_HPP
#define	_SIPTASK_HPP

/**
 * Boost
 */
#include <boost/any.hpp>

/**
 * Local includes
 */
#include "SIPTaskBase.hpp"

namespace IMLib {

    template<class Handler>
    class SIPTask : public SIPTaskBase
    {
    public:

      SIPTask ( const Handler &handler );

      virtual void exec ( );

    private:

        Handler _handler;

    };

    template<class Handler>
    SIPTask<Handler>::SIPTask ( const Handler &handler )
     : _handler( handler )
    {
    }

    template<class Handler> void
    SIPTask<Handler>::exec ( )
    {
        _handler( );
    }

}

#endif	/* _SIPTASK_HPP */

