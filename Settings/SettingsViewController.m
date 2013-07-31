//
//  SettingsViewController.m
//  SIPPhone
//
//  Created by Administrator on 7/5/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SettingsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SettingsViewController () <AVAudioPlayerDelegate>

@end

@implementation SettingsViewController
NSArray *tableData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //general settings
    self.view.backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f];

    tableData = [[NSArray alloc] initWithObjects:@"beep", @"wind", @"coin_drop", nil];

    
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //save name of sound
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[tableData objectAtIndex:indexPath.row] forKey:@"sound"];
    [defaults synchronize];
    //play sound
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                                                                  pathForResource:[defaults objectForKey:@"sound"] ofType:@"wav"]];
    AVAudioPlayer *click  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:nil];
   
    [click setVolume:self.loudSlider.value/10];
    [click play];
}

//settings for cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"Iconsound.png"];
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([cell.textLabel.text isEqual:[defaults objectForKey:@"sound"]]==YES)
        {
            [tableView
             selectRowAtIndexPath:indexPath
             animated:TRUE
             scrollPosition:UITableViewScrollPositionNone
             ];
        
            [[tableView delegate]
             tableView:tableView
             didSelectRowAtIndexPath:indexPath
             ];
        
        }

    
    return cell;
}

//change high of table cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 30;
}

 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    [super dealloc];
}
 


@end
