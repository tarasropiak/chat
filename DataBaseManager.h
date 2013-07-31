//
//  DataBaseManger.h
//  SIPPhone
//
//  Created by developer on 6/29/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Message;
@class Account;
@class DAL;
@protocol DataBaseManager <NSObject>
-(NSArray*)contactsOfAccountWithSipID:(NSString*)sipID;
- (void) addContactWithName:(NSString*)name
                      sipID:(NSString*)sipID
                  pictureID:(NSString*)picID
          toAcountWithSipID:(NSString*)acountSIP;
-(NSArray*)firstThirtyMessagesBetweenSender:(NSString*) senderSip
                               andRecipient:(NSString*)recipientSip;
-(void) sendMessageFromSipID:(NSString*) _senderID
                    toSipIDs:(NSSet*)_recipintsSipIDs
                    withText:(NSString*)_text;
-(NSManagedObjectContext*) contextForObseving;
-(void) reciveMessageFrom:(NSString *)senderSip
                 WithText:(NSString *)text
                inAccount:(NSString *)recipentSip;

-(Message*)lastMessageBettwenAccountWithSipID:(NSString*)accountSIP
                          andContactWithSipID:(NSString*)contactSip;

-(void)deleteContactWithsSipID:(NSString *)sipID
           fromAcountWithSipID:(NSString *)acountSIP;

-(void) updateNameWith:(NSString*)newName
            andPicture:(NSString*)imagePath
    inContactWithSipID:(NSString*)contactSIP
    ofAccountWithSipID:(NSString*)accountSIP;
-(NSArray*) allConversationsOfAccountWithSipID:(NSString*)sipID;

-(void) readAllMessagesInConversationBetween:(NSString*)accountSipID
                                  andContact:(NSString*)contactSIP;
-(Account*) accountWithSipID:(NSString*)sipId;

-(void) changeStatusOn:(int)status inContactWithSip:(NSString*)sip;

- (void)registerAccountWithName:(NSString *)name
                          sipID:(NSString *)sipID
                       password:(NSString*)password
                        imageID:(NSString*)imageID;
-(DAL*)sharedInstance;
@end
