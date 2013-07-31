//
//  Messagge.m
//  SIPPhone
//
//  Created by admin on 11.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "MessageWrapper.h"

@implementation MessageWrapper


-(void) dealloc
{
    [_messageField release];
    [_nameField release];
    [_urlField release];
    
    [super dealloc];

}
@end
