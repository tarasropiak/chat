//
//  ChatViewController.m
//  Chat
//
//  Created by Administrator on 6/6/13.
//  Copyright (c) 2013 YuraKom. All rights reserved.
//

#import "ChatViewController.h"
#import "DAL.h"
#import "ChatCell.h"
#import "Message.h"
#import "SIPWrapper.h"
#import "SystemSIPMessage.h"

@interface ChatViewController ()
{
    // flags
    BOOL _keyboardIsShown;
    BOOL _dataUploaded;
    BOOL _chatViewRotated;
    BOOL _tableViewRedrawn;
}

// properties for adding messages to array
@property (nonatomic, retain) NSMutableArray *userMessages;
@property (nonatomic, retain) NSMutableArray *messageTime;

@end

@implementation ChatViewController

// constant for bottom bar hidding and showing
const float BOTTOM_BAR_HEIGHT = 49.0;
const float KEYBOARD_LANDSCAPE_WIDTH = 162.0;

// constants margins for cell resizing
const float FONT_SIZE = 17.0;
const float CELL_CONTENT_HEIGHT = 29.0;
const float CELL_NEXT_CONTENT_HEIGHT = 16.0;

// identifiers for cell
static NSString * const CellIdentifierBlue = @"MessageBlue";
static NSString * const CellIdentifierWhite = @"MessageWhite";
static NSString * const CellIdentifierBlueNext = @"MessageBlueNext";
static NSString * const CellIdentifierWhiteNext = @"MessageWhiteNext";

#pragma mark - Dealloc

// dealloc method
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:NSManagedObjectContextObjectsDidChangeNotification
                                                 object:[self.dataBaseManager contextForObseving]];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIKeyboardWillHideNotification
                                                 object:self.view.window];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIKeyboardWillShowNotification
                                                 object:self.view.window];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:self.view.window];
    [_messageTime release];
    [_userMessages release];
    [_currentSIPID release];
    [_tempMSG release];
    [_tableView release];
    [_textField release];
    [_sendButtonOutlet release];
    [super dealloc];
}

#pragma mark - Loading View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // sets view and tableview customised backgrounds
    self.view.backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f
                                                alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f
                                                      blue:0.9f alpha:1.0f];
    // sets separator to none
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // gesture recognizer for hidding keyboard when user touched display
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(keyboardEndEditing)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    // looks after database is something was changed there
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleDataChange:)
                                                name:NSManagedObjectContextObjectsDidChangeNotification
                                              object:[self.dataBaseManager contextForObseving]];

    // notifications about keyboardChatViewController.mm
    // looks after keyboard is it shown
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:self.view.window];
    
    // looks after keyboard is it hidden
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:self.view.window];

    // rotation notification
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(deviceOrientationChanged)
                                                name:UIDeviceOrientationDidChangeNotification
                                              object:self.view.window];
    _keyboardIsShown = NO;
    _dataUploaded = NO;
    _chatViewRotated = NO;
    _tableViewRedrawn = NO;                                                     
}

- (void)viewWillAppear:(BOOL)animated
{
    const float redrawnHeight = 338;
    
    // changes tableView, textField and sendButton locations
    CGRect tableViewFrame = CGRectMake(0, 0, 320, 368);
    CGRect textFieldFrame = CGRectMake(5, 332, 228, 30);
    CGRect sendButtonFrame = CGRectMake(241, 332, 73, 30);
    
    // begins animations
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // sets new frames
    if(self.tableView.frame.size.height == redrawnHeight)
    {
        [self.tableView setFrame:tableViewFrame];
    }
    [self.textField setFrame:textFieldFrame];
    [self.sendButtonOutlet setFrame:sendButtonFrame];
    
    [UIView commitAnimations];
}



#pragma mark - Handle Message Visualization

