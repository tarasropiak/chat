//
//  SIPWrapperRegistrationDelegat.h
//  SIPPhone
//
//  Created by admin on 03.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SIPWrapperErrorsDelegat <NSObject>
- (void)errorRecieved:(int)registration;
@end
