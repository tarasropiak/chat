//
//  TabBarViewController.h
//  MyChat
//
//  Created by adminaccount on 6/26/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIPWrapper.h"
#import "ContactsViewController.h"
#import "ConversationsViewController.h"
#import "SipClientDelegate.h"
#import "sessionProvider.h"
#import "DataBaseManager.h"
#import "ChatViewController.h"

@interface TabBarViewController : UITabBarController
<HideBottomBarWhenChatViewRotated>

@property (nonatomic, retain) SIPWrapper* wrapInTabVC;
@property (nonatomic,assign) id <SipClientDelegate> sipDelegate;
@property (nonatomic, assign) id <sessionProvider> sessionProvider;
@property (nonatomic, assign) id <DataBaseManager> dataBaseManager;
@end