-(void)handleDataChange:(NSNotification *)notification
{
    // gets information about changes in database
    NSDictionary *userInfo = [notification userInfo];
    id messageChanger = [userInfo objectForKey:@"inserted"];
    
    // if something changed redraws the tableView
    if(messageChanger != nil)
    {
        [self.dataBaseManager readAllMessagesInConversationBetween:
                              [self.sessionProvider authorizedUser]
                                            andContact:self.currentSIPID];
        
        // upload last message from database after it was changed
        Message *lastMessage = [self.dataBaseManager
                                lastMessageBettwenAccountWithSipID:
                                [self.sessionProvider authorizedUser]
                                               andContactWithSipID:self.currentSIPID];
        [self.userMessages addObject:lastMessage];        
        // formats date and adds it to local array
        NSString *dateToChat = [self formatDateToAppropriateFormat];
        [self.messageTime addObject:dateToChat];
        
        // displays message on the screen
        [self whenSentOrReceivedMessageHasNotBeenDisplayedYet];
    }
}

#pragma mark - Keyboard Events

// actions when keyboard shows
- (void)keyboardWillShow:(NSNotification *)notification
{
    // when keyboard is showed just stop the function
    if(_keyboardIsShown)
    {
        return;
    }
    
    //actions with keyboard
    NSDictionary *userInfo = [notification userInfo];
    
    // gets keyboard size from user info
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]
                           CGRectValue].size;
    // keyboard show duration
    NSTimeInterval animDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]
                                   doubleValue];
    
    CGRect viewFrame;
    CGRect textFieldFrame;
    CGRect sendButtonFrame;
    
    if(!_chatViewRotated)
    {
        // resizes view when keyboard is shown
        viewFrame = self.view.frame;
        viewFrame.size.height -= ((keyboardSize.height) - BOTTOM_BAR_HEIGHT);
    
        // changes textFiedl and sendButton location when keyboard is shown
        textFieldFrame = self.textField.frame;
        textFieldFrame.origin.y -= ((keyboardSize.height) - BOTTOM_BAR_HEIGHT);
        sendButtonFrame = self.sendButtonOutlet.frame;
        sendButtonFrame.origin.y -= ((keyboardSize.height) - BOTTOM_BAR_HEIGHT);
    }
    else
    {
        // resizes when keyboard is shown in landscape mode
        viewFrame = self.view.frame;
        viewFrame.size.height -= KEYBOARD_LANDSCAPE_WIDTH;
        
        // changes textFiedl and sendButton location when keyboard is shown
        textFieldFrame = self.textField.frame;
        textFieldFrame.origin.y -= KEYBOARD_LANDSCAPE_WIDTH;
        sendButtonFrame = self.sendButtonOutlet.frame;
        sendButtonFrame.origin.y -= KEYBOARD_LANDSCAPE_WIDTH;
    }
    
    // begins animations

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];

    // sets keyboard duration
    [UIView setAnimationDuration:animDuration];
    
    // sets new frames
    [self.view setFrame:viewFrame];
    [self.textField setFrame:textFieldFrame];
    [self.sendButtonOutlet setFrame:sendButtonFrame];
    
    [UIView commitAnimations];
    
    [self scrollViewAfterAction];
    
    _keyboardIsShown = YES;
}

// actions when keyboard hides
- (void)keyboardWillHide:(NSNotification *)notification
{
    // actions with keyboard
    NSDictionary *userInfo = [notification userInfo];
    
    // gets keyboard size from user info
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]
                           CGRectValue].size;
    // keyboard hide duration
    NSTimeInterval animDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]
                                   doubleValue];
    

    CGRect viewFrame;
    CGRect textFieldFrame;
    CGRect sendButtonFrame;
    if(!_chatViewRotated)
    {
        // resizes view when keyboard is hidden
        viewFrame = self.view.frame;
        viewFrame.size.height += ((keyboardSize.height) - BOTTOM_BAR_HEIGHT);
    
        // changes textFiedl and sendButton location when keyboard is hidden
        textFieldFrame = self.textField.frame;
        textFieldFrame.origin.y += ((keyboardSize.height) - BOTTOM_BAR_HEIGHT);
        sendButtonFrame = self.sendButtonOutlet.frame;
        sendButtonFrame.origin.y += ((keyboardSize.height) - BOTTOM_BAR_HEIGHT);
    }
    else
    {
        // resizes when keyboard is hidden in landscape mode
        viewFrame = self.view.frame;
        viewFrame.size.height += KEYBOARD_LANDSCAPE_WIDTH;
    
        // changes textFiedl and sendButton location when keyboard is hidden
        textFieldFrame = self.textField.frame;
        textFieldFrame.origin.y += KEYBOARD_LANDSCAPE_WIDTH;
        sendButtonFrame = self.sendButtonOutlet.frame;
        sendButtonFrame.origin.y += KEYBOARD_LANDSCAPE_WIDTH;
    }

    // begins animations
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];

    // sets keyboard hide duration
    [UIView setAnimationDuration:animDuration];
    
    // sets new frames
    [self.view setFrame:viewFrame];
    [self.textField setFrame:textFieldFrame];
    [self.sendButtonOutlet setFrame:sendButtonFrame];
    
    [UIView commitAnimations];
    
    _keyboardIsShown = NO;
}

