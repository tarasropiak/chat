//
//  SIPMessage.h
//  SIPPhone
//
//  Created by admin on 20.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

/*  Define classes for messages*/
#define SIMPLE_MESSAGE (0)
#define SYSTEM_MESSAGE (1)
#define DATA_TRANSFER_MESSAGE (2)

/*  Define subclasses for system messages */

//  NETWORK defines
#define GET_NET_STATUS  (10)
#define SEND_NET_STATUS (11)
#define GET_NET_STATUS_VERBOSE (12)

// "SOUL" defines
#define GET_SOUL_STATUS  (20)
#define SEND_SOUL_STATUS (21)
#define GET_SOUL_STATUS_VERBOSE (22)

//  PING defines
#define GET_PING  (30)
#define SEND_PING (31)
#define GET_PING_VERBOSE (32)


@interface SIPMessage : NSObject

@property (nonatomic) int type;
@property (nonatomic) double SSN;

-(id)initWithCurentTimeAndType:(int) type;
@end


