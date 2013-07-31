//
//  SettingViewController.m
//  SIPPhone
//
//  Created by Administrator on 7/16/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "SettingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface SettingViewController ()
@property (retain, nonatomic) IBOutlet UISwitch *autolLogValue;
@property (retain, nonatomic) IBOutlet UILabel *timeSliderLabel;
@property (retain, nonatomic) IBOutlet UISlider *timeSliderVal;
@property (retain, nonatomic) IBOutlet UILabel *soundNameLabel;
@property (retain, nonatomic) IBOutlet UISlider *loudSliderValue;
@end

@implementation SettingViewController
BOOL _playSound;

- (void)viewDidLoad {
    [super viewDidLoad];
    //autolog
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.autolLogValue.on = [[defaults objectForKey:@"autolog"] boolValue];
    //time settings initialize
    self.timeSliderVal.minimumValue = 0.0;
    self.timeSliderVal.maximumValue = 10.0;
    self.timeSliderLabel.text = @"Exit after closing program";
    self.timeSliderVal.value = [[defaults objectForKey:@"time"] floatValue];
	[self switchTime];
    //sound
    _playSound = NO;
    self.soundNameLabel.text = [[defaults objectForKey:@"sound"] stringByAppendingString:@".wav"];
    self.loudSliderValue.minimumValue = 0.0;
    self.loudSliderValue.maximumValue = 10.0;
    self.loudSliderValue.value = [[defaults objectForKey:@"loud"] floatValue];
    _playSound = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.soundNameLabel.text = [[defaults objectForKey:@"sound"] stringByAppendingString:@".wav"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)autoLoginChanged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(self.autolLogValue.on)
    {
        [defaults setObject:@"YES" forKey:@"autolog"];
        [defaults setObject:[defaults objectForKey:@"thisaccount"] forKey:@"autoaccount"];
        [defaults setObject:[defaults objectForKey:@"thispasswor"] forKey:@"autopasswor"];
        [defaults synchronize];
    }
    else
    {
        [defaults setObject:@"NO" forKey:@"autolog"];
        [defaults synchronize];
    }
}

//timeslider moved
- (IBAction)sliderMoved:(id)sender {
    [self switchTime];
}

- (void)switchTime {
    int sliderValue = self.timeSliderVal.value;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (sliderValue) {
        case 1:
            self.timeSliderLabel.text = @"Exit after 30 seconds";
            [defaults setInteger:30 forKey:@"timeSeconds"];
            break;
        case 2:
            self.timeSliderLabel.text = @"Exit after 1 minute";
            [defaults setInteger:60 forKey:@"timeSeconds"];
            break;
        case 3:
            self.timeSliderLabel.text = @"Exit after 5 minutes";
            [defaults setInteger:300 forKey:@"timeSeconds"];
            break;
        case 4:
            self.timeSliderLabel.text = @"Exit after 10 minutes";
            [defaults setInteger:600 forKey:@"timeSeconds"];
            break;
        case 5:
            self.timeSliderLabel.text = @"Exit after 20 minutes";
            [defaults setInteger:1200 forKey:@"timeSeconds"];
            break;
        case 6:
            self.timeSliderLabel.text = @"Exit after 30 minutes";
            [defaults setInteger:1800 forKey:@"timeSeconds"];
            break;
        case 7:
            self.timeSliderLabel.text = @"Exit after 1 hour";
            [defaults setInteger:3600 forKey:@"timeSeconds"];
            break;
        case 8:
            self.timeSliderLabel.text = @"Exit after 2 hours";
            [defaults setInteger:7200 forKey:@"timeSeconds"];
            break;
        case 9:
            self.timeSliderLabel.text = @"Exit after 3 hours";
            [defaults setInteger:10800 forKey:@"timeSeconds"];
            break;
        case 10:
            self.timeSliderLabel.text = @"Never exit program";
            [defaults setInteger:2 forKey:@"timeSeconds"];
            break;
        default: self.timeSliderLabel.text = @"Exit program after closing";
            [defaults setInteger:0 forKey:@"timeSeconds"];
            break;
    }
    
    
    [defaults setFloat:self.timeSliderVal.value forKey:@"time"];
    [defaults synchronize];
}

- (IBAction)loudSliderMoved:(id)sender {
     if(_playSound)
     {
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                    pathForResource:[defaults objectForKey:@"sound"] ofType:@"wav"]];
         AVAudioPlayer *click = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:nil];
         [click setVolume:self.loudSliderValue.value / 10];
         [click play];
         [defaults setInteger:self.loudSliderValue.value forKey:@"loud"];
         [defaults synchronize];
         [self.loudSliderValue addTarget:self action:@selector(dragEndedForSlider:)
                        forControlEvents:UIControlEventEditingDidEnd];
     }
}

//---Orientation---
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_autolLogValue release];
    [_timeSliderLabel release];
    [_timeSliderVal release];
    [_soundNameLabel release];
    [_loudSliderValue release];
    [super dealloc];
}
@end
