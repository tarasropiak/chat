//  ContactsViewController.m
//  MyChat
//
//  Created by Administrator on 6/13/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import "ContactsViewController.h"
#import "ChatViewController.h"
#import "AddUserViewController.h"
#import "TabBarViewController.h"

@interface ContactsViewController ()
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *contactSection;
@property (nonatomic, retain) NSMutableArray *filteredTableData;
@property (nonatomic, retain) NSMutableArray *listOfContacts;
@property (nonatomic, retain) NSMutableArray *listOfContactsUnsorted;
@property (nonatomic, retain) NSMutableArray *listOfLetters;
@property (nonatomic, retain) NSMutableArray *searchResult;
@property (nonatomic, retain) NSArray* sortedList;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSIndexPath *index;
@property (nonatomic, retain) Contact* chosenContact;

@property CGRect kbSize;
@property CGFloat initialTVHeight;
@property BOOL isFiltered;
@property BOOL searchPressed;
@end


@implementation ContactsViewController

const int ROW_HEIGHT = 70;
const double HIGHLIGT_DELAY = 0.5;
const double SCROLL_DELAY = 0.5;
const double ECHO_DELAY = 10.0;
const int BUTTON_HEIGHT = 32;
const int BUTTON_WIDTH = 32;

#pragma mark - View lifecycle method

