//
//  Contact+Managment.h
//  ChatModel
//
//  Created by developer on 6/19/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "Contact.h"

@interface Contact (Managment)

-(BOOL) hasConversationWith:(NSSet*)membersSipIDs;
-(void)sendMessageWithText:(NSString*) text
              toRecipinets:(NSSet*)resipients;
-(Conversation *) conversationWithSipIDs:(NSSet*) membersSipIDs;
-(BOOL) validateForInsert:(NSError **)error;
@end
