//
//  LoginViewController.m
//  Login
//
//  Created by Administrator on 6/3/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import "LoginViewController.h"

#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface LoginViewController ()
@property (retain, nonatomic) IBOutlet UITextField *userName;
@property (retain, nonatomic) IBOutlet UITextField *userPassword;
@property (retain, nonatomic) SIPWrapper *wrapInLogin;
@property (assign, nonatomic) id<DataBaseManager> dataAccessLayer;
@property (retain, nonatomic) NSString *validUserSipID;
@property (nonatomic) NSInteger registrationProcces;
@property (retain, nonatomic) IBOutlet UIButton *signInOutlet;
@property (nonatomic) BOOL inChat;
@end


@implementation LoginViewController
@synthesize userName;
@synthesize userPassword;
@synthesize validUserSipID;
@synthesize dataAccessLayer = _dataAccessLayer;

// SIP Wrapper lazy init + delegate
-(SIPWrapper *)wrapInLogin
{
    if (!_wrapInLogin){
        _wrapInLogin = [[SIPWrapper alloc] init];
        _wrapInLogin.errorDelegat=self;
        self.inChat=NO;
    }
    return _wrapInLogin;
}

-(NSString *)correctName
{
    NSString *correctName = self.userName.text;
    if ((correctName.length < 5) || ![[correctName substringToIndex:4] isEqualToString:@"sip:"])
    {
        correctName = [@"sip:" stringByAppendingString:correctName];
    }
    if ((correctName.length < 17) || ![[correctName substringFromIndex:(correctName.length - 17)] isEqualToString:@"@sip.linphone.org"])
    {
        correctName = [correctName stringByAppendingString:@"@sip.linphone.org"];
    }
    return correctName;
}

- (IBAction)SignInPressed:(id)sender {
    [self.view endEditing:YES];
    if (self.userPassword.text.length == 0 || self.userName.text.length == 0){
        return;
    }
    _signInOutlet.enabled=NO;
    _signInOutlet.backgroundColor= [UIColor redColor];
    
    // When button pressed rebild wrap ....
    self.wrapInLogin=nil;
    //... start client ...
    [self.wrapInLogin startSIPWithLogin:self.correctName
                            andWithPass:self.userPassword.text];
    self.validUserSipID = self.correctName;
    //.. register ...
    [self.wrapInLogin registerWithDomen:self.validUserSipID];
    
    /* ... connect registration feedback
     For more detail and program behiave
     look registrationProcessed function*/
    [self.wrapInLogin enableErrorReceiver];
   // [self errorRecieved:200];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.userName.leftView = paddingView;
    self.userName.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.userPassword.leftView = paddingView1;
    self.userPassword.leftViewMode = UITextFieldViewModeAlways;
    _signInOutlet.backgroundColor=[UIColor greenColor];
    [self.userPassword setSecureTextEntry:YES];
    self.dataAccessLayer = (AppDelegate*) UIApplication.sharedApplication.delegate;
    
    self.wrapInLogin = [[SIPWrapper alloc]init];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"autolog"] boolValue])
    {  
        self.userName.text=[defaults objectForKey:@"autoaccount"];
        self.userPassword.text=[defaults objectForKey:@"autopasswor"];
        _signInOutlet.enabled=NO;
        _signInOutlet.backgroundColor= [UIColor redColor];
        [self.view endEditing:YES];
        
        // When button pressed rebild wrap ....
        self.wrapInLogin=nil;
        //... start client ...
        [self.wrapInLogin startSIPWithLogin:self.correctName
                                andWithPass:self.userPassword.text];
        self.validUserSipID = self.correctName;
        //.. register ...
        [self.wrapInLogin registerWithDomen:self.validUserSipID];
        
        /* ... connect registration feedback
         For more detail and program behiave
         look registrationProcessed function*/
        [self.wrapInLogin enableErrorReceiver];
    }
}

- (void)viewDidUnload
{
    [self setUserName:nil];
    [self setUserPassword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//---Orientation---
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if(!self.inChat)
    {
        
        if ([segue.identifier isEqualToString:@"ShowTabBar"]){
            [segue.destinationViewController  setWrapInTabVC:self.wrapInLogin];
            TabBarViewController * _temporaryTabPtr =
            segue.destinationViewController;
            
            
            _temporaryTabPtr.sipDelegate = self;
            _temporaryTabPtr.sessionProvider = self;
            _temporaryTabPtr.dataBaseManager = self.dataAccessLayer;
        }
        //save login and password for settings
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:self.correctName forKey:@"thisaccount"];
        [defaults setObject:self.userPassword.text forKey:@"thispasswor"];
        [defaults synchronize];
        self.inChat=YES;
    }
        
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)dealloc {
    [userName release];
    [userPassword release];
    [_wrapInLogin release];
    [_dataAccessLayer release];
    [_signInOutlet release];
    [super dealloc];
}

