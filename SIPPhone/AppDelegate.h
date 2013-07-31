//
//  AppDelegate.h
//  SIPPhone
//
//  Created by Andriy Mykhaylyshyn on 6/4/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAL.h"
#import "DataBaseManager.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, DataBaseManager>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) DAL *dataAccessLayer;
@end
