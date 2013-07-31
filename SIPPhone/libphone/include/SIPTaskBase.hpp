/* 
 * File:   SIPTaskBase.hpp
 * Author: manuna
 *
 * Created on February 26, 2013, 12:13 AM
 */

#ifndef _SIPTASKBASE_HPP
#define	_SIPTASKBASE_HPP

namespace IMLib {

    struct SIPTaskBase
    {
        virtual ~SIPTaskBase ( );
        virtual void exec ( ) = 0;
    };

}

#endif	/* _SIPTASKBASE_HPP */

