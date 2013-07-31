//
//  ChatCell.m
//  Chat
//
//  Created by Administrator on 6/12/13.
//  Copyright (c) 2013 YuraKom. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

@synthesize messageLabel = _messageLabel;
@synthesize timeLabel = _timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        //Initialize your cell...
    }
    
    return self;
}

// add some new setting to totally initialized things
- (void)awakeFromNib
{
    // sets message label's components programatically
    self.messageLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.messageLabel];
    
    // sets time label's components programatically
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor lightGrayColor];
    self.timeLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self.contentView addSubview:self.timeLabel];
}

// dealloc method
- (void)dealloc
{
    [_timeLabel release];
    [_messageLabel release];
    [super dealloc];
}

@end
