//  DAL.m
//  ChatModel
//
//  Created by developer on 6/10/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "DAL.h"

//Private instance methods/properties
@interface DAL()
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
@property (readonly, retain, nonatomic) NSManagedObjectModel
                                                            *managedObjectModel;
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's
// store added to it.
@property (readonly,retain,nonatomic) NSPersistentStoreCoordinator
                                                    *persistentStoreCoordinator;
// Returns the URL to the application's Documents directory.
@property (retain,nonatomic) NSDate *dateForFetchingMessages;
@property (retain,nonatomic) NSDateComponents *components;
- (NSURL *)applicationDocumentsDirectory;


@end

@implementation DAL

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

-(id)init
{
    if ( self = [super init] ) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        self.dateForFetchingMessages = [[NSDate alloc]init];
        self.components = [cal
                           components:
                           ( NSHourCalendarUnit   |
                             NSMinuteCalendarUnit |
                             NSSecondCalendarUnit   )
                           fromDate:[[NSDate alloc] init]];
        
        [self.components setHour:-[self.components hour]];
        [self.components setMinute:-[self.components minute]];
        [self.components setSecond:-[self.components second]];
        self.dateForFetchingMessages =
                                    [cal dateByAddingComponents:self.components
                                        toDate:self.dateForFetchingMessages
                                                        options:0];
    }
    return self;
}

-(Account*)accountWithSipID:(NSString *)sipId
{
    //Create fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //Get Entity description Account
    NSEntityDescription *accountEntity = [NSEntityDescription
                                   entityForName:@"Account"
                          inManagedObjectContext:self.managedObjectContext];
    //Initialize fetch request (set entity and predicate
    fetchRequest.entity = accountEntity;
    NSPredicate *predicate =
                      [NSPredicate predicateWithFormat:@"sipID == %@", sipId ];
    fetchRequest.predicate = predicate;
    //Make query
    NSArray *fetchedObjects = [self.managedObjectContext
                                    executeFetchRequest:fetchRequest error:nil];
    [fetchRequest release];
    //We know that all acounts have different sip ID, that's why
    // we are sure than fetch request return array with one objects
    // We must only get this object by lastObject method
   
    return fetchedObjects.lastObject;
}
//Saves the Data Model onto the DB
- (void)saveContext
{
    NSError * error = nil;
    if (self.managedObjectContext != nil)
    {
        if ([self.managedObjectContext hasChanges]
                                    &&
                                     ![self.managedObjectContext save:&error])
        {
            [self.managedObjectContext reset];
            NSException* myException = [NSException
                                     exceptionWithName:@"InvalidSipIdException"
                                                reason:@"Invalid contact's sip"
                                              userInfo:nil];
         
            //Need to come up with a better error management here.
            @throw myException;
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and
// bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
        return __managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the
// application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
        return __managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model"
                                              withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc]
                            initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the
// application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
        return __persistentStoreCoordinator;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory]
                       URLByAppendingPathComponent:@"MyData.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                    initWithManagedObjectModel:
                                                     [self managedObjectModel]];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:
                                                            NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:storeURL
                                                          options:nil
                                                            error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask]
                                                                    lastObject];
}

//Method for register a new account
-(void)registerAccountWithName:(NSString *)name
                         sipID:(NSString *)sipID
                      password:(NSString *)password
                       imageID:(NSString *)imageID
{
    if(![self isExistAccountWithSipID:sipID]) //Check if account already exist
    {
        NSManagedObjectContext *context = self.managedObjectContext;
        //Create insert new accoount
        Account *acount = [NSEntityDescription
                           insertNewObjectForEntityForName:@"Account"
                           inManagedObjectContext:context];
        //Set values for this account
        acount.name = name;
        acount.password = password;
        acount.pictureID = imageID;
        acount.sipID = sipID;
        /*For correct representing message history we need to have
         contact for every account, we need no relatonship for this contact*/
        Contact *contactOfAccount = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"Contact"
                                              inManagedObjectContext:context];
        contactOfAccount.name = name;
        contactOfAccount.sipID = sipID;
        contactOfAccount.pictureID = imageID;
        //Adding contact of account
        [acount addContactsObject:contactOfAccount];
        [self saveContext];
    }
}

