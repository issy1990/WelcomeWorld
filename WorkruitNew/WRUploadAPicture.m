//
//  WRUploadAPicture.m
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRUploadAPicture.h"
#import "RSKImageCropViewController.h"
#import "WRLocationViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "Photos/Photos.h"


@interface WRUploadAPicture ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,RSKImageCropViewControllerDelegate>

@end

@implementation WRUploadAPicture
{
    IBOutlet UIView * myView;

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    NSLog(@"params %@",[CompanyHelper sharedInstance]);
    
    if([Utility isComapany])
    {
        [self.upload_button setTitle:@"Upload Company Logo" forState:UIControlStateNormal];
        self.profilePic.image = [UIImage imageNamed:@"company_placeholder"];
        
    }else{
        
        [self.upload_button setTitle:@"Upload your picture" forState:UIControlStateNormal];
        self.profilePic.image = [UIImage imageNamed:@"aplicant_placeholder"];
        
    }
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2;
    self.profilePic.layer.masksToBounds = YES;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [Utility setThescreensforiPhonex:myView];

}

-(IBAction)showPickerOption:(id)sender
{
        UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Choose Image" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *finish = [UIAlertAction actionWithTitle:@"Take New Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                 {
                                     if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                         [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
                                 }];
        
            UIAlertAction *playAgain = [UIAlertAction actionWithTitle:@"Select from library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                    }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                 {
                                     [actionSheetController dismissViewControllerAnimated:YES completion:nil];
                                 }];
        [actionSheetController addAction:finish];
        [actionSheetController addAction:playAgain];
        [actionSheetController addAction:cancel];
        [self.navigationController presentViewController:actionSheetController animated:YES completion:nil];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if(sourceType == UIImagePickerControllerSourceTypePhotoLibrary || sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum){

        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized) {
            // Access has been granted.
            [self popCamera:sourceType];
        }else if (status == PHAuthorizationStatusDenied) {
            // Access has been denied.
            [CustomAlertView showAlertWithTitle:nil message:@"Workruit does not have access to your photos. To enable access, tap Settings and turn on Photos." OkButton:@"Cancel" cancelButton:@"Settings" delegate:self withTag:100];
        }else if (status == PHAuthorizationStatusNotDetermined) {
            // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                    [self popCamera:sourceType];
                }else {
                    // Access has been denied.
                    [self camDenied];
                }
            }];
        } else if (status == PHAuthorizationStatusRestricted) {
            // Restricted access - normally won't happen.
            [CustomAlertView showAlertWithTitle:nil message:@"Workruit does not have access to your photos. To enable access, tap Settings and turn on Photos." OkButton:@"Cancel" cancelButton:@"Settings" delegate:self withTag:100];
        }
    }else{
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized)
        {
            [self popCamera:sourceType];
        }
        else if(authStatus == AVAuthorizationStatusNotDetermined)
        {
            NSLog(@"%@", @"Camera access not determined. Ask for permission.");
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 if(granted)
                 {
                     NSLog(@"Granted access to %@", AVMediaTypeVideo);
                     [self popCamera:sourceType];
                 }
                 else
                 {
                     NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                     [self camDenied];
                 }
             }];
        }
        else if (authStatus == AVAuthorizationStatusRestricted)
        {
            // My own Helper class is used here to pop a dialog in one simple line.
            [CustomAlertView showAlertWithTitle:nil message:@"Workruit does not have access to your photos. To enable access, tap Settings and turn on Photos." OkButton:@"Cancel" cancelButton:@"Settings" delegate:self withTag:100];
        }
        else
        {
            [CustomAlertView showAlertWithTitle:nil message:@"Workruit does not have access to your photos. To enable access, tap Settings and turn on Photos." OkButton:@"Cancel" cancelButton:@"Settings" delegate:self withTag:100];
        }
    }
}

-(void)camDenied
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)popCamera:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.hidesBottomBarWhenPushed = YES;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.edgesForExtendedLayout = UIRectEdgeAll;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[[UIApplication sharedApplication].delegate window] rootViewController] presentViewController:imagePickerController animated:NO completion:nil];
    });
}

