//
//  Conversation+Managment.h
//  ChatModel
//
//  Created by developer on 6/19/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "Conversation.h"

@interface Conversation (Managment)
-(BOOL) isConversationWithContactsWithSipIds:(NSSet*) sipIDs;
-(BOOL) hasContactWithSipID:(NSString*)sipID;
-(void) addMessageWithText:(NSString*)text
                 andSender:(Contact*)sender;
-(int)countOfUnread;
@end
