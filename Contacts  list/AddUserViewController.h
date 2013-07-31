//
//  AddUserViewController.h
//  MyChat
//
//  Created by Administrator on 6/25/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sessionProvider.h"
#import "DataBaseManager.h"
@interface AddUserViewController : UIViewController

@property (assign, nonatomic) id<sessionProvider> sessionProvider;
@property (assign, nonatomic) id<DataBaseManager> dataBaseManager;
@end
