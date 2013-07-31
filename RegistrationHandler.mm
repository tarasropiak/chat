//
//  File.cpp
//  SIPPhone
//
//  Created by admin on 09.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//



#import "RegistrationHandler.h"
#import "SIPWrapper.h"
#include "Logger.hpp"

using namespace IMLib;
using namespace std;

RegistrationHandler::RegistrationHandler(SIPWrapper *owner)
{
    _owner = owner;
}

void RegistrationHandler:: registrationRecieved(const int &regStatus)
                                    
{
    if(regStatus)
        EVENT(regStatus)
       
            [_owner registrationProcessed:regStatus];
            
    
};