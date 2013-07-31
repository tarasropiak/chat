//
//  ViewController.m
//  SIPPhone
//
//  Created by Andriy Mykhaylyshyn on 6/4/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "ViewController.h"
#import "SIPWrapper.h"



@interface ViewController () <SIPWrapperDelegate>

@property (retain, nonatomic)    SIPWrapper *wrap;
@property (retain, nonatomic) IBOutlet UILabel *url;

@end

@implementation ViewController


//getter & lazyinit for wrap and delegate
-(SIPWrapper*) wrap
{
    if(!_wrap) {
        _wrap = [[SIPWrapper alloc] init];
        _wrap.delegate = self;
    }
    return _wrap;
}
// Delloc
- (void)dealloc {
    [_wrap release];
    [_url release];
    
    [super dealloc];
}

// Test send message 
- (IBAction)test:(id)sender {
    //Cr8 temporal message
    MessageWrapper * tempMSG = [[MessageWrapper alloc] init];
    tempMSG.nameField=@"sip:test25@sip.linphone.org";
    tempMSG.messageField = @"All Your Base Are Belong To Us";
    
    [self.wrap sendMessage:tempMSG];
    [tempMSG release];
    
}



-(void) viewDidLoad
{
   // Start SIPCliend and message listening
    [self.wrap startSIPWithLogin:@"sip:test26@sip.linphone.org" andWithPass:@"111111"];
    [self.wrap registerWithDomen:@"sip:sip.linphone.org"];
    [self.wrap enableErrorReceiver];
    

}


- (void)messageReceived:(MessageWrapper *)message
{
    //Return to GCD
   dispatch_async(dispatch_get_main_queue(), ^{
       self.url.text=message.messageField;
   });
}
-(void)registrationProcessed:(bool)registration
{

}

@end
