//
//  AddUserViewController.m
//  MyChat
//
//  Created by Administrator on 6/25/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import "AddUserViewController.h"
#import "DAL.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AddUserViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (retain, nonatomic) IBOutlet UITextField *sipID;
@property (retain, nonatomic) IBOutlet UITextField *userName;
@property (retain, nonatomic) IBOutlet UIImageView *photo;
@property (retain, nonatomic) NSString *urlPhoto;
@property (retain, nonatomic) IBOutlet UIButton *chooseBtn;
@property (retain, nonatomic) IBOutlet UIButton *takeBtn;
@property (retain, nonatomic) NSString *imageName;
@end

@implementation AddUserViewController
@synthesize  sessionProvider = _sessionProvider;
@synthesize dataBaseManager = _dataBaseManager;
@synthesize urlPhoto = _urlPhoto;
@synthesize imageName = _imageName;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=@"Add New Contact";
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.userName.leftView = paddingView;
    self.userName.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.sipID.leftView = paddingView1;
    self.sipID.leftViewMode = UITextFieldViewModeAlways;
    
    [self.photo setImage:[UIImage imageNamed:@"defaultPicture.jpg"]];
    _imageName = @"defaultPicture.jpg";
    
}

- (IBAction)getPhoto:(id)sender {
    [self.view endEditing:YES];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ((UIButton *) sender == self.chooseBtn){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else {
        return;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //get temporary asset URL of image in Photo Library
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        _imageName = [imageRep filename];
    };
    
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.photo.image = pickedImage;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)AddUser:(id)sender {
    [self.view endEditing:YES];
  
    if (self.sipID.text.length == 0 || self.userName.text.length == 0){
        return;
    }
    //Test and correct self.userName
    NSString *correctName = self.sipID.text;
    if ((correctName.length < 5) || ![[correctName substringToIndex:4] isEqualToString:@"sip:"])
    {
        correctName = [@"sip:" stringByAppendingString:correctName];
    }
    if ((correctName.length < 17) || ![[correctName substringFromIndex:(correctName.length - 17)] isEqualToString:@"@sip.linphone.org"])
    {
        correctName = [correctName stringByAppendingString:@"@sip.linphone.org"];
    }
    self.sipID.text = correctName;
    
    //---getting path of Documents directory + concatinating with image name
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:_imageName];
    NSError * error = nil;
    //---Copying image to Documents directory only if it isn't already there
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSData *imageData = UIImagePNGRepresentation(self.photo.image);
        [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
    }
    //Handling error if it comes
        if (error != nil) {
            NSLog(@"Error: %@", error);
            return;
        }
    self.urlPhoto = path;
    @try {
        [self.dataBaseManager addContactWithName:self.userName.text
                                           sipID:self.sipID.text
                                       pictureID:self.urlPhoto
                               toAcountWithSipID:
         [self.sessionProvider
          authorizedUser]];
    }
    @catch (NSException *exception) {
    UIAlertView *alert = [[UIAlertView alloc]
                                           initWithTitle:@"Validation error!!!"
                                                 message:@"Invalid sip ID"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];;
        [alert show];
    }
    @finally {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_sipID release];
    [_userName release];
    [_photo release];
    [_chooseBtn release];
    [_takeBtn release];
    [super dealloc];
}
@end
