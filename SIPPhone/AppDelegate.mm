//
//  AppDelegate.m
//  SIPPhone
//
//  Created by Andriy Mykhaylyshyn on 6/4/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "AppDelegate.h"
#import "DAL.h"
#import "SipClientDelegate.h"
#import "LoginViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate()
@property (retain, nonatomic) SIPWrapper *wrapInLogin;
@end

@implementation AppDelegate
NSTimer *timer;
int currSeconds;

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
    self.dataAccessLayer = [[DAL alloc]init];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)start {
    timer=[[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES] retain]; 
}

- (void)timerFired {
    NSLog(@"timer");
    NSLog(@"%i",currSeconds);
    if(currSeconds>=0)
    {
        if(currSeconds>0) {
            currSeconds-=1;
        }
        else {
            [self playSoundWithName:@"signIOut" andType:@"mp3"];
            currSeconds-=1;
        }
    }
    else
    {
        [timer invalidate];
        timer = nil;
        NSLog(@"end of time/timer release");
        [self.wrapInLogin unregister];
        [self.wrapInLogin stopClient];
        exit(0);
    }
}

-(void) playSoundWithName: (NSString*) soundName
                  andType:(NSString*) soundType {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                                                                  pathForResource:soundName ofType:soundType]];
    AVAudioPlayer *click  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:nil];
    [click setVolume:[defaults floatForKey:@"loud"]];
    [click play];
    NSLog(@"ifhj;aeriomub;soyum;bslruys");
}

//when program closed
- (void)applicationDidEnterBackground:(UIApplication *)application {
     NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    UIApplication*    app = [UIApplication sharedApplication];

    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:nil];
//    dispatch_block_t expirationHandler;
//    expirationHandler = ^{
//        [app endBackgroundTask:bgTask];
//    };
    currSeconds = [defaults integerForKey:@"timeSeconds"];
    NSLog(@"%i",currSeconds);
    if(currSeconds != 2)
    {
        [self start];//timer start
        NSLog(@"back/timer create");
    }    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyApplicationEntersBackground" object:self]; 
    }); 
}

//application become active
- (void)applicationWillEnterForeground:(UIApplication *)application {
    int i=[timer retainCount];
    NSLog(@"retaincount:");
    NSLog(@"%i",i);
    if([timer retainCount]>0)
    {
        [timer invalidate];
        timer = nil;
        NSLog(@"open/timer release");
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

-(NSArray*)firstThirtyMessagesBetweenSender:(NSString*) senderSip
                               andRecipient:(NSString*)recipientSip
{
    return [self.dataAccessLayer conversationBettwenAccountWithSipID:senderSip
                                                 andContactWithSipID:recipientSip];
}

-(void) sendMessageFromSipID:(NSString*) _senderID
                    toSipIDs:(NSSet*)_recipintsSipIDs
                    withText:(NSString*)_text
{
    [self.dataAccessLayer sendMessageFromSipID: _senderID
                                      toSipIDs:_recipintsSipIDs
                                      withText:_text];
}

-(NSManagedObjectContext*)contextForObseving
{
    return self.dataAccessLayer.managedObjectContext;
}

-(void) reciveMessageFrom:(NSString *)senderSip
                 WithText:(NSString *)text
                inAccount:(NSString *)recipentSip
{
    [self.dataAccessLayer  reciveMessageFrom:senderSip
                                    WithText:text
                                   inAccount:recipentSip];
}

-(Message*)lastMessageBettwenAccountWithSipID:(NSString*)accountSIP
                          andContactWithSipID:(NSString*)contactSip
{
    return [self.dataAccessLayer lastMessageBettwenAccountWithSipID:accountSIP
                                                andContactWithSipID:contactSip];
}
-(void)deleteContactWithsSipID:(NSString *)sipID
           fromAcountWithSipID:(NSString *)acountSIP
{
    [self.dataAccessLayer deleteContactWithsSipID:sipID
                              fromAcountWithSipID:acountSIP];
}

-(void) updateNameWith:(NSString*)newName
            andPicture:(NSString*)imagePath
    inContactWithSipID:(NSString*)contactSIP
    ofAccountWithSipID:(NSString*)accountSIP
{
    [self.dataAccessLayer  updateNameWith:newName
                               andPicture:imagePath
                       inContactWithSipID:contactSIP
                       ofAccountWithSipID:accountSIP];
}

-(NSArray*) allConversationsOfAccountWithSipID:(NSString*)sipID
{
    return [self.dataAccessLayer allConversationsOfAccountWithSipID:sipID];
}

-(void) readAllMessagesInConversationBetween:(NSString*)accountSipID
                                  andContact:(NSString*)contactSIP
{
    [self.dataAccessLayer readAllMessagesInConversationBetween:accountSipID
                                                    andContact:contactSIP];
}

-(Account*) accountWithSipID:(NSString*)sipId
{
    return [self.dataAccessLayer accountWithSipID:sipId];
}

-(void) changeStatusOn:(int)status inContactWithSip:(NSString*)sip
{
    [self.dataAccessLayer changeStatusOn:status
                        inContactWithSip:sip];
}

-(NSArray*)contactsOfAccountWithSipID:(NSString*)sipID
{
    return [self.dataAccessLayer contactsOfAccountWithSipID:sipID];
}

- (void) addContactWithName:(NSString*)name
                      sipID:(NSString*)sipID
                  pictureID:(NSString*)picID
          toAcountWithSipID:(NSString*)acountSIP
{
    [self.dataAccessLayer addContactWithName:name
                                       sipID:sipID
                                   pictureID:picID
                           toAcountWithSipID:acountSIP];
}

- (void)registerAccountWithName:(NSString *)name
                          sipID:(NSString *)sipID
                       password:(NSString*)password
                        imageID:(NSString*)imageID
{
    [self.dataAccessLayer registerAccountWithName:name
                                            sipID:sipID
                                         password:password
                                          imageID:imageID];
}
-(DAL*)sharedInstance
{
    return self.dataAccessLayer;
}
@end
