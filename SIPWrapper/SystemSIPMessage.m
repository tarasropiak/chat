//
//  SystemSIPMessage.m
//  SIPPhone
//
//  Created by admin on 20.07.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SystemSIPMessage.h"

@implementation SystemSIPMessage

-(id) initAsStatusRequestTo:(NSString *) destination andType:(int) subType {
    
        if(self=[super initWithCurentTimeAndType:SYSTEM_MESSAGE]){
        _body=@"";
        _subType=subType;
        _destination =destination;
    }
    else
    {
        return nil;
    }
    return self;
    
}
-(id) initAsStatusReplayTo:(NSString *) destination andStatus:(NSString *)status withStatusType:(int) subType{
    
    if(self=[super initWithCurentTimeAndType:SYSTEM_MESSAGE]){
        _body=@"";
        _subType=subType;
        _destination =destination;
    }
    else
    {
        return nil;
    }
    return self;
    
}

-(NSString *) body{
    
    if(!_body){
        _body = [[NSString alloc] init];
    }
    return _body;
}
-(NSString *) destination{
    
    if(!_destination){
        _destination = [[NSString alloc] init];
    }
    return _destination;
}


-(void)dealloc{
    
    [_body release];
    [super dealloc];
}
@end

