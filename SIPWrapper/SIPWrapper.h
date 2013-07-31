//
//  SIPWrapper.h
//  SIPPhone
//
//  Created by GGC on 6/7/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
// class-layer whitch wrapped SIP cliend and give it's methods to other

#import <Foundation/Foundation.h>
#include <sofia-sip/su_debug.h>
#include "Logger.hpp"
#include "SIPClient.hpp"
#include "SIPClientCallbacks.hpp"
#include "MessageHandler.h"
#include "ErrorHandler.h"
#include "MessageWrapper.h"
#include "SIPWrapperRegistrationDelegat.h"
#include "SimpleSIPMessage.h"
#include "SystemSIPMessage.h"

using namespace boost;
using namespace IMLib;
using namespace IMLib::client::callbacks;
using namespace std;

// Protocol which operating receiving messages
@protocol SIPWrapperDelegate
@required
- (void) messageReceived:(id) message;
@optional
- (void) statusReplayRecieved:(SystemSIPMessage *) message;
@end


@interface SIPWrapper : NSObject

@property (nonatomic, assign) id <SIPWrapperDelegate> delegate;
@property (nonatomic, assign) id <SIPWrapperErrorsDelegat> errorDelegat;
@property (nonatomic, assign) NSString * networkStatus;
@property (nonatomic, assign) NSString * soulStatus;

- (void) startSIPWithLogin:(NSString* ) loginField
               andWithPass:(NSString* ) passField;
- (void) registerWithDomen:(NSString*) domenField;
- (void) sendMessage:(id) message;
- (void) waitClient;
- (void) stopClient;
- (void) unregister;
- (void) messageReceived:(id)message;
- (void) errorRecieved:(int)code;
- (void) enableErrorReceiver;
- (void) disableErrorReceiver;
- (void) enableMessageReceiver;
- (void) disableMessageReceiver;
- (void) statusReplayRecieved:(SystemSIPMessage*)message;

- (id) fromJSON :(std::string& ) messageInJSon andRealURL:(NSString *) url;
@end
