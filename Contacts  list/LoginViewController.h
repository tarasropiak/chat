//
//  LoginViewController.h
//  Login
//
//  Created by Administrator on 6/3/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarViewController.h"
#import "SipClientDelegate.h"
#import "sessionProvider.h"
#import "DataBaseManager.h"
#import "SIPWrapperRegistrationDelegat.h"
#import "DAL.h"
@interface LoginViewController : UIViewController<SipClientDelegate,sessionProvider,SIPWrapperErrorsDelegat>
-(IBAction)didLogOutPressed:(UIStoryboardSegue *)segue;


@end
