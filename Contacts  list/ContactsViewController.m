//  ContactsViewController.m
//  MyChat
//
//  Created by Administrator on 6/13/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import "ContactsViewController.h"
#import "ChatViewController.h"
#import "AddUserViewController.h"

@interface ContactsViewController ()
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property BOOL searchPressed;
@property (retain, nonatomic) Contact* chosenContact;
@property CGRect kbSize;
@property CGFloat initialTVHeight;
@property BOOL allowHighlight;
- (IBAction)cancelSrc:(id)sender;

@end

@implementation ContactsViewController

@synthesize listOfContacts;
@synthesize listOfLetters;
@synthesize listOfContactsUnsorted;
@synthesize searchPressed=_searchPressed;
@synthesize searchBar=_searchBar;
@synthesize filteredTableData;
@synthesize isFiltered;
@synthesize tableView=_tableView;
@synthesize index;
@synthesize chosenContact;
@synthesize delegate = _delegate;
@synthesize sessionProvider = _sessionProvider;
@synthesize dataBaseManager = _dataBaseManager;
@synthesize chat;

const int ROW_HEIGHT = 70;

- (void)viewDidLoad
{
    [super viewDidLoad];
//Adding observer for keyboard showing
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
//Config search button up right
    self.navigationItem.title=@"Contacts";
    UIButton *searchBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setImage:[UIImage imageNamed:@"magnify2.png"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchPushed) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setFrame:CGRectMake(0, 0, 32, 32)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
//Config add button up left
    UIButton *addContact =  [UIButton buttonWithType:UIButtonTypeCustom];
    [addContact setImage:[UIImage imageNamed:@"add2.png"] forState:UIControlStateNormal];
    [addContact addTarget:self action:@selector(addPushed) forControlEvents:UIControlEventTouchUpInside];
    [addContact setFrame:CGRectMake(0, 0, 32, 32)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addContact];
//Gesture recognizer for ending search on tap
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.tableView addGestureRecognizer:tap];
// Do any additional setup after loading the view, typically from a nib.
//---initialize flags---
    [self viewNotSearching];
//—--initialize the arrays and adding elements—--
    listOfLetters = [[NSMutableArray alloc] init];
    listOfContacts =[[NSMutableArray alloc] init];
//---used for storing the search result---
    self.searchResult = [[NSMutableArray alloc] init];
//---sort method---
    [self sortList];
}


