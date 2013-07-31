//
//  Conversation+Managment.m
//  ChatModel
//
//  Created by developer on 6/19/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "Conversation+Managment.h"
#import "Message.h"
@implementation Conversation (Managment)

-(BOOL) isConversationWithContactsWithSipIds:(NSSet *)sipIDs
{
    BOOL result = YES;
    /*
     If count of contacts of this conversation and 
     count of sipIDs are different,we set result NO
     */
    
    if([self.contacts count]!=([sipIDs count] + 1))
    {
        result = NO;
    } else
    {
        /*
         Else we must check contacts of this conversation
         has contact with every sipID.
         And if contact with some sipID is not exist we set 
         result NO
        */
        for(NSString *currentSip in sipIDs)
        {
            if(![self hasContactWithSipID:currentSip])
            {
                result = NO;
            }
        }
    }
    return result;
    
}

//Chek if current conversation has member with sipID
-(BOOL) hasContactWithSipID:(NSString *)sipID
{
    BOOL result = NO;
    NSSet *contacts = self.contacts;
    //filter only contacts with required sipId (using predicate)
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"sipID = %@",sipID];
    NSSet *filteredSet =
    [contacts filteredSetUsingPredicate:predicate];
    //If filtered set isn't empty set YES for result
    if ([filteredSet count] > 0)
    {
        result = YES;
    }
    return result;
}

//Adding message to conversation
-(void) addMessageWithText:(NSString *)text andSender:(Contact *)sender
{
    
    //Create new message object
    Message *messageForInsert = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Message"
                                inManagedObjectContext:self.managedObjectContext];
    //Set properties
    messageForInsert.text = text;
    messageForInsert.sender = sender;
    messageForInsert.date = [NSDate date];
    messageForInsert.state = [NSNumber numberWithBool:NO];
    messageForInsert.conversation = self;
    //Add relationship with this messages
    [self addMessagesObject:messageForInsert];

}

-(int)countOfUnread
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %i",0];
    NSArray *unreadMessages =[self.messages allObjects];
    NSArray *filteredMessages = [unreadMessages filteredArrayUsingPredicate:predicate];
    return [filteredMessages count];
}
@end
