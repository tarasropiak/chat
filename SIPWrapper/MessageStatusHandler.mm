//
//  File.cpp
//  SIPPhone
//
//  Created by admin on 09.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//



#include "MessageStatusHandler.h"
#include "SIPWrapper.h"
#include "Logger.hpp"

using namespace IMLib;
using namespace std;

MessageStatusHandler:: MessageStatusHandler(SIPWrapper *owner)
{
    _owner = owner;
}

void MessageStatusHandler:: messageStatusChanged(const string &from_uri,
                                                 const string &from_name,
                                                  const int &SSN
                                                 )

{
    EVENT(" ===================================================== CHANGED ");
    
};