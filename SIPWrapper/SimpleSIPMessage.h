//
//  SimpleTextSIPMessage.h
//  SIPPhone
//
//  Created by admin on 20.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SIPMessage.h"

@interface SimpleSIPMessage : SIPMessage
@property (retain, nonatomic) NSString* text;
@property (retain, nonatomic) NSArray* recievers;

-(id) initWithRecievers:(NSArray *) recievers
                andText:(NSString *) text;
@end
