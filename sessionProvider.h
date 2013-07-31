//
//  sessionProvider.h
//  SIPPhone
//
//  Created by developer on 6/29/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>
//Protocol for getting a sipID of authorized user

// TODO: protocol name starts from uppercase
@protocol sessionProvider <NSObject>
- (NSString*) authorizedUser;
@end
