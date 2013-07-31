//
//  File.h
//  SIPPhone
//
//  Created by admin on 09.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#ifndef REGISTRATION_HANDLER_H_
#define REGISTRATION_HANDLER_H_

@class SIPWrapper;

class RegistrationHandler {
    
public:
    RegistrationHandler(SIPWrapper *owner);// Constructor for class
    
    //Callback when message recieved
    void registrationRecieved (
                          const int &regStatus
                          
                          );
    
private:
    
    SIPWrapper *_owner;
};


#endif /* defined(__SIPPhone__File__) */
