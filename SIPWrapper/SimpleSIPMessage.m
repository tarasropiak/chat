//
//  SimpleTextSIPMessage.m
//  SIPPhone
//
//  Created by admin on 20.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SimpleSIPMessage.h"

@implementation SimpleSIPMessage

-(id) initWithRecievers:(NSArray *) recievers andText:(NSString *) text{
 
    if(self=[super initWithCurentTimeAndType:SIMPLE_MESSAGE]){
        
        _text=text;
        _recievers = recievers;
    }
    else
        return nil;

    return self;
}
    
-(void) dealloc{
    
    [_recievers release];
    [_text release];
    [super dealloc];
}
@end
