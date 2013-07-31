//
//  File.h
//  SIPPhone
//
//  Created by admin on 09.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#ifndef ERROR_HANDLER_H_
#define ERROR_HANDLER_H_

@class SIPWrapper;

class ErrorHandler {
    
public:
    ErrorHandler(SIPWrapper *owner);// Constructor for class
    
    //Callback when message recieved
    void on_error (const int code);
    
private:
    
    SIPWrapper *_owner;
};


#endif /* defined(__ERROR_HANDLER__) */
