//
//  Contact.h
//  SIPPhone
//
//  Created by developer on 7/23/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Conversation, Message;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pictureID;
@property (nonatomic, retain) NSString * sipID;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) Account *acount;
@property (nonatomic, retain) NSSet *conversations;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addConversationsObject:(Conversation *)value;
- (void)removeConversationsObject:(Conversation *)value;
- (void)addConversations:(NSSet *)values;
- (void)removeConversations:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