//---keyboard show event---
- (void) keyboardDidShow:(NSNotification *)nsNotification {
        self.initialTVHeight = self.tableView.frame.size.height;
    
        CGRect initialFrame = [[[nsNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect convertedFrame = [self.view convertRect:initialFrame fromView:nil];
        CGRect tvFrame = self.tableView.frame;
        [UIView beginAnimations:@"TableViewDown" context:NULL];
        [UIView setAnimationDuration:0.15f];
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
    [UIView setAnimationDuration:0.3f];
    self.tableView.frame = tvFrame;
    [UIView commitAnimations];
}
//---search button push event---
- (void) searchPushed {
    if(!_searchPressed)
    {
        NSLog(@"Not searching");
        [self viewNotSearching];
    }
    else
    {
        [_searchBar becomeFirstResponder];
        NSLog(@"Searching");
        if(![self.searchBar.text isEqualToString:@""]){
            [self searchBar:searchBar textDidChange:self.searchBar.text];
        }
        self.searchPressed=NO;
    }
    [self.tableView reloadSectionIndexTitles];
    [self.tableView reloadData];
}

//Number of sections which actually have contacts in + deleting letters which don't have contacts
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //---get first letters of contact list without dupes
    NSMutableSet *firstCharacters = [NSMutableSet setWithCapacity:0];
    for( NSString *string in [listOfContacts valueForKey:@"name"] ){
        [firstCharacters addObject:[string substringToIndex:1]];
    }
    //---sort list of letters---
    NSArray *uniquearray = [[firstCharacters allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    //---saving in property---
    listOfLetters= [uniquearray mutableCopy];
    if(!isFiltered){
        return [listOfLetters count];
    }
    else
        return 1;
}

//—--set the number of rows in each existing section—--
-(NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{   if(!isFiltered){
//---check if first letter of contact matches section's letter with the help of predicate
    NSPredicate *myPred = [NSPredicate predicateWithFormat:
                           @"name beginswith[cd] %@",[listOfLetters objectAtIndex:section]];
    NSArray *contactsInSection = [listOfContacts filteredArrayUsingPredicate:myPred];
    return [contactsInSection count];
}
else
    return [filteredTableData count];
}

//---get the letter as the section header---
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(!isFiltered){
        return [listOfLetters objectAtIndex:section];
    }
    else
        return nil;
}

//---adding indexes---
- (NSMutableArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(_searchPressed){
        return listOfLetters;
    }
    else
        return nil;
}

//---height of cells---
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

//---display contacts---
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSMutableArray *contactSection;
    NSString *letter;
//—-try to get a reusable cell—-
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
//---accessory type---
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = [[ UIImageView alloc ]
                            initWithImage:[UIImage imageNamed:@"red_circle.png" ]];
//---highlight color---
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//---set background image as bg and filler---
    cell.imageView.image = [UIImage imageNamed:@"spacer.png"];
    UIImageView *customImageView = [[UIImageView alloc] initWithFrame:(CGRect){.size={cell.imageView.image.size.width, ROW_HEIGHT}}];
    UIImage *image;
    if(!self.isFiltered){
        contactSection = [[NSMutableArray alloc] init];
        //---get the letter---
        letter = [listOfLetters objectAtIndex:[indexPath section]];
        //---get the list of contact for that letter---
        for(int i=0;i<[listOfContacts count];i++){
            if ([[[[[listOfContacts objectAtIndex:i]name]substringFromIndex:0]substringToIndex:1] isEqualToString: letter]){
                [contactSection addObject:[listOfContacts objectAtIndex:i]];
            }
        }
        //---get the particular contact based on that row---
        cell.textLabel.text = [[contactSection objectAtIndex:[indexPath row]]name];
        cell.detailTextLabel.text = [[contactSection objectAtIndex:[indexPath row]]sipID];
        image = [UIImage imageWithContentsOfFile:[[contactSection objectAtIndex:[indexPath row]]pictureID]];
    }
    else{
        cell.textLabel.text= [[filteredTableData objectAtIndex:[indexPath row]]name];
        cell.detailTextLabel.text = [[filteredTableData objectAtIndex:[indexPath row]]sipID];
        image = [UIImage imageWithContentsOfFile:[[filteredTableData objectAtIndex:[indexPath row]]pictureID]];
    }
    //---adding custom imageview for equal size of images---
    customImageView.image=image;
    [cell.contentView addSubview:customImageView];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.clipsToBounds = YES;
    return cell;
}

//---method for sorting list
- (void) sortList{
    listOfContactsUnsorted = [[self.dataBaseManager
                             contactsOfAccountWithSipID:
                             [self.sessionProvider authorizedUser]]
                             mutableCopy];
    //---creating temp array for sorting---
    NSArray* sortedList;
    //---sorting with criteria using comparator---
    sortedList = [listOfContactsUnsorted sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Contact*)a name];
        NSString *second = [(Contact*)b name];
        return [first compare:second];
    }];
    //---convertion to mutable array from temp array---
    listOfContacts=[sortedList mutableCopy];
    [self.tableView reloadData];
               
}
//---message on clicking---
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
//---search with PREDICATE in array of objects by object.name----- 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name like[cd] %@) AND (sipID like[cd] %@)",
                              selectedCell.textLabel.text, selectedCell.detailTextLabel.text];
    NSArray *filtered = [listOfContacts filteredArrayUsingPredicate:predicate];
//---assigning selected contact to property for sending to other views
    chosenContact= [filtered objectAtIndex:0];
    if(!_searchPressed){
        [self viewNotSearching];
        [self.tableView reloadData];
    }
    [self scrollAtPosition];
    self.searchBar.text=@"";
    [self performSegueWithIdentifier:@"Details" sender:self];
}

