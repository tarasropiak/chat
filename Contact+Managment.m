//
//  Contact+Managment.m
//  ChatModel
//
//  Created by developer on 6/19/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "Contact+Managment.h"
#import "Conversation+Managment.h"
#import "Account+Managment.h"
@implementation Contact (Managment)

-(BOOL) hasConversationWith:(NSSet *)membersSipIDs
{
    BOOL result = NO;
    //get set with all conversation
    NSSet *myConversations = self.conversations;
    //walk through this set
    for(Conversation* currentConversation in myConversations)
    {
        /*
         and search
         conversation only with membersSipIDs
         */
        if([currentConversation
            isConversationWithContactsWithSipIds:membersSipIDs])
        {
            //if conversation was found set valu YES to result
            result = YES;
        }
    }
    return result;
}

-(Conversation *) conversationWithSipIDs:(NSSet *)membersSipIDs
{
    Conversation*  requireConversation = nil;
    //get set with all conversation
    NSSet *myConversations = self.conversations;
    //walk through this set
    for(Conversation* currentConversation in myConversations)
    {
        /*
         and search
         conversation only with membersSipIDs
         */
        if([currentConversation
            isConversationWithContactsWithSipIds:membersSipIDs])
        {
            /*
             if conversation was found, store in in varaible
            requireConversation
             */
            requireConversation = currentConversation;
        }
    }
    return  requireConversation;

}

-(void) sendMessageWithText:(NSString *)text
               toRecipinets:(NSSet *)resipients
{
    NSError *error;
     
    //Check if contact has conversation with recipients
    if([self hasConversationWith:resipients])
    {
        /*if it has, we get this conversation and
         add to this conversation message with text and
         sender self.
         */
        Conversation* currentConversation =
                                  [self conversationWithSipIDs:resipients];
        [currentConversation addMessageWithText:text
                                      andSender:self];
     [currentConversation.managedObjectContext save:&error];
    } else
    {
        //Create conversation with recipients
        Conversation *newConversation =
        [NSEntityDescription
         insertNewObjectForEntityForName:@"Conversation"
         inManagedObjectContext:self.managedObjectContext];
       
        for(NSString* currentSip in resipients)
        {
            if([ self.acount hasContactWithSipID:currentSip])
            {
                [newConversation addContactsObject:
                                       [self.acount contactWithSip:currentSip]];
            }
            else
            {
                [self.acount addContactWithName:@"Unamed"
                                   sipID:currentSip
                            andPictureID:0];
                [newConversation addContactsObject:
                                       [self.acount contactWithSip:currentSip]];
            }
        }
        [newConversation addContactsObject:self];
        [self addConversationsObject:newConversation];
        for(Contact *current in newConversation.contacts)
        {
            [current addConversationsObject:newConversation];
        }
        [newConversation addMessageWithText:text andSender:self];
    }
}

-(BOOL)validateForInsert:(NSError **)error
{
    NSError *regErr = NULL;
    NSString *pattern = @"^[\"sip:\"]+[_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,4})$";
    NSRegularExpression *regex = [NSRegularExpression
                                         regularExpressionWithPattern:pattern
                                                              options:
                                             NSRegularExpressionCaseInsensitive
                                                                error:&regErr];
   
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self.sipID
                                                        options:0
                                                          range:
                                         NSMakeRange(0, [self.sipID length])];
    if(numberOfMatches!=1)
    {
        return  NO;
    }
    else
    {
        return YES;
    }
    
}


@end
