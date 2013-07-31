//
//  SettingsViewController.h
//  SIPPhone
//
//  Created by Administrator on 7/5/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SipClientDelegate.h"
#import "sessionProvider.h"
#import "DataBaseManager.h"
#import "SIPWrapperRegistrationDelegat.h"
/*@interface SettingsViewController : UIViewController <
                                                UITableViewDataSource,
                                                UITableViewDelegate,
                                                SipClientDelegate,
                                                DataBaseManager,
                                                sessionProvider,
                                                SIPWrapperRegistrationDelegat>*/
@interface SettingsViewController : UIViewController < UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *soundLabel;
@property (nonatomic, retain) NSMutableArray *listOfSounds;
@property (nonatomic, retain) NSMutableArray *listOfSoundsSorted;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UILabel *loudLabel;
@property (retain, nonatomic) IBOutlet UISlider *loudSlider;
@property (retain, nonatomic) IBOutlet UISlider *loudSliderValue;

@end

