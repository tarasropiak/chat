//
//  Account+Managment.h
//  ChatModel
//
//  Created by developer on 6/10/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "Account.h"
#import "Contact.h"
@interface Account (Managment)

-(Contact*)contactWithSip:(NSString*)sipID;
-(void)deleteContactOfYourSelf;
-(BOOL)hasContactWithSipID:(NSString*) contactSIP;
-(void)sentMessageWithText: (NSString*) text
       ToContactsWithSipId:(NSSet*) recipients;
-(Contact*)contactOfMySelf;
-(void) reciveMessageWithText:(NSString*)messageText
                    fromSipID:(NSString*)senderSIP;
-(NSArray*) allConversations;
-(void)setNewName:(NSString *)newName andPicture:(NSString *)pictureURL;
-(int)status;
-(void)setStatus:(NSString *)status;
@end
