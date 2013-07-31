//
//  DetailsViewController.h
//  MyChat
//
//  Created by Administrator on 6/13/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "sessionProvider.h"
#import "DataBaseManager.h"
#import "SipClientDelegate.h"

@interface DetailsViewController: UIViewController

@property (retain, nonatomic) id<SipClientDelegate> delegate;
@property (nonatomic, retain) id<sessionProvider> sessionProvider;
@property (nonatomic, retain) id<DataBaseManager> dataBaseManager;
@property (retain, nonatomic) Contact* chosenContact;
@end



