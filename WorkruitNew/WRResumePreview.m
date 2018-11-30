//
//  WRResumePreview.m
//  WorkruitNew
//
//  Created by Admin on 10/2/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "WRResumePreview.h"
#import "HeaderFiles.h"
#import "AWSS3.h"
#import "AWSCore.h"


@interface WRResumePreview ()<UIWebViewDelegate,UIDocumentPickerDelegate,UIDocumentMenuDelegate>

@end

@implementation WRResumePreview
{
    IBOutlet UIView * myView;

}

-(IBAction)backButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(IBAction)changeButtonAction:(id)sender
{
    [self tapDocumentMenuView];
}


- (void)viewDidLoad
{
     if([Utility isComapany]){
         self.changeButton.hidden = YES;
     }
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    NSURL *url = [NSURL URLWithString:self.string_url];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
    
    [Utility setThescreensforiPhonex:myView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
    - (void)tapDocumentMenuView
    {
        NSArray *types = @[(NSString*)kUTTypeImage,(NSString*)kUTTypeSpreadsheet,(NSString*)kUTTypePresentation,(NSString*)kUTTypeDatabase,(NSString*)kUTTypeFolder,(NSString*)kUTTypeZipArchive,(NSString*)kUTTypeVideo,(NSString *)kUTTypeCompositeContent];
        
        UIDocumentMenuViewController *objMenuView = [[UIDocumentMenuViewController alloc]initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
        objMenuView.delegate = self;
        [self presentViewController:objMenuView animated:YES completion:nil];
        
    }
    
    
- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}
    
    
#pragma mark Delegate-UIDocumentPickerViewController
    
    /**
     *  This delegate method is called when user will either upload or download the file.
     *
     *  @param controller UIDocumentPickerViewController object
     *  @param url        url of the file
     */
    
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
    {
        if (controller.documentPickerMode == UIDocumentPickerModeImport)
        {
            NSData *fileData = [NSData dataWithContentsOfURL:url];
            NSString *fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:[NSString stringWithFormat:@".%@",[url pathExtension]]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
            //NSLog(@"filePath %@", filePath);
           // NSLog(@"----------- %d -------------------",[fileData writeToFile:filePath atomically:YES]);
            [fileData writeToFile:filePath atomically:YES];
            NSURL *url = [NSURL fileURLWithPath:filePath];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                [self.webView loadRequest:urlRequest];
            });


            //Temp
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:[url absoluteString] forKey:@"resume"];
            
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.body = [NSURL fileURLWithPath:filePath];
            uploadRequest.key = [NSString stringWithFormat:@"%@.%@",[Utility isComapany]?[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],[NSString stringWithFormat:@".%@",[url pathExtension]]];
            uploadRequest.bucket = AS3BUCKET_NAME;
            
            [self uploadToAmazonS3:uploadRequest];
            
            
            
            
        }else  if (controller.documentPickerMode == UIDocumentPickerModeExportToService)
        {
            // Called when user uploaded the file - Display success alert
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
                NSString *alertMessage = [NSString stringWithFormat:@"Successfully uploaded file %@", [url lastPathComponent]];
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"UIDocumentView"
                                                      message:alertMessage
                                                      preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
                
            });
        }
        
    }
    
    /**
     *  Delegate called when user cancel the document picker
     *
     *  @param controller - document picker object
     */
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    
}

-(void)uploadToAmazonS3:(AWSS3TransferManagerUploadRequest *)uploadRequest{
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        });
                    }
                    break;
                    default:
                    NSLog(@"Upload failed: [%@]", task.error);
                    break;
                }
            } else {
                NSLog(@"Upload failed: [%@]", task.error);
            }
        }
        
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }
        return nil;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