//Check if account with sipID is exist
-(BOOL) isExistAccountWithSipID:(NSString *)sipID
{
    return [self accountWithSipID:sipID] ? YES : NO;
}

-(void)deleteAccountWithSipID:(NSString *)sipID
{
    Account *accountForDelete = [self accountWithSipID:sipID];
    //Delete acount
    [accountForDelete deleteContactOfYourSelf];
    [accountForDelete.managedObjectContext deleteObject:accountForDelete];
    //Save context and check error
    [self saveContext];
}

//Method for add contact to account
-(void)addContactWithName:(NSString *)name
                    sipID:(NSString *)sipID
                pictureID:(NSString*)picID
        toAcountWithSipID:(NSString *)acountSIP
{
    
    Account * accountObj = [self accountWithSipID:acountSIP];
    Contact *contactForInsert = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    contactForInsert.name = name;
    contactForInsert.sipID = sipID;
    contactForInsert.pictureID = picID;
    contactForInsert.status = [NSNumber numberWithInt:0];
    [accountObj addContactsObject:contactForInsert];
    [self saveContext];
}

//Method for delete contact from account
-(void)deleteContactWithsSipID:(NSString *)sipID
           fromAcountWithSipID:(NSString *)acountSIP
{
    Account * accountObj = [self accountWithSipID:acountSIP];
    //delete selected acount
    Contact *contactForDeleting = [accountObj contactWithSip:sipID];
    [accountObj removeContactsObject:contactForDeleting];
    [self saveContext];
}

//Get set of account's contacts
-(NSArray*)contactsOfAccountWithSipID:(NSString *)sipID
{
    Account * accountObj = [self accountWithSipID:sipID];
    NSArray *contacts = [accountObj.contacts allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                                    @"sipID != %@", sipID ];
    contacts = [contacts filteredArrayUsingPredicate:predicate];
    return  contacts;
}

-(NSDate*) currentDateAndTime
{
    NSDate *now = [NSDate date];
    return  now;
}

-(void) sendMessageFromSipID:(NSString *)senderID
                    toSipIDs:(NSSet *)recipintsSipIDs
                    withText:(NSString *)text

{
    NSError  *error = nil;
    //get account of sender
    if([self isExistAccountWithSipID:senderID])
    {
        Account *sender = [self accountWithSipID:senderID];
        //And sendMessage from this account
        [sender sentMessageWithText:text
            ToContactsWithSipId:recipintsSipIDs];
        [sender.managedObjectContext save:&error];
    }
}

/*
 Getting first 30 messages from conversation
 later this method must be modified. 
 */
-(NSArray*)conversationBettwenAccountWithSipID:(NSString *)accountSIP
                           andContactWithSipID:(NSString *)contactSip
{
    Account *currentAccount = [self accountWithSipID:accountSIP];
    Contact *contactOfCurrentAccount = [currentAccount contactOfMySelf];
    NSSet   *conversationMembers = [[NSSet alloc]
                                   initWithObjects:contactSip, nil];
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                         [NSSortDescriptor
                                            sortDescriptorWithKey:@"date"
                                                                 ascending:NO]];
    //[self incrementDate];
    NSArray *messages = [[[[[contactOfCurrentAccount
                          conversationWithSipIDs:conversationMembers] messages]
                                                                    allObjects]
                                   sortedArrayUsingDescriptors:sortDescriptors]
                                                                          copy];
    NSArray *partMessages;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@",
                              self.dateForFetchingMessages];
    partMessages = [messages filteredArrayUsingPredicate:predicate];
    sortDescriptors = [NSArray arrayWithObject:
                                           [NSSortDescriptor
                                                sortDescriptorWithKey:@"date"
                                                                ascending:YES]];
   partMessages = [partMessages sortedArrayUsingDescriptors:sortDescriptors]; // TODO: Memory leak here
   
   return partMessages;
}
-(void) reciveMessageFrom:(NSString *)senderSip
                 WithText:(NSString *)text
                inAccount:(NSString *)recipentSip
{
    NSError  *error = nil;

    Account *currentAccount = [self accountWithSipID:recipentSip];
    [currentAccount reciveMessageWithText:text fromSipID:senderSip];
    [currentAccount.managedObjectContext save:&error];
}

