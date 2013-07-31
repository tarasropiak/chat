//
//  DAL.h
//  ChatModel
//
//  Created by developer on 6/10/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account+Managment.h"
#import "Contact+Managment.h"
#import "Conversation.h"
#import "Message.h"
#import <CoreData/CoreData.h>

@interface DAL : NSObject
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and
// bound to the persistent store coordinator for the application.
@property (readonly,nonatomic, retain) NSManagedObjectContext
                                                        *managedObjectContext;

- (Account *)accountWithSipID:(NSString *)sipId;
//Saves the Data Model onto the DB
- (void)saveContext;


//Method for ragistration account
- (void)registerAccountWithName:(NSString *)name
                          sipID:(NSString *)sipID
                       password:(NSString *)password
                        imageID:(NSString *)imageID;

//Check if acciunt with such sip id  is exist
- (BOOL)isExistAccountWithSipID:(NSString *)sipID;

//Delete account by sipID
- (void)deleteAccountWithSipID:(NSString *)sipID;


//AddingContact to account with sipID
- (void)addContactWithName:(NSString *)name
                     sipID:(NSString *)sipID
                 pictureID:(NSString *)picID
         toAcountWithSipID:(NSString *)acountSIP;

//Deleting contact from account vy sipID
- (void)deleteContactWithsSipID:(NSString *)sipID
            fromAcountWithSipID:(NSString *)acountSIP;

//Getting all array with contacts of some account
- (NSArray *)contactsOfAccountWithSipID:(NSString *)sipID;

//Sending message from 
- (void)sendMessageFromSipID:(NSString *)senderID
                    toSipIDs:(NSSet *)recipintsSipIDs
                    withText:(NSString *)text;
//Reciving message
- (void)reciveMessageFrom:(NSString *)senderSip
                  ithText:(NSString *)text
                inAccount:(NSString *)recipentSip;

//Getting message history between two contacts
- (NSArray *)conversationBettwenAccountWithSipID:(NSString *)accountSIP
                             andContactWithSipID:(NSString *)contactSip;

//Getting the last message between two contacts
- (Message *)lastMessageBettwenAccountWithSipID:(NSString *)accountSIP
                            andContactWithSipID:(NSString *)contactSip;

//Update contacts information
- (void)updateNameWith:(NSString *)newName
            andPicture:(NSString *)imagePath
    inContactWithSipID:(NSString *)contactSIP
    ofAccountWithSipID:(NSString *)accountSIP;

//Getting all conversation of account
- (NSArray *)allConversationsOfAccountWithSipID:(NSString *)sipID;

- (void)readAllMessagesInConversationBetween:(NSString *)accountSipID
                                  andContact:(NSString *)contactSIP;


- (void)changeStatusOn:(int)status inContactWithSip:(NSString *)sip;

- (void)incrementDate;
@end