-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    if(buttonIndex == 2){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)nextButtonForProcess:(id)sender
{
    if([Utility isComapany]){
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        WRChooseCompanyIndustry *industryController = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
        [self.navigationController pushViewController:industryController animated:YES];
    }else{
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRLocationViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_LOCATION_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if([Utility isComapany]){
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        WRChooseCompanyIndustry *industryController = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
        [self.navigationController pushViewController:industryController animated:YES];
    }else{
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        [self.navigationController pushViewController:[mystoryboard instantiateViewControllerWithIdentifier:WR_LOCATION_VIEW_CONTROLLER_IDENTIFIER] animated:YES];
    }
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}

-(IBAction)skipButtonAction:(id)sender
{
    if([Utility isComapany]){
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        WRChooseCompanyIndustry *industryController = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
        [self.navigationController pushViewController:industryController animated:YES];
    }else{
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRLocationViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_LOCATION_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


-(IBAction)previousButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
    imageCropVC.hidesBottomBarWhenPushed = YES;
    [imageCropVC setAvoidEmptySpaceAroundImage:YES];
    imageCropVC.delegate = self;
    [self.navigationController pushViewController:imageCropVC animated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma IMAGE CROP DELEGATE AND DATASOURCES METHODS

// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    self.profilePic.image = croppedImage;
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    UIImage *image = [Utility resizeImage:croppedImage];
    self.profilePic.image = image;
    if([Utility isComapany])
        [CompanyHelper sharedInstance].profile_image = image;
    else
        [ApplicantHelper sharedInstance].profile_image = image;
    
    [self.navigationController popViewControllerAnimated:YES];

    NSData *imageData = UIImageJPEGRepresentation(image,0.5);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"cached"]];
    
    NSLog((@"pre writing to file"));
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        NSLog((@"Failed to cache image data to disk"));
    }
    else
    {
        NSLog(@"the cachedImagedPath is %@",imagePath);
        [self uploadProfilePicWithURL:imagePath];
    }
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage
{
    // Use when `applyMaskToCroppedImage` set to YES.
}


// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGSize maskSize;
    if ([controller isPortraitInterfaceOrientation]) {
        maskSize = CGSizeMake(250, 250);
    } else {
        maskSize = CGSizeMake(220, 220);
    }
    
    CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
    CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
    
    CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                 (viewHeight - maskSize.height) * 0.5f,
                                 maskSize.width,
                                 maskSize.height);
    
    return maskRect;
}

-(void)uploadProfilePicWithURL:(NSString *)imagePath
{
    NSMutableDictionary *parmas = [[NSMutableDictionary alloc] initWithCapacity:0];
    if([Utility isComapany])
        [parmas setObject:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:SAVE_COMPANY_ID]] forKey:@"companyId"];
    else
        [parmas setObject:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]] forKey:@"userId"];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", API_BASE_URL,[Utility isComapany]?UPLOAD_COMPANY_LOGO_API:UPLOAD_PROFILE_PIC] parameters:parmas constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:imagePath] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
    } error:nil];
    
    NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    if([session_id length] > 10)
        [request setValue:session_id forHTTPHeaderField:@"Token"];
    
    NSString *authorization = [NSString stringWithFormat:@"%@:%@",USERNAME,PASSWORD];
    authorization = [Utility encodeStringTo64:authorization] ;
    [request setValue:[NSString stringWithFormat:@"Basic %@",authorization] forHTTPHeaderField:@"Authorization"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          // [progressView setProgress:uploadProgress.fractionCompleted];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                          if([[responseObject valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
                          {
                              if([Utility isComapany]){
                                  [[CompanyHelper sharedInstance] setParamsValue:[[responseObject valueForKey:@"data"] valueForKey:@"filePath"] forKey:@"pic"];
                                  [[CompanyHelper sharedInstance] setParamsValue:[[responseObject valueForKey:@"data"] valueForKey:@"filePath"] forKey:@"picture"];
                              }else{
                                  [[ApplicantHelper sharedInstance] setParamsValue:[[responseObject valueForKey:@"data"] valueForKey:@"filePath"] forKey:@"pic"];
                                  [[ApplicantHelper sharedInstance] setParamsValue:[[responseObject valueForKey:@"data"] valueForKey:@"filePath"] forKey:@"picture"];

                              }
                          }
                          
                      }
                  }];
    
    [uploadTask resume];
}

@end
