//
//  Contact.m
//  MyChat
//
//  Created by Administrator on 6/13/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import "ContactWrapper.h"

@implementation ContactWrapper
@synthesize name;
@synthesize description;
@synthesize avatar;

-(id) initWithName:(NSString*)theName Description:(NSString*)theDescription Image:(NSString*)theImage
{
    self = [super init];
    if(self)
    {
        self.name = theName;
        self.description = theDescription;
        self.avatar = theImage;
    }
    return self;
}
@end
