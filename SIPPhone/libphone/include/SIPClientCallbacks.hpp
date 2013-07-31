/* 
 * File:   SIPClientCallbacks.hpp
 * Author: manuna
 *
 * Created on March 16, 2013, 8:11 PM
 */

#ifndef _SIPCLIENTCALLBACKS_HPP
#define	_SIPCLIENTCALLBACKS_HPP

namespace IMLib {
namespace client {
namespace callbacks {

typedef SIPClient::MessageReceivedCallback::slot_type       on_message_received_slot;
typedef SIPClient::OperationStatusCallback::slot_type       on_operation_status_slot;
typedef SIPClient::MessageStatusChangedCallback::slot_type  on_message_status_changed_slot;
typedef SIPClient::ErrorCallback::slot_type                 on_error_slot;

} } } // namespaces

#endif	/* _SIPCLIENTCALLBACKS_HPP */

