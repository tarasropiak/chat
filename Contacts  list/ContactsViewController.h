//
//  ContactsViewController.h
//  MyChat
//
//  Created by Administrator on 6/13/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SipClientDelegate.h"
#import "sessionProvider.h"
#import "DAL.h"
#import "DataBaseManager.h"
#import "DetailsViewController.h"

@interface ContactsViewController : UIViewController <UISearchBarDelegate>
@property (assign, nonatomic) id<SipClientDelegate> delegate;
@property (assign, nonatomic) id<sessionProvider> sessionProvider;
@property (assign, nonatomic) id<DataBaseManager> dataBaseManager;
@property BOOL chat;
@end
