//
//  SipClientDelegate.h
//  SIPPhone
//
//  Created by developer on 6/28/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MessageWrapper;
@class SIPWrapper;
@protocol SipClientDelegate <NSObject>
-(void) sendMessage:(id)message;
-(SIPWrapper*) returnMyWrap;
@end
