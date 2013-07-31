//
//  ConversationsViewController.m
//  IM
//
//  Created by Aleksander on 03.06.13.
//  Copyright (c) 2013 Aleksander. All rights reserved.
//

#import "ConversationsViewController.h"

@interface ConversationsViewController ()

@property (retain, nonatomic) id<SipClientDelegate> delegate;
@property (retain,nonatomic) id<DataBaseManager> dataBaseManager;
@property (retain,nonatomic) id<sessionProvider> sessionProvider;
@property (retain, nonatomic) Contact* chosenContact;
@property (nonatomic, retain) NSMutableArray *listOfsipIDs;

@end

@implementation ConversationsViewController
@synthesize dataBaseManager = _dataBaseManager;
@synthesize sessionProvider = _sessionProvider;
@synthesize conversationsOfCurrentAccount = _conversationsOfCurrentAccount;
@synthesize chosenContact;
@synthesize delegate = _delegate;
@synthesize listOfsipIDs;
@synthesize countOfUnreadMessages = _countOfUnreadMessages;

/*- (void)changeBadgeValue
{
    static int val = 0;
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", val++];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeBadgeValue) userInfo:nil repeats:YES];
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    
	// Do any additional setup after loading the view, typically from a nib.
    self.countOfUnreadMessages = 0;
    self.navigationItem.title=@"Conversations";
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleDataChange:)
                                                name:NSManagedObjectContextObjectsDidChangeNotification
                                              object:[self.dataBaseManager contextForObseving]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(void)handleDataChange:(NSNotification *)notification
{
    // gets information about changes in database
    NSDictionary *userInfo = [notification userInfo];
    id messageChanger = [userInfo objectForKey:@"inserted"];
    
    // if something changed redraws the tableView
    if(messageChanger != nil)
    {
        [self.table reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    listOfsipIDs = [[NSMutableArray alloc] init];
    TabBarViewController * tab  = (TabBarViewController*)self.tabBarController;
    self.dataBaseManager = tab.dataBaseManager;
    self.sessionProvider = tab.sessionProvider;
    self.conversationsOfCurrentAccount =
    [self.dataBaseManager allConversationsOfAccountWithSipID:
     [self.sessionProvider authorizedUser]];
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [self.conversationsOfCurrentAccount count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set the data for this cell:
 
    Conversation * currentConversation = [self.conversationsOfCurrentAccount
                                         objectAtIndex:indexPath.row];
    NSArray *filteredContacts =
    [[currentConversation.contacts allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sipID != %@",[self.sessionProvider authorizedUser]]];
    cell.textLabel.text = [[filteredContacts lastObject]name];
    [listOfsipIDs addObject:[[filteredContacts lastObject]sipID]];
    cell.tag = listOfsipIDs.count-1;
    cell.detailTextLabel.text =
      [NSString stringWithFormat:@"%i", [currentConversation countOfUnread]];
    self.countOfUnreadMessages += [currentConversation countOfUnread];
    cell.imageView.image = [UIImage imageWithContentsOfFile:[[filteredContacts lastObject] pictureID]];
    // set the accessory view:
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

//---height of cells---
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

//action on clik
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    //---search with PREDICATE in array of contacts by sipID-----
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sipID == %@", [listOfsipIDs objectAtIndex:selectedCell.tag]];
    //---assigning selected contact to property for sending to other views
    NSMutableArray *listOfContacts = [[self.dataBaseManager
                       contactsOfAccountWithSipID:
                       [self.sessionProvider authorizedUser]]
                      mutableCopy];
    NSArray *currentContact = [listOfContacts filteredArrayUsingPredicate:predicate];
    chosenContact= [currentContact objectAtIndex:0];
    Conversation * currentConversation = [self.conversationsOfCurrentAccount
                                          objectAtIndex:selectedCell.tag];
    self.countOfUnreadMessages -= [currentConversation countOfUnread];
    [self.table reloadData];
    [self performSegueWithIdentifier:@"ShowChat" sender:self];
}


//---prepare data for passing in another views---
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *_chat = segue.destinationViewController;
    _chat.delegate = self.delegate;
    _chat.title=self.chosenContact.name;
    _chat.currentSIPID=self.chosenContact.sipID;
    _chat.dataBaseManager = self.dataBaseManager;
    _chat.sessionProvider = self.sessionProvider;
}
//---Orientation---
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    //---dispose of any resources that can be recreated---
    [super didReceiveMemoryWarning];
}

@end