-(void)viewWillAppear:(BOOL)animated{
    //---preparations and selection of row before view appears---
    [self sortList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //echo for status
    [NSTimer scheduledTimerWithTimeInterval:ECHO_DELAY target:  self selector:@selector(getStatuses) userInfo:nil repeats:YES];
    //Adding observer for keyboard showing
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
    
    //Config search button up right
    self.navigationItem.title=@"Contacts";
    UIButton *searchBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setImage:[UIImage imageNamed:@"magnify.png"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchPushed) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    //Config add button up left
    UIButton *addContact =  [UIButton buttonWithType:UIButtonTypeCustom];
    [addContact setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [addContact addTarget:self action:@selector(addPushed) forControlEvents:UIControlEventTouchUpInside];
    [addContact setFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addContact];
    
    //Gesture recognizer for ending search on tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.tableView addGestureRecognizer:tap];
    //---initialize flags---
    [self viewNotSearching];
    //—--initialize the arrays and adding elements—--
    self.listOfLetters = [[NSMutableArray alloc] init];
    self.listOfContacts = [[NSMutableArray alloc] init];
    self.listOfContactsUnsorted = [[NSMutableArray alloc] init];
    self.filteredTableData = [[NSMutableArray alloc] init];
    self.searchResult = [[NSMutableArray alloc] init];
    self.contactSection = [[NSMutableArray alloc] init];
    self.sortedList = [[NSArray alloc] init];
    //---sort method---
    [self sortList];
}

- (void) viewDidAppear:(BOOL)animated
{   if(self.chat){
        self.chat=NO;
        [self performSegueWithIdentifier:@"ChatSegue" sender:self];
    }
    if([self.listOfContacts indexOfObject:self.chosenContact]!=NSNotFound){
        [self performSelector:@selector(scrollAtPosition) withObject:self];
        //---highlight cell scrolled to---
        [self.tableView selectRowAtIndexPath:self.index animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self performSelector:@selector(deselect) withObject:self afterDelay:HIGHLIGT_DELAY];
    }
}

#pragma mark - Keyboard handle methods

//---keyboard show event---
- (void) keyboardDidShow:(NSNotification *)nsNotification {
    self.initialTVHeight = self.tableView.frame.size.height;
    CGRect initialFrame = [[[nsNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedFrame = [self.view convertRect:initialFrame fromView:nil];
    CGRect tvFrame = self.tableView.frame;
    [UIView beginAnimations:@"TableViewUp" context:NULL];
    double animationDuration;
    animationDuration = [[[nsNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView setAnimationDuration:animationDuration];
    tvFrame.size.height = convertedFrame.origin.y-self.searchBar.frame.size.height;
    tvFrame.origin.y+=self.searchBar.frame.size.height;
    self.tableView.frame = tvFrame;
    [UIView commitAnimations];
}
//---keyboard hide event---
- (void) keyboardWillHide:(NSNotification *)nsNotification {
    CGRect tvFrame = self.tableView.frame;
    tvFrame.size.height = self.initialTVHeight;
    tvFrame.origin.y-=self.searchBar.frame.size.height;
    [UIView beginAnimations:@"TableViewDown" context:NULL];
    double animationDuration;
    animationDuration = [[[nsNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView setAnimationDuration:animationDuration];
    self.tableView.frame = tvFrame;
    [UIView commitAnimations];
}
#pragma mark - Sorting list of contact method

//---method for sorting list
- (void) sortList{
    self.listOfContactsUnsorted = [[self.dataBaseManager
                                    contactsOfAccountWithSipID:
                                    [self.sessionProvider authorizedUser]]
                                   mutableCopy];
    //---sorting with criteria using comparator---
    self.sortedList = [self.listOfContactsUnsorted sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Contact*)a name];
        NSString *second = [(Contact*)b name];
        return [first compare:second];
    }];
    //---convertion to mutable array from temp array---
    self.listOfContacts=[self.sortedList mutableCopy];
    [self.tableView reloadData];
    
}
#pragma mark - Searching on text changing method

//---search method---
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.isFiltered = NO;
    }
    else
    {
        self.isFiltered = YES;
        self.filteredTableData = [[NSMutableArray alloc] init];
        Contact* contact;
        for (contact in self.listOfContacts)
        {
            NSRange nameRange = [contact.name rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [contact.sipID rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [self.filteredTableData addObject:contact];
            }
        }
    }
    [self.tableView reloadData];
}
#pragma mark - Table view configering and filling with data

//Number of sections which actually have contacts in + deleting letters which don't have contacts
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //---get first letters of contact list without dupes
    NSMutableSet *firstCharacters = [NSMutableSet setWithCapacity:0];
    for( NSString *string in [self.listOfContacts valueForKey:@"name"] ){
        [firstCharacters addObject:[string substringToIndex:1]];
    }
    //---sort list of letters---
    NSArray *uniquearray = [[firstCharacters allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    //---saving in property---
    self.listOfLetters= [uniquearray mutableCopy];
    if(!self.isFiltered){
        return [self.listOfLetters count];
    }
    else
        return 1;
}

//—--set the number of rows in each existing section—--
-(NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{   if(!self.isFiltered){
    //---check if first letter of contact matches section's letter with the help of predicate
    NSPredicate *myPred = [NSPredicate predicateWithFormat:
                           @"name beginswith[cd] %@",[self.listOfLetters objectAtIndex:section]];
    NSArray *contactsInSection = [self.listOfContacts filteredArrayUsingPredicate:myPred];
    return [contactsInSection count];
}
else
    return [self.filteredTableData count];
}

//---get the letter as the section header---
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(!self.isFiltered){
        return [self.listOfLetters objectAtIndex:section];
    }
    else
        return nil;
}

//---adding indexes---
- (NSMutableArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(self.searchPressed){
        return self.listOfLetters;
    }
    else
        return nil;
}

//---display contacts---
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    //NSMutableArray *contactSection;
    NSString *letter;
    //—-try to get a reusable cell—-
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    //---highlight color---
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //---set background image as bg and filler---
    cell.imageView.image = [UIImage imageNamed:@"spacer.png"];
    UIImageView *customImageView = [[UIImageView alloc] initWithFrame:(CGRect){.size={cell.imageView.image.size.width, ROW_HEIGHT}}];
    UIImage *image;
    if(!self.isFiltered){
        [self.contactSection removeAllObjects];
        //---get the letter---
        letter = [self.listOfLetters objectAtIndex:[indexPath section]];
        //---get the list of contact for that letter---
        for(int i=0;i<[self.listOfContacts count];i++){
            if ([[[[[self.listOfContacts objectAtIndex:i]name]substringFromIndex:0]substringToIndex:1] isEqualToString: letter]){
                [self.contactSection addObject:[self.listOfContacts objectAtIndex:i]];
            }
        }
        //---get the particular contact based on that row---
        cell.textLabel.text = [[self.contactSection objectAtIndex:[indexPath row]]name];
        cell.detailTextLabel.text = [[self.contactSection objectAtIndex:[indexPath row]]sipID];
        image = [UIImage imageWithContentsOfFile:[[self.contactSection objectAtIndex:[indexPath row]]pictureID]];
        //Statuses

        NSString *status;
        
        switch([[(Contact*)[self.contactSection objectAtIndex:[indexPath row]]status]intValue]) {
            case 0:
                status=@"online.png";
                break;
            case 1:
                status=@"offline.png";
                break;
            case 2:
                status=@"busy.png";
                break;
            case 3:
                status=@"donotdisturb.png";
                break;
        }
        
        cell.accessoryView = [[ UIImageView alloc ]
                              initWithImage:[UIImage imageNamed:status]];

       
    }
    else{
        cell.textLabel.text= [[self.filteredTableData objectAtIndex:[indexPath row]]name];
        cell.detailTextLabel.text = [[self.filteredTableData objectAtIndex:[indexPath row]]sipID];
        image = [UIImage imageWithContentsOfFile:[[self.filteredTableData objectAtIndex:[indexPath row]]pictureID]];
    }
    //---adding custom imageview for equal size of images---
    customImageView.image = image;
    [cell.contentView addSubview:customImageView];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.clipsToBounds = YES;
    return cell;
}

//---height of cells---
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ROW_HEIGHT;
}

-(void) deselect{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Cell selection event

//---message on clicking---
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    //---search with PREDICATE in array of objects by object.name-----
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name like[cd] %@) AND (sipID like[cd] %@)", selectedCell.textLabel.text, selectedCell.detailTextLabel.text];
    NSArray *filtered = [self.listOfContacts filteredArrayUsingPredicate:predicate];
    //---assigning selected contact to property for sending to other views
    self.chosenContact= [filtered objectAtIndex:0];
    if(!self.searchPressed){
        [self viewNotSearching];
        [self.tableView reloadData];
    }
    [self performSegueWithIdentifier:@"Details" sender:self];
    self.searchBar.text=@"";
}

#pragma mark - Button action events (add, search, cancel search)
//---add contact event(Add New Contact)---
- (void) addPushed {
    if(!self.searchPressed){
        [self viewNotSearching];
        [self.tableView reloadData];
    }
    [self performSegueWithIdentifier:@"AddContact" sender:self];
    [self performSelector:@selector(scrollToTop) withObject:self afterDelay:SCROLL_DELAY];
    self.searchBar.text=@"";
}

//---search button push event---
- (void) searchPushed {
    if(!self.searchPressed)
    {
        [self viewNotSearching];
    }
    else
    {
        [self.searchBar becomeFirstResponder];
        if(![self.searchBar.text isEqualToString:@""]){
            [self searchBar:self.searchBar textDidChange:self.searchBar.text];
        }
        self.searchPressed = NO;
    }
    [self.tableView reloadSectionIndexTitles];
    [self.tableView reloadData];
}

- (IBAction)cancelSrc:(id)sender {
    [self viewNotSearching];
    [self.tableView reloadSectionIndexTitles];
    [self.tableView reloadData];
}

#pragma mark - Prepare data for segues
//---prepare data for passing in another views---
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ChatSegue"])
    {
        ChatViewController *chat = segue.destinationViewController;
        chat.delegate = self.delegate;
        chat.title=self.chosenContact.name;
        chat.currentSIPID=self.chosenContact.sipID;
        chat.dataBaseManager = self.dataBaseManager;
        chat.sessionProvider = self.sessionProvider;
    }
    else
        if([segue.identifier isEqualToString:@"AddContact"])
        {
            AddUserViewController *tmpAddUserControllerPtr = segue.destinationViewController;
            tmpAddUserControllerPtr.dataBaseManager = self.dataBaseManager;
            tmpAddUserControllerPtr.sessionProvider = self.sessionProvider;
            if(self.chosenContact){
                self.chosenContact=nil;
            }
        }
        else
            if([segue.identifier isEqualToString:@"Details"])
            {
                DetailsViewController *tmpDetailsViewControllerPtr = segue.destinationViewController;
                tmpDetailsViewControllerPtr.dataBaseManager = self.dataBaseManager;
                tmpDetailsViewControllerPtr.sessionProvider = self.sessionProvider;
                tmpDetailsViewControllerPtr.chosenContact = self.chosenContact;
                tmpDetailsViewControllerPtr.delegate = self.delegate;
            }
}
//---storyboard segue handlers---
- (IBAction)chatSegue:(UIStoryboardSegue *)segue {
    self.chat=YES;
}

- (IBAction)deleteSegue:(UIStoryboardSegue *)segue {
    self.chosenContact = nil;
    [self performSelector:@selector(scrollToTop) withObject:self];
}

#pragma mark - Tap handler
//---end searching on tap---
- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    if (indexPath){
        //we are in a tableview cell, let the gesture be handled by the view
        recognizer.cancelsTouchesInView = NO;
    }
    else{
        // anywhere else, do what is needed for your case
        if(!self.searchPressed){
            [self viewNotSearching];
            [self.tableView reloadSectionIndexTitles];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Scroll methods
//---scroll to previous selected cell---
- (void)scrollAtPosition{
    //---update chosen contact if we changed it---
    if(![self.listOfContacts containsObject:self.chosenContact]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name like[cd] %@)", self.chosenContact.sipID];
        NSArray *filtered = [self.listOfContacts filteredArrayUsingPredicate:predicate];
        self.chosenContact= [filtered objectAtIndex:0];
    }
    //---get the row index of selected contact(in d-fault tableview) with the help of predicate---
    NSPredicate *myPred = [NSPredicate predicateWithFormat:
                           @"name beginswith[cd] %@",[[self.chosenContact.name substringFromIndex:0]substringToIndex:1]];
    NSArray *aList = [self.listOfContacts filteredArrayUsingPredicate:myPred];
    
    //---get the section of selected contact(in d-fault tableview)
    self.index = [NSIndexPath indexPathForRow:[aList indexOfObject:self.chosenContact]
                                    inSection:[self.listOfLetters indexOfObject:[[self.chosenContact.name substringFromIndex:0]substringToIndex:1]]];
    //---scroll to position of contact---
    [self.tableView scrollToRowAtIndexPath:self.index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}
//---scroll to top---
- (void)scrollToTop{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Interface orientation
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - User statuses
- (void) getStatuses{
    //Code for updating statuses
    [self sortList];
}

#pragma mark - Flags change
//---flags for not searching---
- (void)viewNotSearching{
    self.searchPressed=YES;
    [self.view endEditing:YES];
    self.isFiltered=NO;
}

#pragma mark - Dealloc
- (void)dealloc {
    [self.tableView release];
    [self.listOfContactsUnsorted release];
    [self.listOfContacts release];
    [self.listOfLetters release];
    [self.contactSection release];
    [self.filteredTableData release];
    [self.index release];
    [self.searchResult release];
    [self.searchBar release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super dealloc];
}

@end