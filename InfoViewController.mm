//
//  InfoViewController.m
//  SIPPhone
//
//  Created by developer on 7/16/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "InfoViewController.h"
#import "TabBarViewController.h"
#import "sessionProvider.h"
#import "DataBaseManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DAL.h"
#import "SipClientDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface InfoViewController ()
//@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIImageView *avatarView;
@property (retain, nonatomic) IBOutlet UITextField *nameField;
@property (retain, nonatomic) IBOutlet UITextField *sipField;
@property (retain, nonatomic) IBOutlet UISwitch *onlineSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *busySwitch;
@property (retain, nonatomic) IBOutlet UISwitch *dontDisturbSwitch;

@property (retain, nonatomic) UIImage *avatarImage;
@property (assign, nonatomic) id<sessionProvider> sessionProvider;
@property (assign, nonatomic) id<DataBaseManager> dataBaseManager;
@property (assign, nonatomic) id<SipClientDelegate> sipClient;
@property (retain,nonatomic) Account* currentAccount;
@property (retain, nonatomic) NSString* avatarURL;
@property (retain, nonatomic) NSString* choosenStatus;
@end

@implementation InfoViewController

@synthesize tableView = _tableView;
@synthesize sessionProvider = _sessionProvider;
@synthesize dataBaseManager = _dataBaseManager;
@synthesize avatarView = _avatarView;
@synthesize avatarImage = _avatarImage;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setStatus:(NSString*)status
{
    self.choosenStatus = status;
    if([status isEqualToString:@"Online"])
    {
        [self.busySwitch setOn:NO animated:YES];
        [self.dontDisturbSwitch setOn:NO animated:YES];
    }
    if([status isEqualToString:@"Busy"])
    {
        [self.onlineSwitch setOn:NO animated:YES];
        [self.dontDisturbSwitch setOn:NO animated:YES];
    }
    if([status isEqualToString:@"Don't disturb"])
    {
        [self.busySwitch setOn:NO animated:YES];
        [self.onlineSwitch setOn:NO animated:YES];
    }
    
}
- (IBAction)onlineChanges:(UISwitch *)sender
{
    if(sender.isOn)
    {
        [self setStatus:@"Online"];
    } else
    {
        [sender setOn:YES];
    }
}
- (IBAction)busyChanged:(UISwitch *)sender
{
    if(sender.isOn)
    {
        [self setStatus:@"Busy"];
    }else
    {
        [sender setOn:YES];
    }

}
- (IBAction)dontDisturbChanged:(UISwitch *)sender
{
    if(sender.isOn)
    {
        [self setStatus:@"Don't disturb"];
    }
    else
    {
        [sender setOn:YES];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    TabBarViewController * tab  = (TabBarViewController*)self.tabBarController;
    self.dataBaseManager = tab.dataBaseManager;
    self.sessionProvider = tab.sessionProvider;
    self.sipClient = tab.sipDelegate;
    [self preloadData];
    [self setStatus:self.choosenStatus];
    self.avatarView.image  = self.avatarImage;
    self.nameField.text = self.currentAccount.name;
    self.sipField.text = self.currentAccount.sipID;
    self.sipField.enabled = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(tapOnBack:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [self.avatarView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *pictureGestureRecognizer =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(tapOnImage:)];
    
    [self.avatarView addGestureRecognizer:pictureGestureRecognizer];
    
}
- (IBAction)confirmShangesPressed
{
    
    NSData *imageData = UIImagePNGRepresentation(self.avatarView.image);
    NSString *documentsDirectory =
    [NSSearchPathForDirectoriesInDomains
     (NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *path = [documentsDirectory
                      stringByAppendingPathComponent:
                      self.avatarURL];
    NSError * error = nil;
    if(self.avatarURL==nil)
    {
        path=nil;
    } else {
        BOOL fileExists = [[NSFileManager defaultManager]
                           fileExistsAtPath:path];
        if(!fileExists){
            [imageData writeToFile:path
                           options:NSDataWritingAtomic
                             error:&error];
        }
        if (error != nil) {
            NSLog(@"Error: %@", error);
            return;
        }
    }
    [self.currentAccount setStatus:self.choosenStatus];
    [self.currentAccount setNewName:
     self.nameField.text
                         andPicture:path];
}

-(void)tapOnBack:(UITapGestureRecognizer*)tapGestureRecognizer
{
    [self.nameField resignFirstResponder];
}

-(void)tapOnImage:(UITapGestureRecognizer*)tapGestureRecognizer
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"autolog"];
    
     NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                                                                  pathForResource:@"signIOut" ofType:@"mp3"]];
     AVAudioPlayer *click  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:nil];
     [click setVolume:[defaults floatForKey:@"loud"]];
     [click play];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        self.avatarURL= [imageRep filename];
        NSLog(@"[imageRep filename] : %@", [imageRep url]);
    };
    
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.avatarView.image = pickedImage;
    
    
    
    
}
-(void) preloadData
{
    self.currentAccount = [self.dataBaseManager accountWithSipID:
                           [self.sessionProvider authorizedUser]];
    switch (self.currentAccount.status) {
        case 0:
            self.choosenStatus = @"Online";
            [self.onlineSwitch setOn:YES animated:YES];
            break;
        case 1:
            self.choosenStatus = @"Busy";
            [self.busySwitch setOn:YES animated:YES];
            break;
        case 2:
            self.choosenStatus = @"Don't disturb";
            [self.dontDisturbSwitch setOn:YES animated:YES];
            break;
        
    }
    if([self.currentAccount.pictureID isEqualToString:@"defaultPicture.jpg"])
    {
        self.avatarImage = [UIImage imageNamed: self.currentAccount.pictureID];
    } else
    {
        self.avatarImage = [UIImage imageWithContentsOfFile:
                            self.currentAccount.pictureID];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//---Orientation---
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [_tableView release];
    [_avatarView release];
    [_nameField release];
    [_sipField release];
    [_onlineSwitch release];
    [_busySwitch release];
    [_dontDisturbSwitch release];
    [super dealloc];
}
@end