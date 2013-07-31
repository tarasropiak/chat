//
//  Messagge.h
//  SIPPhone
//
//  Created by admin on 11.06.13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

//Class whitch descrip message
#import <Foundation/Foundation.h>

@interface MessageWrapper : NSObject
@property (retain, nonatomic) NSString* urlField; 
@property (retain, nonatomic) NSString* nameField;
@property (retain, nonatomic) NSString* messageField;

@property (retain, nonatomic) NSArray* recievers;
@property (retain, nonatomic) NSDate*  time;
@property (retain, nonatomic) NSData*  dataBuffer;
@property (retain, nonatomic) NSString* dataFormat;
@end
