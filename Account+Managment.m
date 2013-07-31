//
//  Account+Managment.m
//  ChatModel
//
//  Created by developer on 6/10/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "Account+Managment.h"
#import "Contact+Managment.h"
#import "Conversation+Managment.h"
@implementation Account (Managment)


- (BOOL) hasContactWithSipID:(NSString *)contactSIP
{
    
    BOOL contactAlreadyExist = NO;
        for(Contact *currentContact in self.contacts)
    {
        if ([currentContact.sipID isEqualToString:contactSIP])
        {
            contactAlreadyExist = YES;
        }
    }
    
    return contactAlreadyExist;
}
 
-(void)deleteContactOfYourSelf
{
    NSArray *myContacts = [NSArray arrayWithArray:
                                  [self.contacts allObjects]];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"sipID == %@", self.sipID ];
    
    NSArray *filteredObjects = [myContacts filteredArrayUsingPredicate:predicate];
    Contact *myContact = [filteredObjects lastObject];
    [self.managedObjectContext deleteObject:myContact];

}

-(Contact*) contactOfMySelf
{
    
   NSArray *myContacts = [NSArray arrayWithArray:
                                             [self.contacts allObjects]];
   NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"sipID == %@", self.sipID ];
    
    NSArray *filteredObjects = [myContacts filteredArrayUsingPredicate:predicate];
    Contact *myContact = [filteredObjects lastObject];
    return myContact;
} 

-(Contact*)contactWithSip:(NSString *)sipID
{
    Contact *requiredContact = nil;
    for(Contact* current in self.contacts)
    {
        if([current.sipID isEqualToString:sipID])
        {
            requiredContact = current;
            break;
        }
    }
    return  requiredContact;
    
}
-(void) sentMessageWithText:(NSString *)text
        ToContactsWithSipId:(NSSet *)recipients
{
    //Get contact of myseklf and send message from this contact
    Contact *sender = [self contactOfMySelf];
    [sender sendMessageWithText:text toRecipinets:recipients];
}
-(void)reciveMessageWithText:(NSString *)messageText
                   fromSipID:(NSString *)senderSIP
{
    Contact *sender = [self contactWithSip:senderSIP];
    NSSet *recipients = [[NSSet alloc]initWithObjects:self.sipID, nil];
    [sender sendMessageWithText:messageText toRecipinets:recipients];
    
}

-(NSArray*)allConversations
{
    Contact  *contactOfMyself = [self contactOfMySelf];
    NSArray *myConversations = [[contactOfMyself.conversations allObjects]copy];
    return myConversations;
}

-(void)setNewName:(NSString *)newName andPicture:(NSString *)pictureURL
{
    self.name = newName;
    if(pictureURL!=nil)
    {
        self.pictureID = pictureURL;
    }
    [self.managedObjectContext save:nil];
}

-(int)status
{
    return self.contactOfMySelf.status.intValue;
}

-(void)setStatus:(NSString *)status
{
    if([status isEqualToString:@"Online"])
    {
        self.contactOfMySelf.status = [NSNumber numberWithInt:0];
    }
    else if([status isEqualToString:@"Busy"])
    {
        self.contactOfMySelf.status = [NSNumber numberWithInt:1];
    } else if([status isEqualToString:@"Don't disturb"])
    {
        self.contactOfMySelf.status = [NSNumber numberWithInt:2];
    }
}
@end
