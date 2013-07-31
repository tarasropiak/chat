//
//  File.h
//  SIPPhone
//
//  Created by admin on 09.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#ifndef __MessageStatusHandler__File__
#define __MessageStatusHandler__File__

#include "Logger.hpp"
#import "SIPWrapper.h"
#import "json.h"
#import "JSonConverter.h"

using namespace IMLib;
using namespace std;

@class SIPWrapper;

class MessageStatusHandler
{
    
public:
    MessageStatusHandler(SIPWrapper *owner);// Constructor for class
    
    //Callback when message recieved
    void messageStatusChanged (
                          const string &from_uri,
                          const string &message,
                          const int &SSN
                          );
    
private:
    
    SIPWrapper *_owner;
    
};

#endif /* defined(__SIPPhone__File__) */