// hide keyboard after gesture
- (void)keyboardEndEditing
{
    [self.textField resignFirstResponder];
}

#pragma mark - Send Button

// send button
- (IBAction)sendButton
{
    
    
    
    // cheks if current message is not empty
    // if it isn't, sends message and adds it database
    if(![[self.textField text]isEqualToString:@""])
    {
        // sending message
        self.tempMSG = [[[MessageWrapper alloc] init]autorelease];
        
        // sends receiver's SIPID
        self.tempMSG.nameField = self.currentSIPID;
        
        // sends message text
        self.tempMSG.messageField = self.textField.text;
        
        NSString *senderID = [self.sessionProvider authorizedUser];
        NSSet *recipients = [[[NSSet alloc]initWithObjects:self.currentSIPID, nil]
                             autorelease];
        
        [self.dataBaseManager sendMessageFromSipID:senderID
                                          toSipIDs:recipients
                                          withText:self.textField.text];
        [self isMessageSystem:self.textField.text];
    }
    
    // after send was pressed does text field empty
    self.textField.text = @"";
}

#pragma mark - Data Source

// number of rows
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // uploads last messages from database
    if(!_dataUploaded)
    {
        // changes status of the messagses in the database
        [self.dataBaseManager readAllMessagesInConversationBetween:
         [self.sessionProvider authorizedUser] andContact:self.currentSIPID];
        
        // loads all objects from database
        self.userMessages = [NSMutableArray arrayWithArray:
                             [self.dataBaseManager firstThirtyMessagesBetweenSender:
                              [self.sessionProvider authorizedUser]
                                                                       andRecipient:
                              self.currentSIPID]];
        
        // retrieves not formated time from the array and formats it,
        // then adds it to another array
        for(int i = 0; i < [self.userMessages count]; i ++)
        {
            // formats date date and adds it to the local array
            NSDateFormatter *dateForm = [[[NSDateFormatter alloc]init]autorelease];
            dateForm.dateFormat = @"HH:mm";
            NSString *dateToChat = [dateForm stringFromDate:
                                    [[self.userMessages objectAtIndex:i]date]];
            
            [self.messageTime addObject:dateToChat];
        }
        
        _dataUploaded = YES;
        
        // scrolls tableView when messages were downloaded from database
        [self scrollViewAfterAction];
        
        return [self.userMessages count];
    }
    // if messages are uploaded adds new dynamical cell
    else
    {
        return [self.userMessages count];
    }
}

// cell creation
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // creates cell
    ChatCell *cell = [self customCellWithTableView:tableView
                                      andIndexPath:indexPath];
    
    return cell;
}

// height of a row
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // content width of the message label in the cell
    float cellContentWidth = 0.0;
    
    if(_chatViewRotated)
    {
        cellContentWidth = 365.0;
    }
    else
    {
        cellContentWidth = 205.0;
    }
    
    NSString *cellText = [[self.userMessages objectAtIndex:indexPath.row]text];
    
    // defines constraint for resizing
    CGSize constraint = CGSizeMake(cellContentWidth, 20000.0f);
    
    // sets constraint to the cell
    CGSize size = [cellText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]
                       constrainedToSize:constraint
                           lineBreakMode:NSLineBreakByWordWrapping];
    
    // calculate row height
    CGFloat rowHeight = [self calculateRowHeightAtIndexPath:indexPath
                                        withCellContentSize:size];
    
    return rowHeight;
}

#pragma mark - Extensions

