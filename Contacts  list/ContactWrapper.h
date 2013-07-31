//
//  Contact.h
//  MyChat
//
//  Created by Administrator on 6/13/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactWrapper : NSObject
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* avatar;

-(id) initWithName:(NSString*)theName Description:(NSString*)theDescription Image:(NSString*)theImage;

@end