//---prepare data for passing in another views---
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ChatSegue"])
    {
        ChatViewController *_chat = segue.destinationViewController;
        _chat.delegate = self.delegate;
        _chat.title=self.chosenContact.name;
        _chat.currentSIPID=self.chosenContact.sipID;
        _chat.dataBaseManager = self.dataBaseManager;
        _chat.sessionProvider = self.sessionProvider;
        self.allowHighlight = YES;
    }

    else
        if([segue.identifier isEqualToString:@"AddContact"])
            {
                AddUserViewController *tmpAddUserControllerPtr = segue.destinationViewController;
                tmpAddUserControllerPtr.dataBaseManager = self.dataBaseManager;
                tmpAddUserControllerPtr.sessionProvider = self.sessionProvider;
                
            }
            else
                if([segue.identifier isEqualToString:@"Details"])
                {
                    DetailsViewController *tmpDetailsViewControllerPtr = segue.destinationViewController;
                    tmpDetailsViewControllerPtr.dataBaseManager = self.dataBaseManager;
                    tmpDetailsViewControllerPtr.sessionProvider = self.sessionProvider;
                    tmpDetailsViewControllerPtr.chosenContact = self.chosenContact;
                    tmpDetailsViewControllerPtr.delegate = self.delegate;
                    self.allowHighlight = YES;
                }
}

//---add contact event(Add New Contact)---
- (void) addPushed {
    if(!_searchPressed){
        [self viewNotSearching];
        [self.tableView reloadData];
    }
    [self performSegueWithIdentifier:@"AddContact" sender:self];
    self.searchBar.text=@"";
}

- (IBAction)cancelSrc:(id)sender {
    [self viewNotSearching];
    [self.tableView reloadSectionIndexTitles];
    [self.tableView reloadData];
}

//---search method---
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        isFiltered = NO;
    }
    else
    {
        isFiltered = YES;
        filteredTableData = [[NSMutableArray alloc] init];
        Contact* contact;
        for (contact in listOfContacts)
        {
            NSRange nameRange = [contact.name rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [contact.sipID rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [filteredTableData addObject:contact];
            }
        }
    }
    
    [self.tableView reloadData];
}

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
        if(!_searchPressed){
            [self viewNotSearching];
            [self.tableView reloadSectionIndexTitles];
            [self.tableView reloadData];
        }
    }
}

- (IBAction)chatSegue:(UIStoryboardSegue *)segue {
    chat=YES;
}

//---scroll to previous selected cell---
- (void)scrollAtPosition{
    //---get the row index of selected contact(in d-fault tableview) with the help of predicate---
    NSPredicate *myPred = [NSPredicate predicateWithFormat:
                           @"name beginswith[cd] %@",[[chosenContact.name substringFromIndex:0]substringToIndex:1]];
    NSArray *aList = [listOfContacts filteredArrayUsingPredicate:myPred];
    
    //---get the section of selected contact(in d-fault tableview)
    self.index = [NSIndexPath indexPathForRow:[aList indexOfObject:chosenContact]
                               inSection:[listOfLetters indexOfObject:[[chosenContact.name substringFromIndex:0]substringToIndex:1]]];
    //---scroll to position of contact---
    [_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    //---highlight cell scrolled to---
    [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

//---flags for not searching---
- (void)viewNotSearching{
    self.searchPressed=YES;
    [self.view endEditing:YES];
    isFiltered=NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void) viewDidAppear:(BOOL)animated
{
    if(chat){
        chat=NO;
        [self performSegueWithIdentifier:@"ChatSegue" sender:self];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    //---preparations and selection of row before view appears---
    [self shouldAutorotate];
       [self sortList];
        if([listOfContacts indexOfObject:chosenContact]!=NSNotFound){
            [self scrollAtPosition];
            [self performSelector:@selector(deselect) withObject:self afterDelay:0.5];
        }
        self.allowHighlight=NO;
}

-(void) deselect{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(!self.allowHighlight){
        if(chosenContact)
            chosenContact=nil;
    }
}

- (void)didReceiveMemoryWarning
{
//---dispose of any resources that can be recreated---
    [super didReceiveMemoryWarning];
    [listOfContacts release];
    [listOfLetters release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)dealloc {
    [super dealloc];
}

@end