//
//  ConversationsViewController.h
//  IM
//
//  Created by Aleksander on 03.06.13.
//  Copyright (c) 2013 Aleksander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarViewController.h"
#import "DataBaseManager.h"
#import "sessionProvider.h"
#import "Conversation+Managment.h"
#import "ChatViewController.h"
#import "SipClientDelegate.h"

@interface ConversationsViewController : UIViewController
<UITableViewDataSource>
@property (nonatomic) int countOfUnreadMessages;
@property (retain, nonatomic) IBOutlet UITableView *table;
@property (retain, nonatomic) NSArray *conversationsOfCurrentAccount;
@end
