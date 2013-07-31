//
//  ChatCell.h
//  Chat
//
//  Created by Administrator on 6/12/13.
//  Copyright (c) 2013 YuraKom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

// property label outlet for cell
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
// property label outlet for time
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@end