// function for formatting time
- (NSString *)formatTime:(NSIndexPath *)indexPath
{
    const float time_const = 12.0;
    NSString *timePmOrAmString;
    
    // temp data for conditions
    NSString *tempTime = [self.messageTime objectAtIndex:indexPath.row];
    int time = [tempTime intValue];
    
    // adds AM appendix
    if(time < time_const)
    {
        timePmOrAmString = [NSString stringWithFormat:@"%@ %@",
                            tempTime, @"AM"];
    }
    // adds PM appendix
    if(time >= time_const)
    {
        timePmOrAmString = [NSString stringWithFormat:@"%@ %@",
                            tempTime, @"PM"];
    }
    
    return timePmOrAmString;
}

// displays message on the screen and rotates it to the last message
- (void)whenSentOrReceivedMessageHasNotBeenDisplayedYet
{
    [self.tableView reloadData];
    // scrolls table view
    [self scrollViewAfterAction];
}

// formats NSDate to appropriate format
- (NSString *)formatDateToAppropriateFormat
{
    // formater for date
    NSDateFormatter *dateForm =[[[NSDateFormatter alloc]init]autorelease];
    dateForm.dateFormat = @"HH:mm";
    
    NSString *dateToChat = [dateForm stringFromDate:
                            [[self.userMessages lastObject]date]];
    
    return dateToChat;
}

// scrolls view to the bottom when actions happend
- (void)scrollViewAfterAction
{
    if([self.userMessages count] > 0)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(0,0,0,0);
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.userMessages count] - 1)
                                                    inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

// calcucates row height
- (CGFloat)calculateRowHeightAtIndexPath:(NSIndexPath *)indexPath
                     withCellContentSize:(CGSize)size
{
    const CGFloat nextMessageRowHeight = 37.0;
    const CGFloat messageRowHeight = 50.0;

    CGFloat rowHeight;
    
    // current user sipID
    Contact *tempSenderCurrent = [[self.userMessages objectAtIndex:
                                   indexPath.row]sender];
    Contact *tempSenderPrevious = nil;
    if(indexPath.row >= 1)
    {
        tempSenderPrevious = [[self.userMessages objectAtIndex:
                               indexPath.row - 1]sender];
    }
    
    // checks accordingly to sipID; if gives white XIB and else gives blue
    if(![tempSenderCurrent.sipID isEqualToString:self.currentSIPID])
    {
        // checks what kind of white cell will be chosen
        // second message
        if(indexPath.row > 0 && ![tempSenderPrevious.sipID
                                  isEqualToString:self.currentSIPID])
        {
            // sets resized row height
            rowHeight = (size.height + CELL_NEXT_CONTENT_HEIGHT);
            
            // if row height was resized return new height else default height
            return MAX(rowHeight, nextMessageRowHeight);
        }
        // first message
        else
        {
            rowHeight = (size.height + CELL_CONTENT_HEIGHT);
            
            // if row height was resized return new height else default height
            return MAX(rowHeight, messageRowHeight);
        }
    }
    else
    {
        // checks what kind of blue cell will be chosen
        // second message
        if(indexPath.row > 0 && [tempSenderPrevious.sipID
                                 isEqualToString:self.currentSIPID])
        {
            // sets resized row height
            rowHeight = (size.height + CELL_NEXT_CONTENT_HEIGHT);
            
            // if row height was resized return new height else default height
            return MAX(rowHeight, nextMessageRowHeight);
        }
        // first message
        else
        {
            // sets resized row height
            rowHeight = (size.height + CELL_CONTENT_HEIGHT);
            
            // if row height was resized return new height else default height
            return MAX(rowHeight, messageRowHeight);
        }
    }
}

