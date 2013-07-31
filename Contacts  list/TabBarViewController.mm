//
//  TabBarViewController.m
//  MyChat
//
//  Created by adminaccount on 6/26/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//
#import "TabBarViewController.h"
#import "ChatViewController.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "SystemSIPMessage.h"
@interface TabBarViewController ()<UITabBarControllerDelegate, SIPWrapperDelegate>
@property BOOL allowRotate;
@end

@implementation TabBarViewController
@synthesize sipDelegate = _sipDelegate;
@synthesize sessionProvider = _sessionProvider;
@synthesize dataBaseManager = _dataBaseManager;
@synthesize allowRotate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationController* nvc = [self.customizableViewControllers objectAtIndex:0];
    ContactsViewController *cvc = (ContactsViewController*)nvc.topViewController;
    cvc.sessionProvider = self.sessionProvider;
    cvc.dataBaseManager = self.dataBaseManager;
    cvc.delegate = self.sipDelegate;
    _wrapInTabVC.delegate = self;
    [self.wrapInTabVC enableMessageReceiver];
    int count = 5;
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d",count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) playSound {
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                                                                  pathForResource:[defaults objectForKey:@"sound"] ofType:@"wav"]];
    AVAudioPlayer *player  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:nil];
    [player setVolume:[[defaults objectForKey:@"loud"] floatValue]];
    [player play];
}

-(void)addNotification:(MessageWrapper *)message
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"Message: %@ From: %@", message.messageField, message.urlField];
    //[UIApplication sharedApplication].applicationIconBadgeNumber++;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

-(void) statusReplayRecieved:(SystemSIPMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
    NSString *contactSip = message.destination;
    NSString *status = message.body;
    int statusCode = -1;
    if([status isEqualToString:@"online"])
    {
        statusCode = 0;
    }
    if([status isEqualToString:@"busy"])
    {
        statusCode = 1;
    }
    if([status isEqualToString:@"don't disturb"])
    {
        statusCode = 2;
    }
    if([status isEqualToString:@"Don't disturb"])
    {
        statusCode = 3;
    }
    [self.dataBaseManager changeStatusOn:statusCode
                        inContactWithSip:contactSip];
    });
}

-(void) messageReceived:(MessageWrapper *)message
{
    [self playSound];
//    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    [self addNotification:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataBaseManager reciveMessageFrom:message.urlField
                                  WithText:message.messageField
                                 inAccount:[self.sessionProvider authorizedUser]];
        
    });
}

@end
