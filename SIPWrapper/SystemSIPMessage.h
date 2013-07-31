//
//  SystemSIPMessage.h
//  SIPPhone
//
//  Created by admin on 20.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SIPMessage.h"

@interface SystemSIPMessage : SIPMessage
@property (nonatomic) int subType;
@property (retain, nonatomic) NSString * body;
@property (retain, nonatomic) NSString * destination;

-(id) initAsStatusRequestTo:(NSString *) destination
                    andType:(int) subType;

-(id) initAsStatusReplayTo:(NSString *) destination
                 andStatus:(NSString *)status
            withStatusType:(int) subType;
@end