// customs and fills table view cell
- (ChatCell *)customCellWithTableView:(UITableView *)tableView
                         andIndexPath:(NSIndexPath *)indexPath
{
    // adds AM or PM appendix to date
    NSString *timePmOrAmCurrent = [self formatTime:indexPath];
    
    // current user sipID
    Contact *tempSenderCurrent = [[self.userMessages objectAtIndex:
                                   indexPath.row]sender];
    Contact *tempSenderPrevious = nil;
    if(indexPath.row >= 1)
    {
        tempSenderPrevious = [[self.userMessages objectAtIndex:
                               indexPath.row - 1]sender];
    }
    
    // cheks and chooses: if chooses white XIB else chooses blue XIB
    if(![tempSenderCurrent.sipID isEqualToString:self.currentSIPID])
    {
        // cheks what kind of white XIB will be
        // second message
        if(indexPath.row > 0 && ![tempSenderPrevious.sipID
                                  isEqualToString:self.currentSIPID])
        {
            ChatCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifierWhiteNext];
            
            if(cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ChatCell"
                                                     owner:self
                                                   options:nil]objectAtIndex:3];
            }
            
            // assigns text and date in the cell
            cell.messageLabel.text = [[self.userMessages
                                       objectAtIndex:indexPath.row]text];
            cell.timeLabel.text = timePmOrAmCurrent;
            
            return cell;
        }
        // first message
        else
        {
            ChatCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifierWhite];
            
            if(cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ChatCell"
                                                     owner:self
                                                   options:nil]objectAtIndex:1];
            }
            
            // assigns text and date in the cell
            cell.messageLabel.text = [[self.userMessages
                                       objectAtIndex:indexPath.row]text];
            cell.timeLabel.text = timePmOrAmCurrent;
            
            return cell;
        }
    }
    else
    {
        // cheks what kind of blue XIB will be
        // second message
        if(indexPath.row > 0 && [tempSenderPrevious.sipID
                                 isEqualToString:self.currentSIPID])
        {
            ChatCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifierBlueNext];
            
            if(cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ChatCell"
                                                     owner:self
                                                   options:nil]objectAtIndex:2];
            }
            
            // assigns text and date in the cell
            cell.messageLabel.text = [[self.userMessages
                                       objectAtIndex:indexPath.row]text];
            cell.timeLabel.text = timePmOrAmCurrent;
            
            return cell;
        }
        // first message
        else
        {
            ChatCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifierBlue];
            
            if(cell == nil)
            {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"ChatCell"
                                                     owner:self
                                                   options:nil]objectAtIndex:0];
            }
            
            // assigns text and date in the cell
            cell.messageLabel.text = [[self.userMessages
                                       objectAtIndex:indexPath.row]text];
            cell.timeLabel.text = timePmOrAmCurrent;
            
            return cell;
        }
    }
}

// handles redrawing of the view after rotation
- (void)deviceOrientationChanged
{    
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)
    UIDevice.currentDevice.orientation;
       
    // lendscape mode - left or right
    if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft ||
        UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight)
    {
        _chatViewRotated = YES;
        
        // hides tabBar
        [self hideOrShowTabBar:_chatViewRotated];
        
        // reloads tableView
        [self.tableView reloadData];
        [self.navigationItem setHidesBackButton:YES];
        // redraws the tableVeiw
        CGRect tableViewFrame;
        if(!_tableViewRedrawn)
        {
            tableViewFrame = CGRectMake(0, 30, 480, 146);        
        }
        
        // changes textField and SendButton locations
        CGRect textFieldFrame = CGRectMake(5, 265, 388, 30);
        CGRect sendButtonFrame = CGRectMake(400, 265, 73, 30);
        
        // begins animations
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        // sets new frames
        if(!_tableViewRedrawn)
        {
            [self.tableView setFrame:tableViewFrame];
        }
        [self.textField setFrame:textFieldFrame];
        [self.sendButtonOutlet setFrame:sendButtonFrame];

        [UIView commitAnimations];

        _tableViewRedrawn = YES;
    }
    // portrait mode
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        _chatViewRotated = NO;
        
        // shows tabBar
        [self hideOrShowTabBar:_chatViewRotated];
        
        // reloads tableView
        [self.tableView reloadData];
        [self.navigationItem setHidesBackButton:NO];
        // changes textField and sendButton locations
        CGRect textFieldFrame = CGRectMake(5, 376, 228, 30);
        CGRect sendButtonFrame = CGRectMake(241, 376, 73, 30);
        
        // begins animations
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        // sets new frames
        [self.textField setFrame:textFieldFrame];
        [self.sendButtonOutlet setFrame:sendButtonFrame];
        
        [UIView commitAnimations];
    
        _tableViewRedrawn = NO;
    }
}

// hides or shows tabBar
- (UIViewController *)hideOrShowTabBar:(BOOL)action
{
    self.hidesBottomBarWhenPushed = action;
    
    UIViewController *viewContr = [[[UIViewController alloc]init]autorelease];
    [self.navigationController pushViewController:viewContr animated:NO];
    [self.navigationController popToViewController:self animated:NO];
    
    return viewContr;
}

