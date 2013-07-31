//
//  ChatViewController.h
//  Chat
//
//  Created by Administrator on 6/6/13.
//  Copyright (c) 2013 YuraKom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SipClientDelegate.h"
#import "DataBaseManager.h"
#import "MessageWrapper.h"
#import "sessionProvider.h"

@protocol HideBottomBarWhenChatViewRotated <NSObject>

//- (void)actionWithBottomBarWhenBackButtonPressed;

@end

@interface ChatViewController : UIViewController <UITableViewDataSource,
                                                  UITableViewDelegate>

// outlets
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UIButton *sendButtonOutlet;

// delegates
@property (nonatomic, assign) id <SipClientDelegate> delegate;
@property (nonatomic, assign) id <DataBaseManager> dataBaseManager;
@property (nonatomic, assign) id <sessionProvider> sessionProvider;
@property (nonatomic, assign) id <HideBottomBarWhenChatViewRotated> tabBarDelegate;

// message property
@property (nonatomic, retain) MessageWrapper *tempMSG;
// returns receiver's SIPID
@property (nonatomic, retain) NSString* currentSIPID;

// send button
- (IBAction)sendButton;

@end
