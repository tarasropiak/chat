//
//  File.h
//  SIPPhone
//
//  Created by admin on 09.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#ifndef __SIPPhone__File__
#define __SIPPhone__File__

#include "Logger.hpp"
#import "SIPWrapper.h"
#import "json.h"
#import "JSonConverter.h"

using namespace IMLib;
using namespace std;

@class SIPWrapper;

class MessageHandler {
    
public:
    MessageHandler(SIPWrapper *owner);// Constructor for class
    
   //Callback when message recieved
    void messageReceived (
                          const string &from_uri,
                          const string &from_name,
                          const string &message
                          );
    
private:
    
    SIPWrapper *_owner;
    
};

#endif /* defined(__SIPPhone__File__) */