-(Message*)lastMessageBettwenAccountWithSipID:(NSString *)accountSIP
                          andContactWithSipID:(NSString *)contactSip
{
    Account *currentAccount = [self accountWithSipID:accountSIP];
    Contact *contactOfCurrentAccount = [currentAccount contactOfMySelf];
    NSSet * conversationMembers = [NSSet setWithObjects:contactSip, nil];
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                                [NSSortDescriptor
                                                  sortDescriptorWithKey:@"date"
                                                              ascending:YES]];
    NSArray *messages =
    [[contactOfCurrentAccount
                conversationWithSipIDs:conversationMembers].messages.allObjects
                                    sortedArrayUsingDescriptors:sortDescriptors];
    Message *lastMessage = messages.lastObject;
    return lastMessage;
}

-(void)updateNameWith:(NSString *)newName
           andPicture:(NSString *)imagePath
   inContactWithSipID:(NSString *)contactSIP
   ofAccountWithSipID:(NSString *)accountSIP
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSError *error = nil;
    //==============Make query for select account====================
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *contactEntity = [NSEntityDescription
                                   entityForName:@"Contact"
                                   inManagedObjectContext:context];
    fetchRequest.entity = contactEntity;
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:
                                @"sipID == %@ AND acount.sipID == %@",
                                                    contactSIP ,accountSIP ];
    fetchRequest.predicate = predicate;
    Contact *contactForUpdate = [[context executeFetchRequest:fetchRequest
                                                        error:&error] lastObject];
    
    contactForUpdate.name = newName;
    if(imagePath != nil)
    {
        contactForUpdate.pictureID = imagePath;
    }
    [context save:&error];
    

}

-(NSArray*)allConversationsOfAccountWithSipID:(NSString *)sipID
{
    Account *currentAccount = [self accountWithSipID:sipID];
    NSArray *allConversations = [currentAccount allConversations];
    return  allConversations;
}

-(void)readAllMessagesInConversationBetween:(NSString *)accountSipID
                                 andContact:(NSString *)contactSIP
{
    Account *currentAccount = [self accountWithSipID:accountSipID];
    Contact *contactOfCurrentAccount = [currentAccount contactOfMySelf];
    
    NSSet *recipients = [[NSSet alloc]initWithObjects:contactSIP, nil];
    
    Conversation *conversation = [contactOfCurrentAccount
                                            conversationWithSipIDs:recipients];
    [recipients release];
    for(Message *currentMessage in conversation.messages)
    {
        if([currentMessage.state boolValue] == NO)
        {
            currentMessage.state = [NSNumber numberWithBool: YES];
        }
    }
    
    [self saveContext];
}

-(void) changeStatusOn:(int)status inContactWithSip:(NSString*)sip
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *contactEntity = [NSEntityDescription
                                                   entityForName:@"Contact"
                                          inManagedObjectContext:
                                                     self.managedObjectContext];
    fetchRequest.entity = contactEntity;
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:
                              @"sipID == %@",sip ];
    fetchRequest.predicate = predicate;
    NSArray *contacts = [self.managedObjectContext
                         executeFetchRequest:fetchRequest
                         error:nil];
    for(Contact *current in contacts)
    {
        current.status = [NSNumber numberWithInt:status];
    }
    [self saveContext];
}

-(void) incrementDate
{
    self.components.hour -=24;
    NSCalendar *cal = [NSCalendar currentCalendar];
    self.dateForFetchingMessages =
    [cal dateByAddingComponents:self.components
                         toDate:self.dateForFetchingMessages
                        options:0];

}
@end

