//
//  File.cpp
//  SIPPhone
//
//  Created by admin on 09.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//



#include "ErrorHandler.h"
#include "SIPWrapper.h"
#include "Logger.hpp"

using namespace IMLib;
using namespace std;

ErrorHandler::ErrorHandler(SIPWrapper *owner)
{
    _owner = owner;
}

void ErrorHandler:: on_error(int code)
                                    
{
    [_owner  errorRecieved:code];
    
};