// hides keyboard before the rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self keyboardEndEditing];
}

// when back button pressed
- (void)viewWillDisappear:(BOOL)animated
{
    /*[self keyboardEndEditing];
    
    if(UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft ||
       UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight)
    {
        [self.tabBarDelegate actionWithBottomBarWhenBackButtonPressed];
    }*/
}

#pragma mark - Lazy instantiation

// overrided getter, which makes lazy instantiation
- (NSMutableArray *)userMessages
{
    if(!_userMessages)
    {
        _userMessages = [[NSMutableArray alloc]init];
        
        return _userMessages;
    }
    else
    {
        return _userMessages;
    }
}

// overrided getter, which makes lazy instantiation
- (NSMutableArray *)messageTime
{
    if(!_messageTime)
    {
        _messageTime = [[NSMutableArray alloc]init];
        
        return _messageTime;
    }
    else
    {
        return _messageTime;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat actualPosition = scrollView.contentOffset.y;
    if(actualPosition == -30)
    {
        NSLog(@"Hello world");
    }
    //CGFloat contentHeight = scrollView.contentSize.height - (someArbitraryNumber);
    //if (actualPosition >= contentHeight) {
        
        //[self.tableView reloadData];
    //}
}

/*- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    
}*/


-(void) isMessageSystem:(NSString *)text{

    
    int chosen= [self returnNumber:text];
    
    switch (chosen) {
        case 0:
        {
            MessageWrapper * temp  = [[MessageWrapper alloc] init];
            // sends current SIPID
            temp.urlField = self.currentSIPID;
            // sends message text
            temp.messageField = self.textField.text;
            // delegate
            [self.delegate  sendMessage:temp];
         break;
        }
        case -1:
        {
            break;
        
        }
        
        default:
            NSDate * sendTime = [[NSDate alloc] init];
            
            SystemSIPMessage *syssipm = [[SystemSIPMessage alloc] initAsStatusRequestTo:self.currentSIPID andType:chosen];
            syssipm.SSN= [sendTime timeIntervalSince1970];
            [self.delegate  sendMessage:syssipm];
            break;
    }
    
}

- (int) returnNumber:(NSString *) line
{
 
    
    
    
    
    
    if(line.length<12)
    {
        NSString *senderID = [self.sessionProvider authorizedUser];
        NSSet *recipients = [[NSSet alloc]initWithObjects:self.currentSIPID, nil];
        
        // NETWORK STATUSES
        
        if ([line isEqualToString:@"!#getns -v"]) {
           
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"SYSTEM :verbose network status request"];
            return GET_NET_STATUS_VERBOSE;
        }
        if ([line isEqualToString:@"!#getns"]) {
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"SYSTEM :network status  request"];
            return GET_NET_STATUS;
        }
      
         // PING
        if ([line isEqualToString:@"!#ping -v"]) {
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"SYSTEM :verbose ping request"];
            return GET_PING_VERBOSE;
        }
        if ([line isEqualToString:@"!#ping"]) {
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"SYSTEM :ping request"];
            return GET_PING;
        }
  
        // SOUL STATUSES
        if ([line isEqualToString:@"!#getss -v"]) {
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"SYSTEM :verbose soul status request"];
            return GET_SOUL_STATUS_VERBOSE;
        }
        if ([line isEqualToString:@"!#getss"]) {
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"SYSTEM :soul status request"];
            return GET_SOUL_STATUS;
        }
       
        if ([line isEqualToString:@"!#time"]) {
            
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"SYSTEM : curent time : "];
            return -1;
        }
        if ([line isEqualToString:@"!#info"]) {
            
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"Chat designed by LV-087"];
            return -1;
        }
        if ([line isEqualToString:@"!#help"]) {
            
            [self.dataBaseManager sendMessageFromSipID:senderID
                                              toSipIDs:recipients
                                              withText:@"List of comands:\
             \n !#help      \
             \n !#info      \
             \n !#getns     \
             \n !#getns -v  \
             \n !#getss     \
             \n !#getss -v  \
             \n !#ping      \
             \n !#ping -v"];
            return -1;
        }
    }
    return 0;
    
    
}

@end