#pragma mark - SIPWrapper delegate methods
// Ivan Lopit's property

-(void) sendMessage:(id)message
{
    [self.wrapInLogin sendMessage:message];
}

-(SIPWrapper *) returnMyWrap
{
    return self.wrapInLogin;
}

-(void)errorRecieved:(int)code
{

    
    _signInOutlet.enabled=YES;
    _signInOutlet.backgroundColor=[UIColor redColor];
    
    
    //     });
    // ERRORS
#define  REGISTRED               200
#define  UNAUTHORIZED            401
#define  INCORRECT_PASSWORD      403
#define  REQUEST_TIMEOUT         408
#define  DNS_ERROR               503
#define  INCORRECT_LOGIN         900
#define  REGISTRATION            999   
#define  CLIENT_ERROR           1000
    
    NSString *errorType;
    NSString *errorDiscription;
    switch (code)
    
    {
        case REGISTRATION:
            
            errorType=@"ERR::403 Incorrect password";
            errorDiscription=@"Please check your password";
            //            [self.wrapInLogin dealloc];
            //            errorType=@"ERR::999";
            //            errorDiscription=@"Registration timeout";
            //
            //
            //... start client ...
            //            [self.wrapInLogin startSIPWithLogin : self.userName.text
            //                                     andWithPass:self.userPassword.text];
            //
            //            //.. register ...
           // [self.wrapInLogin registerWithDomen:self.validUserSipID];
            //
            //            /* ... connect registration feedback
            //             For more detail and program behiave
            //             look registrationProcessed function*/
            //            [self.wrapInLogin enableErrorReceiver];
            
            break;
            
        case REGISTRED:
            
            
            self.validUserSipID = self.correctName;
            [self.dataAccessLayer registerAccountWithName:@"Unnamed"
                                                    sipID:self.correctName
                                                 password:self.userPassword.text
                                                  imageID:@"defaultPicture.jpg"];

            
            [_wrapInLogin disableErrorReceiver ];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"ShowTabBar" sender:self];
            });
            [self playSoundWithName:@"signIn" andType:@"wav"];
            break;
            
        case UNAUTHORIZED:
            
            break;
            
        case INCORRECT_PASSWORD :
            
            errorType=@"ERR::403 Incorrect password";
            errorDiscription=@"Please check your password";
            [self.wrapInLogin unregister];
            [self.wrapInLogin stopClient];
            
            break;
            
        case REQUEST_TIMEOUT:
            
            errorType=@"ERR::408 Request timeout";
            errorDiscription=@"Please check your dominian name";
            [self.wrapInLogin unregister];
            [self.wrapInLogin stopClient];
            
            break;
            
        case DNS_ERROR:
            
            errorType=@"ERR::503 DNS error";
            errorDiscription=@"Please check your dominian/login";
            [self.wrapInLogin unregister];
            [self.wrapInLogin stopClient];
            
            break;
        case INCORRECT_LOGIN:
            
            errorType=@"ERR::900 Incorrect login";
            errorDiscription=@"Please check your login and try again";
            [self.wrapInLogin unregister];
            [self.wrapInLogin stopClient];
            break;
        case     CLIENT_ERROR:
            
            errorType=@"ERR::1000 Server error";
            errorDiscription=@"Please check your internet connection";
            [self.wrapInLogin unregister];
            [self.wrapInLogin stopClient];
            break;
            
            
            
        default:
            errorType=@"Undiferent Error";
            errorDiscription=@"Please connect with us on lv087.iPhone@gmail.com";
            [self.wrapInLogin unregister];
            [self.wrapInLogin stopClient];
            break;
            
    }
    if(code>401)
    {
        [self playSoundWithName:@"error" andType:@"mp3"];       
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorType message:errorDiscription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
        
        
    }
    
}

#pragma mark - Data Base delegates methods
// Andriy Shkinder's property
-(NSString*)authorizedUser
{
    return  self.validUserSipID;
}


-(IBAction)didLogOutPressed:(UIStoryboardSegue *)segue
{
    [self.wrapInLogin stopClient];
    [self.wrapInLogin unregister];
    
}

-(void) playSoundWithName: (NSString*) soundName
                  andType:(NSString*) soundType {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                                                                  pathForResource:soundName ofType:soundType]];
    AVAudioPlayer *click  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:nil];
    [click setVolume:[defaults floatForKey:@"loud"]];
    [click play];
}

@end
