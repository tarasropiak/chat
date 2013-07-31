//
//  DetailsViewController.m
//  MyChat
//
//  Created by Administrator on 6/13/13.
//  Copyright (c) 2013 Administrator. All rights reserved.
//

#import "DetailsViewController.h"
#import "ChatViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DetailsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (retain, nonatomic) IBOutlet UITextField *descriptionLabel;
@property (retain, nonatomic) IBOutlet UIImageView *avatarImage;
@property (retain, nonatomic) IBOutlet UIButton *chooseButton;
@property (retain, nonatomic) IBOutlet UIButton *takeButton;
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UITextField *nameEdit;
@property (retain, nonatomic) NSString *imageName;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) NSString *originName;
@property UINavigationController *navController;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navController = self.navigationController;
    self.view.backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f
                                                alpha:1.0f];
    self.nameEdit.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f
                                                    alpha:0.9f];
    self.descriptionLabel.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f
                                                            alpha:0.9f];
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(keyboardEndEditing)];
    [self.view addGestureRecognizer:recog];
    self.navigationItem.title = self.chosenContact.name;
    self.descriptionLabel.text = self.chosenContact.sipID;
    UIImage *avatarImage = [UIImage imageWithContentsOfFile:self.chosenContact.pictureID];
    self.avatarImage.image = avatarImage;
    self.chooseButton.hidden = YES;
    self.takeButton.hidden = YES;
    self.editButton.titleLabel.text = @"Edit";
    self.nameEdit.hidden = YES;
    self.nameLabel.hidden = YES;
    self.originName = self.chosenContact.name;
}

- (IBAction)deletePressed:(id)sender {
    [self.dataBaseManager deleteContactWithsSipID:self.chosenContact.sipID
                              fromAcountWithSipID:
                                [self.sessionProvider authorizedUser]];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (void)viewDidUnload {
   // [self setNameLabel:nil];
   // [self setDescriptionLabel:nil];
   // [self setAvatarImage:nil];
   // [super viewDidUnload];
}

- (IBAction)editPressed:(id)sender {
    if([self.editButton.titleLabel.text isEqual:@"Edit"] == YES) {//edit
        self.nameEdit.text = self.navigationItem.title;
        self.nameEdit.hidden = NO;
        self.avatarImage.frame = CGRectMake(self.avatarImage.frame.origin.x,
                                            self.avatarImage.frame.origin.y + self.avatarImage.frame.size.height / 2,
                                            self.avatarImage.frame.size.width / 2,
                                            self.avatarImage.frame.size.height / 2);
        [sender setTitle:@"Save" forState:UIControlStateNormal];
        self.chooseButton.hidden = NO;
        self.takeButton.hidden = NO;
        self.nameLabel.hidden = NO;
    }
    else {//save
        //self.navigationItem.title = self.nameEdit.text;
        self.nameEdit.hidden = YES;
        self.nameLabel.hidden = YES;
        
        self.avatarImage.frame = CGRectMake(self.avatarImage.frame.origin.x,
                                            self.avatarImage.frame.origin.y - self.avatarImage.frame.size.height,
                                            self.avatarImage.frame.size.width * 2,
                                            self.avatarImage.frame.size.height * 2);
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        self.chooseButton.hidden = YES;
        self.takeButton.hidden = YES;
        NSData *imageData = UIImagePNGRepresentation(self.avatarImage.image);
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:self.imageName];
        NSError *error = nil;
        if(self.imageName == nil) {
            path = nil;
        }
        else {
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
            if(!fileExists) {
                [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
            }
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
        }if([self.nameEdit.text isEqualToString:@""]){
            self.nameEdit.text = self.originName;
            self.navigationItem.title = self.originName;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty field!" message:@"Don't leave empty field!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        else{
        [self.dataBaseManager updateNameWith:self.nameEdit.text andPicture:path
                          inContactWithSipID:self.chosenContact.sipID ofAccountWithSipID:
                                [self.sessionProvider authorizedUser]];
        self.navigationItem.title = self.nameEdit.text;
        self.originName = self.nameEdit.text;
        }
    }
}

- (IBAction)getPhoto:(id)sender {
    [self.view endEditing:YES];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ((UIButton *) sender == self.chooseButton) {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else {
        return;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        self.imageName = [imageRep filename];
    };
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.avatarImage.image = pickedImage;
    
}

- (IBAction)chatPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardEndEditing {
    [self.nameEdit resignFirstResponder];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [_avatarImage release];
    [_chooseButton release];
    [_takeButton release];
    [_editButton release];
    [_nameEdit release];
    [_nameLabel release];
    [super dealloc];
}

@end
