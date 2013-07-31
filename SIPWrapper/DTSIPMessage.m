//
//  DTSIPMessage.m
//  SIPPhone
//
//  Created by admin on 20.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "DTSIPMessage.h"

@implementation DTSIPMessage

-(void) dealloc
{
    [_bytes release];
    [_format release];
    
    [super dealloc];
}
@end
