//
//  SIPMessage.m
//  SIPPhone
//
//  Created by admin on 20.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SIPMessage.h"

@implementation SIPMessage

//cusom init
-(id) initWithCurentTimeAndType:(int) type {
    
    if(self=[super init]){
        
        _type = type;
        NSDate *curentTime = [[NSDate alloc] init];
        _SSN = [curentTime timeIntervalSince1970];
    }
    else
        return nil;
    
    return self;
}
-(void) dealloc{
    
    [super dealloc];
}
@end
