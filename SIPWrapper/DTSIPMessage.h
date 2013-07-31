//
//  DTSIPMessage.h
//  SIPPhone
//
//  Created by admin on 20.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SIPMessage.h"

@interface DTSIPMessage : SIPMessage
@property (retain, nonatomic) NSString * format;
@property (retain, nonatomic) NSData *bytes;
@end
