//
//  SoundsViewController.m
//  SIPPhone
//
//  Created by Administrator on 7/17/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SoundsViewController.h"
#import "AddUserViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaToolbox/MediaToolbox.h>
@interface SoundsViewController ()<MPMediaPickerControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SoundsViewController
NSArray *tableData;
BOOL _playSound;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _playSound=NO;
    tableData = [[NSArray alloc] initWithObjects:@"beep",
                 @"beat",
                 @"check",
                 @"coin_drop",
                 @"close",
                 @"comic",
                 @"electricity",
                 @"melody",
                 @"phone_connect",
                 @"phone_check",
                 @"signal",
                 @"strange",
                 @"typewriter_key",
                 @"water_droplet",
                 @"wind",
                 nil];
   /* UIButton *addSound =  [UIButton buttonWithType:UIButtonTypeCustom];
    [addSound setImage:[UIImage imageNamed:@"add2.png"] forState:UIControlStateNormal];
    [addSound addTarget:self action:@selector(addPushed) forControlEvents:UIControlEventTouchUpInside];
    [addSound setFrame:CGRectMake(0, 0, 32, 32)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addSound];*/
}

/*- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        [musicPlayer play];
    }
    [self dismissModalViewControllerAnimated: YES];
}*/
/*- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissModalViewControllerAnimated: YES];
}

- (void) addPushed {
    
    MPMediaPickerController *picker =[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    //picker.delegate = self;
    picker.allowsPickingMultipleItems= NO;
    picker.prompt = NSLocalizedString (@"Select any song from the list", @"Prompt to user to choose some songs to play");
    
   // [self presentModalViewController: picker animated: YES];
    @try{
    [self presentViewController:picker animated:YES completion:nil];
   // [self presentViewController: picker animated: YES];
    }
    @catch (NSException *exception)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops!",@"Error title")
                                    message:NSLocalizedString(@"The music library is not available.",@"Error message when MPMediaPickerController fails to load")
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"prepare for segue" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    [self dismissModalViewControllerAnimated: YES];
    NSMutableArray* someMutableArray = [mediaItemCollection mutableCopy];
}*/

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //save name of sound
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[tableData objectAtIndex:indexPath.row] forKey:@"sound"];
    [defaults synchronize];
    //play sound
    if(_playSound)
    {
        NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                   pathForResource:[defaults objectForKey:@"sound"] ofType:@"wav"]];
        AVAudioPlayer *click  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:nil];
        [click setVolume:[[defaults objectForKey:@"loud"] floatValue]];
        [click play];
    }
        _playSound = YES;
}

//settings for cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"Iconsound.png"];
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([cell.textLabel.text isEqual:[defaults objectForKey:@"sound"]] == YES)
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//---Orientation---
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
@end
