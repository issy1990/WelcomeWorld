

//
//  WRApplicantEditProfile.m
//  workruit
//
//  Created by Admin on 10/13/16.
//  Copyright © 2016 Admin. All rights reserved.
//
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#import "WRApplicantEditProfile.h"
#import "WRAddExperianceController.h"
#import "WRSkillsViewController.h"
#import "ApplicantEditProfileMessageView.h"
#import "Photos/Photos.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AWSS3.h"
#import "AWSCore.h"
#import "NewTableViewCell.h"
#import "LoadDataManager.h"


@interface WRApplicantEditProfile ()<UITextFieldDelegate,UITextViewDelegate,RSKImageCropViewControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,TTRangeSliderDelegate,UIDocumentPickerDelegate,UIDocumentMenuDelegate>
{
    ASJTagsView *tagsViewTemp;
    CustomTextViewCell *local_text_view_cell;
    NSString *applicant_title;
    NSString *totalexperiencedisplay ;
    UIImageView *profile_image;
    
    UILabel *experianceLbl;
    BOOL isPickerShown;
    NSMutableDictionary *applicantParamObject;
    CustomTextField *selected_text_field;
    CustomPickerView *picker_object;
    
    BOOL isSectionHeaderShow;
    ApplicantEditProfileMessageView *messageView;
    
    UIView *tagsView;
    
    UIScrollView * scrollView;
    IBOutlet UIView * myView;
    
}
@end

@implementation WRApplicantEditProfile

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    tagsView = nil;
    
    [FireBaseAPICalls captureScreenDetails:EDIT_APPLICANT];
    
    if([[Utility trim:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"title"]] length] <= 0  && [[Utility trim:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userJobTitle"]] length] <= 0){
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] > 0){
            [[ApplicantHelper sharedInstance] setParamsValue:[[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] objectAtIndex:0]valueForKey:@"jobTitle"] forKey:@"userJobTitle"];
            [[ApplicantHelper sharedInstance] setParamsValue:[[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] objectAtIndex:0]valueForKey:@"jobTitle"] forKey:@"title"];
        }
    }
    
    //[self calculateExperiance];
    //[[ApplicantHelper sharedInstance] updateApplicantServiceCallWithDelegate:self requestType:102];
    NSLog(@"my data:%@",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience1"]);
    if ([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience1"] isEqualToString:@"saveddata"]   )
    {
        [[ApplicantHelper sharedInstance] updateApplicantServiceCallWithDelegate:self requestType:-102];
    }else{
        [self.table_view reloadData];
    }
    
    [self performSelector:@selector(checForBanner:) withObject:self afterDelay:1.0];
    scrollView =[[UIScrollView alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"saveJobSkills"] == YES)
    {
        _save_button.hidden = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FireBaseAPICalls captureMixpannelEvent:APPLICANT_JOBS_NOJOBS];
    
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[ApplicantHelper sharedInstance] setParamsValue:@"" forKey:@"about"];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.table_view setSeparatorColor:DividerLineColor];
    
    if(self.isCommingFromWhere == 100 ){
        if(app_delegate.isNetAvailable)
            [[ApplicantHelper sharedInstance] getApplicantProfile:self requestType:-102];
        self.save_button.hidden = YES;
    }else if(self.isCommingFromWhere == 200 || self.isCommingFromWhere == 300){
        self.back_button.hidden = YES;
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[NSNumber numberWithInt:1] forKey:@"minSalaryExp"];
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[NSNumber numberWithInt:50] forKey:@"maxSalaryExp"];
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[NSNumber numberWithBool:1] forKey:@"hideSalary"];
    }
    applicantParamObject = [[ApplicantHelper sharedInstance].paramsDictionary mutableCopy];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alerttDisplayed:) name:@"DataUpdationALert" object:nil];
    
    [Utility setThescreensforiPhonex:myView];

}

-(void)alerttDisplayed:(NSNotification *)notify
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CheckDay_ExtJobs"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:USERJOBSFORAPPLICANTARRAY];
    
    [self closeWindow];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:[notify valueForKey:@"object"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}
-(void)checForBanner:(id)sender
{
    //Banner text
    if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count] <= 0 || [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] <= 0)
    {
        NSString *title = @"", *message = @"", *buttontitle = @"";
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count] <= 0 && ([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] <= 0 && [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"totalexperience"] floatValue] > 0))
        {
            title = @"Finish Signing Up"; message = @"Just one more step away from companies finding your profile."; buttontitle = @"Complete";
            [self showSlideAnimation:title message:message buttontitle:buttontitle];
            
            [FireBaseAPICalls captureScreenDetails:APPLICANT_INCOMPLETE_PROFILE_MISSINGEDUANDEXP];

        }
        else if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count] <= 0)
        {
            title = @"Almost there"; message = @"Just a few steps away from getting the right job."; buttontitle = @"Add Education";
            [self showSlideAnimation:title message:message buttontitle:buttontitle];
            
            [FireBaseAPICalls captureScreenDetails:APPLICANT_INCOMPLETE_PROFILE_MISSINGEDUCATION];

        }
        else if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] <= 0 && [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"totalexperience"] floatValue] > 0)
        {
            title = @"Almost there"; message = @"Just a few steps away from getting the right job."; buttontitle = @"Add Experience";
            [self showSlideAnimation:title message:message buttontitle:buttontitle];
            [FireBaseAPICalls captureScreenDetails:APPLICANT_INCOMPLETE_PROFILE_MISSINGXPERINCE];
        }
    }
}

-(void)showSlideAnimation:(NSString *)title message:(NSString *)message buttontitle:(NSString *)buttontitle
{
    if(messageView != nil)
        return;
    
    isSectionHeaderShow = YES;
    [UIView transitionWithView: self.table_view
                      duration: 0.15f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         [self.table_view reloadData];
     }completion:^(BOOL finished) {
         
         NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ApplicantEditProfileMessageView" owner:self options:nil];
         messageView = (ApplicantEditProfileMessageView *)[topLevelObjects objectAtIndex:0];
         messageView.frame = CGRectMake(10 + self.view.frame.size.width, 10, self.view.frame.size.width-20, 114);
         messageView.titleLbl.text = title;
         messageView.messageLbl.text = message;
         [messageView.completeButton setTitle:buttontitle forState:UIControlStateNormal];
         [messageView.completeButton addTarget:self action:@selector(closeMessageWindow:) forControlEvents:UIControlEventTouchUpInside];
         [messageView.closeButton addTarget:self action:@selector(closeMessageWindow:) forControlEvents:UIControlEventTouchUpInside];
         
         [self.table_view addSubview:messageView];
         
         [UIView transitionWithView: self.table_view
                           duration: 0.5f
                            options: UIViewAnimationOptionTransitionNone
                         animations: ^(void)
          {
              messageView.frame = CGRectMake(10, 10, self.view.frame.size.width-20, 114);
          }completion: nil];
     }];
}
-(void)closeWindow
{
    isSectionHeaderShow = NO;
    [UIView transitionWithView: self.table_view
                      duration: 0.5f
                       options: UIViewAnimationOptionTransitionNone
                    animations: ^(void)
     {
         messageView.frame = CGRectMake(-self.view.frame.size.width, 10, self.view.frame.size.width-20, 114);
     }completion:^(BOOL finished) {
         messageView = nil;
         [UIView transitionWithView: self.table_view
                           duration: 0.15f
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations: ^(void)
          {
              [self.table_view reloadData];
          }completion:^(BOOL finished) {
          }];
     }];
}
-(void)closeMessageWindow:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    isSectionHeaderShow = NO;
    [UIView transitionWithView: self.table_view
                      duration: 0.5f
                       options: UIViewAnimationOptionTransitionNone
                    animations: ^(void)
     {
         messageView.frame = CGRectMake(-self.view.frame.size.width, 10, self.view.frame.size.width-20, 114);
     }completion:^(BOOL finished) {
         messageView = nil;
         [UIView transitionWithView: self.table_view
                           duration: 0.15f
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations: ^(void)
          {
              [self.table_view reloadData];
          }completion:^(BOOL finished) {
              if(btn.tag == 2){
                  
                  if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count] <= 0 && ([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] <= 0 && [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"totalexperience"] floatValue] > 0)){
                      UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
                      WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
                      controller.Flag = 0;
                      controller.isFirstTime = YES;
                      controller.screen_id = 1000;
                      controller.commingfromeditprofile = 100l;
                      [self.navigationController pushViewController:controller animated:YES];
                      
                  }else if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count] <= 0){
                      
                      UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
                      WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
                      controller.Flag = 1;
                      controller.isFirstTime = YES;
                      [self.navigationController pushViewController:controller animated:YES];
                      
                  }else if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] <= 0 && [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"totalexperience"] floatValue] > 0){
                      UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
                      WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
                      controller.Flag = 0;
                      controller.isFirstTime = YES;
                      [self.navigationController pushViewController:controller animated:YES];
                  }
                  
              }
              
          }];
     }];
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
        //NSLog(@"----------- %d -------------------",[fileData writeToFile:filePath atomically:YES]);
        [fileData writeToFile:filePath atomically:YES];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        
        //Temp
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[url absoluteString] forKey:@"resume"];
        [self.table_view reloadData];
        
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.body = [NSURL fileURLWithPath:filePath];
        uploadRequest.key = [NSString stringWithFormat:@"%@.%@",[Utility isComapany]?[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],[url pathExtension]];
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
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {}

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)backButtonAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"saveJobSkills"];

    [ApplicantHelper sharedInstance].paramsDictionary = applicantParamObject;
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)nextButtonForProcess:(id)sender
{
    NSString *aboutme = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"about"];
    if ([aboutme isKindOfClass:[NSString class]] && [aboutme stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CheckDay_ExtJobs"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:USERJOBSFORAPPLICANTARRAY];
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"saveJobSkills"];
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:APPLICANT_PROFILE_UPDATE setProperties:userName];
        
        [[ApplicantHelper sharedInstance] updateApplicantServiceCallWithDelegate:self requestType:100];
    } else {
        UIAlertController * alert_controller=   [UIAlertController
                                                 alertControllerWithTitle:@"Workruit"
                                                 message:@"About me is not valid."
                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
        [alert_controller addAction:ok];
        [self presentViewController:alert_controller animated:YES completion:nil];
    }
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 100 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
        
        [FireBaseAPICalls captureScreenDetails:@"applicant_skills"];
        [[ApplicantHelper sharedInstance] updateApplicantServiceCallWithDelegate:self requestType:101];
        
    }else if(tag == 101&& [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
        
        if([[data valueForKey:@"percentage"] floatValue] > 0)
            [ApplicantHelper sharedInstance].profilePercentage = [[data valueForKey:@"percentage"] floatValue];
        
        [ApplicantHelper sharedInstance].halfProfile = [[data valueForKey:@"halfProfile"] boolValue];
        
        if(self.isCommingFromWhere == 100){
            [self.navigationController popViewControllerAnimated:YES]; //Applicant from profile screen
            return;
        }else if(self.isCommingFromWhere == 200){//Applicant from signup process
            
            [FireBaseAPICalls captureScreenDetails:APPLICANT_FULLPROFILE_DONE];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
            [params setObject:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"email"] forKey:@"username"];
            [params setObject:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"password"] forKey:@"password"];
            [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID] forKey:@"regdId"];
            [params setObject:DEVICE_TYPE_STRING forKey:@"deviceType"];
            [params setObject:@"jobSeeker" forKey:@"role"];
            [[ApplicantHelper sharedInstance] loginApplicant:self requestType:103 params:params];
            
        }else if(self.isCommingFromWhere == 300){ //Applicant from login screen
            
            if([[[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID] length] > 0){
                [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
                [self createMeTabBarController];
            }else{
                NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
                [params setObject:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"email"] forKey:@"username"];
                [params setObject:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"password"] forKey:@"password"];
                [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID] forKey:@"regdId"];
                [params setObject:DEVICE_TYPE_STRING forKey:@"deviceType"];
                [params setObject:@"jobSeeker" forKey:@"role"];
                [[ApplicantHelper sharedInstance] loginApplicant:self requestType:103 params:params];
            }
        }
    }
    else if(tag == 103 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
    {
        [Utility saveToDefaultsWithKey:SESSION_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:SESSION_ID]]];
        [ApplicantHelper sharedInstance].paramsDictionary = [data valueForKey:@"data"];
        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
        [self createMeTabBarController];
    }
    else if(tag == -102&& [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
        
        
        if([[data valueForKey:@"percentage"] floatValue] > 0)
            [ApplicantHelper sharedInstance].profilePercentage = [[data valueForKey:@"percentage"] floatValue];
        
        [ApplicantHelper sharedInstance].halfProfile = [[data valueForKey:@"halfProfile"] boolValue];
        
        
        data = [[data valueForKey:@"data"] mutableCopy];
        NSLog(@"my applicant object:%@",data);
        
        NSLog(@"%@",[data valueForKey:@"totalExperienceText"]);
        
        if ([ApplicantHelper sharedInstance].halfProfile == YES) {
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_VIEW_PROFILE];
        }else{
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_VIEW_INCOMPLETEPROFILE];
        }
        
        NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithCapacity:0];
        [response setObject:[data valueForKey:@"coverLetter"] forKey:@"coverLetter"];
        [response setObject:[data valueForKey:@"coverLetter"] forKey:@"about"];
        [response setObject:[NSNumber numberWithFloat:[ApplicantHelper sharedInstance].profilePercentage] forKey:@"percentage"];
        
        [response setObject:[data valueForKey:@"deviceType"] forKey:@"deviceType"];
        [response setObject:[data valueForKey:@"email"] forKey:@"email"];
        [response setObject:[data valueForKey:@"firstname"] forKey:@"firstname"];
        [response setObject:[data valueForKey:@"jobFunctions"] forKey:@"jobfunctions"];
        [response setObject:[data valueForKey:@"lastname"] forKey:@"lastname"];
        [response setObject:[data valueForKey:@"location"] forKey:@"location"];
        [response setObject:[data valueForKey:@"status"] forKey:@"status"];
        [response setObject:[data valueForKey:@"telephone"] forKey:@"telephone"];
        [response setObject:[NSString stringWithFormat:@"%.1f",[[data valueForKey:@"totalExperience"] floatValue]] forKey:@"totalexperience"];
        [response setObject:[NSString stringWithFormat:@"%@",[data valueForKey:@"totalExperienceText"]] forKey:@"totalExperienceText"];
        
        [response setObject:[[data valueForKey:@"userPreferences"] mutableCopy] forKey:@"userPreferences"];
        [response setObject:[[data valueForKey:@"totalExperienceDisplay"] mutableCopy] forKey:@"totalexperiencedisplay"];
        
        [response setObject:[data valueForKey:@"resume"]  forKey:@"resume"];
        if ([data valueForKey:@"lastUpdatedDate"]!=nil)
        {
            [response setObject:[data valueForKey:@"lastUpdatedDate"] forKey:@"lastUpdatedDate"];
        }
        else{
            [response setObject:@"NA" forKey:@"lastUpdatedDate"];
            
        }
        
        if([data valueForKey:@"userSettings"])
            [response setObject:[[data valueForKey:@"userSettings"] mutableCopy] forKey:@"userSettings"];
        
        if(![Utility isNullValueCheck:[data valueForKey:@"pic"]])
            [response setObject:[data valueForKey:@"pic"] forKey:@"pic"];
        else
            [response setObject:@"" forKey:@"pic"];
        
        if(![Utility isNullValueCheck:[data valueForKey:@"picture"]])
            [response setObject:[data valueForKey:@"picture"] forKey:@"picture"];
        else
            [response setObject:@"" forKey:@"picture"];
        
        NSMutableArray *userAcademic = [data valueForKey:@"userAcademic"];
        userAcademic = [Utility sortTheArray:userAcademic];
        [response setObject:userAcademic forKey:@"academic"];
        NSLog(@"%@",response);
        
        NSMutableArray *educationArray = [[data valueForKey:@"userEducationSet"] mutableCopy];
        for(NSMutableDictionary *dictionary in educationArray){
            NSMutableDictionary *degree_object = [dictionary valueForKey:@"degree"];
            NSString *short_title = [degree_object valueForKey:@"shortTitle"];
            NSString *degree_name = [degree_object valueForKey:@"title"];
            
            [degree_object removeObjectForKey:@"shortTitle"];
            [degree_object removeObjectForKey:@"title"];
            
            [dictionary setObject:short_title forKey:@"degree_short_name"];
            [dictionary setObject:degree_name forKey:@"degree_name"];
        }
        
        educationArray = [Utility sortTheArray:educationArray];
        [response setObject:educationArray forKey:@"education"];
        
        NSMutableArray *userExperienceSet = [data valueForKey:@"userExperienceSet"];
        userExperienceSet = [Utility sortTheArray:userExperienceSet];
        [response setObject:userExperienceSet forKey:@"experience"];
        
        NSMutableArray *array = [data valueForKey:@"userSkillsSet"];
        NSMutableArray *skills_array = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSMutableDictionary *dictionary in array){
            [skills_array addObject:[dictionary valueForKey:@"title"]];
        }
        
        if([[data valueForKey:@"userJobTitle"] length] > 0){
            [response setObject:[data valueForKey:@"userJobTitle"] forKey:@"title"];
            [response setObject:[data valueForKey:@"userJobTitle"] forKey:@"userJobTitle"];
        }
        else{
            if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] > 0)
                [response setObject:[[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] objectAtIndex:0]valueForKey:@"jobTitle"] forKey:@"userJobTitle"];
        }
        [response setObject:skills_array forKey:@"skills"];
        
        if([[data valueForKey:@"minSalaryExp"] intValue] >= 0 && [[data valueForKey:@"maxSalaryExp"] intValue] > 0){
            [response setObject:[data valueForKey:@"minSalaryExp"] forKey:@"minSalaryExp"];
            [response setObject:[data valueForKey:@"maxSalaryExp"] forKey:@"maxSalaryExp"];
            [response setObject:[data valueForKey:@"hideSalary"] forKey:@"hideSalary"];
        }else{
            [response setObject:[NSNumber numberWithInt:1] forKey:@"minSalaryExp"];
            [response setObject:[NSNumber numberWithInt:50] forKey:@"maxSalaryExp"];
            [response setObject:[NSNumber numberWithBool:1] forKey:@"hideSalary"];
        }
        
        [Utility saveToDefaultsWithKey:APPLICANT_REGISTRATION_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:@"userId"]]];
        
        [ApplicantHelper sharedInstance].paramsDictionary = response;
        //[self calculateExperiance];
        
        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
        [self.table_view reloadData];
        
    }else if(tag == -110 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[data valueForKeyPath:@"data.display"] forKey:@"display"];
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[NSString stringWithFormat:@"%.1f",[[data valueForKeyPath:@"data.value"] floatValue]] forKey:@"totalexperience"];
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[NSString stringWithFormat:@"%.1f",[[data valueForKeyPath:@"data.display"] floatValue]] forKey:@"totalExperienceText"];
        //Save company object
        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
        
        [self.table_view reloadData];
    }
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}
-(void)createMeTabBarController
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISLOGEDIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRCandidateProfileController *jobsController =   [mystoryboard instantiateViewControllerWithIdentifier:WRCANDIDATE_PROFILE_CONTROLLER_IDENTIFIER];
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:jobsController];
    navController1.navigationBarHidden = YES;
    
    jobsController.title = @"Jobs";
    jobsController.tabBarItem.image = [[UIImage imageNamed:@"jobs-inactive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    jobsController.tabBarItem.selectedImage = [[UIImage imageNamed:@"jobs-active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    WRActivityViewController *activityController =   [mystoryboard instantiateViewControllerWithIdentifier:WRACTIVITY_VIEW_CONTROLLER_IDENTIFIER];
    UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:activityController];
    navController2.navigationBarHidden = YES;
    
    activityController.title = @"Activity";
    activityController.tabBarItem.image = [[UIImage imageNamed:@"activity-inactive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    activityController.tabBarItem.selectedImage = [[UIImage imageNamed:@"activity-active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    WRProfileViewController *profileController = [mystoryboard instantiateViewControllerWithIdentifier:WRPROFILE_VIEW_CONTROLLER_IDENTIFIER];
    UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:profileController];
    navController3.navigationBarHidden = YES;
    
    profileController.title = @"Profile";
    profileController.tabBarItem.image = [[UIImage imageNamed:@"profile-inactive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profileController.tabBarItem.selectedImage = [[UIImage imageNamed:@"profile-active"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarController *tabBarController=[[UITabBarController alloc] init];
    tabBarController.tabBar.tintColor  = UIColorFromRGB(0x337ab7);
    tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    tabBarController.tabBar.barTintColor = [UIColor whiteColor];
    tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2,navController3,nil];
    [self.navigationController pushViewController:tabBarController animated:YES];
    [LoadDataManager sharedInstance].tabBarController = tabBarController;
    [[LoadDataManager sharedInstance] getApplicationData];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 100.0f;
    else if(indexPath.section == 2 && indexPath.row == 0)
        return 150.0f;
    else if(indexPath.section == 8 && indexPath.row == 0){
        NSMutableArray *skillsArray =  [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"skills"];
        if([skillsArray count] > 0)
            return scrollView.contentSize.height+10;
        else  return CELL_HEIGHT;
    }else if(indexPath.section == 9 && indexPath.row == 0){
        return 100;
    }else
        return CELL_HEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return isSectionHeaderShow?200:60.0f;
    else
        return 40.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width-30, 40)];
    lbl.textColor = UIColorFromRGB(0x6A6A6A);
    bgView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    lbl.numberOfLines = 2;
    if(section == 0){
        UIView *viewTF = [self getProgressViewInHeader];
        [self.table_view bringSubviewToFront:messageView];
        return  viewTF;
    }else if(section == 1){
        lbl.text = @"RESUME";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 2){
        lbl.text = @"ABOUT ME";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 3){
        lbl.text = @"JOB FUNCTION";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 4){
        lbl.text = @"WORK EXPERIENCE";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 5){
        lbl.text = @"EXPERIENCE";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 6){
        lbl.text = @"EDUCATION";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 7){
        lbl.text = @"ACADEMIC PROJECT";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 8){
        lbl.text = @"SKILLS";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 9){
        lbl.text = @"TARGET SALARY";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    } else {
        NSString * lastUpdate =[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"lastUpdatedDate"];
        if (lastUpdate.length ==0||lastUpdate == nil) {
            lbl.hidden = YES;
        } else {
            lbl.hidden = NO;
            lbl.text = [NSString stringWithFormat:@"Profile updated last on %@",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"lastUpdatedDate"]];
        }
        
      //  @"Profile updated last on 09 Nov 2017, 6:09 PM";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.frame = CGRectMake(0, 10, self.view.frame.size.width-30, 30);
    }
    [bgView addSubview:lbl];
    
    return bgView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 11.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 3 || section == 0 ||section == 2 ||section == 1 || section == 4)
        return 1;
    else if(section == 5 && [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] > 0)
        return  [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count] + 1;
    else if(section == 6 && [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count] > 0)
        return [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count] + 1;
    else if(section == 7 && [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] count] > 0)
        return [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] count] + 1;
    else if(section == 8 || section == 9 )
        return 2;
    else if(section == 10)return 0;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        static NSString *cellIdentifier = PROFILE_PHOTO_CUSTOM_CELL_IDENTIFIER;
        ProfilePhotoCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:PROFILE_PHOTO_CUSTOM_CELL owner:self options:nil];
            cell = (ProfilePhotoCustomCell *)[topLevelObjects objectAtIndex:0];
            [cell.buttonAction addTarget:self action:@selector(showPickerOption:) forControlEvents:UIControlEventTouchUpInside];
        }
        NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",IMAGE_BASE_URL,[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"picture"]]]);
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"pic"] length] > 0){
            
            [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"pic"]]]
                                  placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"] options:SDWebImageRefreshCached];
        }else{
            [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"picture"]]]
                                  placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"] options:SDWebImageRefreshCached];
            
        }
        
        cell.profile_image.contentMode = UIViewContentModeScaleAspectFit;
        
        profile_image = cell.profile_image;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    else if (indexPath.section ==1){
        
        static NSString *cellIdentifier = CUSTOM_SKILLS_CELL_IDENTIFIER;
        CustomSkillsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SKILLS_CELL owner:self options:nil];
            cell = (CustomSkillsCell *)[topLevelObjects objectAtIndex:0];
        }
        
        cell.titleLbl.textColor = UIColorFromRGB(0x337ab7);

        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"resume"] length] > 0)
        {
            cell.addButton.hidden = YES;
            cell.titleLbl.text = @"View Resume";
            if (SCREEN_HEIGHT == 736)
            {
                cell.widthConstant.constant = -9;
                cell.label_x_constrant.constant = -4;
            }
            else if (SCREEN_HEIGHT == 667)
            {
                if (SYSTEM_VERSION_LESS_THAN(@"11.0"))
                {
                    cell.widthConstant.constant = 6;
                }
                else
                {
                    cell.widthConstant.constant = 1;
                }
            }
            else{
                cell.widthConstant.constant = 0;
            }
            cell.label_x_constrant.constant = 1;
        }
        else
        {
            cell.titleLbl.text = @" Upload Resume";
            cell.addButton.hidden = NO;
            if (SCREEN_HEIGHT == 568)
            {
                cell.widthConstant.constant = 22;
            }else if (SCREEN_HEIGHT == 667)
            {
                if (SYSTEM_VERSION_LESS_THAN(@"11.0"))
                {
                    cell.widthConstant.constant = 36;
                }
                else
                {
                    cell.widthConstant.constant = 28;
                    cell.button_x_constrant.constant =-1;
                }
                
            }
            else{
                cell.widthConstant.constant = 25;
                cell.button_x_constrant.constant =-5;
            }
            cell.label_x_constrant.constant = 8;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 2)
    {
        static NSString *cellIdentifier = CUSTOM_TEXT_VIEW_CELL_IDENTIFIER;
        CustomTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: CUSTOM_TEXT_VIEW_CELL owner:self options:nil];
            cell = (CustomTextViewCell *)[topLevelObjects objectAtIndex:0];
            local_text_view_cell = cell;
        }
        
        
        if([[Utility trim:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"about"]] length] <= 0 && [[Utility trim:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"coverLetter"]] length] <= 0){
            cell.text_view.text = @"Enter  Summary";
        }else{
            
            
            cell.text_view.text = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"about"];
            if([cell.text_view.text length] <= 0)
                cell.text_view.text = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"coverLetter"];
            cell.wordCount.text =[NSString stringWithFormat:@"%d",(int)(150 - [cell.text_view.text length])];
            
            cell.text_view.textColor = MainTextColor;
        }
        cell.text_view.delegate = self;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }

    else if(indexPath.section == 4 ){
        
        static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
        CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
            cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        }
        
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.ValueTF.textColor = MainTextColor;
        cell.titleLbl.text  = @"Years";
        cell.titleLbl.text = @"Years of Experience";
        cell.ValueTF.placeholder = @"Enter experience";
        cell.ValueTF.textColor = MainTextColor;
        
        cell.ValueTF.text = [NSString stringWithFormat:@"%@ years",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"totalexperiencedisplay"] ];
        
        NSRange range = [cell.ValueTF.text rangeOfString:@" "];
        NSString *fname = [cell.ValueTF.text substringToIndex:range.location];
        NSString *lname = [cell.ValueTF.text substringFromIndex:range.location+1];
        
        if ([lname length] >4) {
            if ([lname isEqualToString:@"0 years"])
            {
                cell.ValueTF.text = [NSString stringWithFormat:@"0.0 years"];
            }
            else{
                cell.ValueTF.text = [NSString stringWithFormat:@"%@ years",fname];
            }
        }
        else{
            cell.ValueTF.text = [NSString stringWithFormat:@"%@",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"totalexperiencedisplay"]];
            if ( [cell.ValueTF.text isEqualToString:@"0 years"]) {
                cell.ValueTF.text = [NSString stringWithFormat:@"0.0 years"];
            }
        }

        
        cell.ValueTF.delegate = self;
        cell.ValueTF.section = indexPath.section;
        cell.ValueTF.row = indexPath.row;
        cell.ValueTF.enabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
    else if(indexPath.section == 3 || indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 7) {
        
        if(((indexPath.row <= [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count]-1 && indexPath.section == 5) && [self isHaveObject:@"experience"]) ||
           ((indexPath.row <= [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count]-1 && indexPath.section == 6) && [self isHaveObject:@"education"]) ||
           ((indexPath.row <= [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] count]-1 && indexPath.section == 7) && [self isHaveObject:@"academic"]) ||
           (indexPath.row == 0 && indexPath.section == 3)
           ){
            static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
            CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
                cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.ValueTF.textColor = MainTextColor;
            if(indexPath.section == 3 && indexPath.row == 0){
                
                cell.titleLbl.text  = @"Role";
                cell.ValueTF.text = [ApplicantHelper getJobRolesFromArrayForEdit:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobfunctions"]];
                cell.ValueTF.placeholder = @"Select Job Function";
                
            }
            
            else if(indexPath.section == 5 && indexPath.row  <= [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count]-1)
            {
                
                cell.titleLbl.text  = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] objectAtIndex:indexPath.row] valueForKey:@"jobTitle"];
                NSString *company = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] objectAtIndex:indexPath.row] valueForKey:@"company"];
                NSString *start_date = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] objectAtIndex:indexPath.row] valueForKey:@"totalExperienceText"];
                
                NSLog(@"date is%@",start_date);
                
                 if(start_date == nil || [start_date isKindOfClass:[NSNull class]] || [start_date isEqualToString:@"(null)"])
                {
                    cell.ValueTF.text = [NSString stringWithFormat:@"%@",company];

                }else{
                    cell.ValueTF.text = [NSString stringWithFormat:@"%@, %@",company,start_date];
                }
            }else if(indexPath.section == 6 && indexPath.row <= [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count]-1){
                
                NSLog(@"%@",[[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row]valueForKey:@"degree"] );
                
                
                //NSMutableArray *degreeArray = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row]valueForKey:@"degree"] ;
                
                NSString *digree_short = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row]   valueForKey:@"degree_short_name"];
                
                cell.titleLbl.text  = [NSString stringWithFormat:@"%@ - %@",digree_short,[[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row] valueForKey:@"fieldOfStudy"]];
                
                NSString *institution = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row] valueForKey:@"institution"];
                NSString *start_date = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row] valueForKey:@"startDate"];
                NSString *end_date = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row] valueForKey:@"endDate"];
                
                if([[[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row] valueForKey:@"isPresent"] boolValue])
                    end_date = @"Present";
                
                cell.ValueTF.text = [NSString stringWithFormat:@"%@, %@ - %@",institution,start_date,end_date];
                
            }else if(indexPath.section == 7 && indexPath.row <= [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] count]-1){
                
                cell.titleLbl.text  = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] objectAtIndex:indexPath.row] valueForKey:@"role"];
                NSString *institution = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] objectAtIndex:indexPath.row] valueForKey:@"institution"];
                NSString *start_date = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] objectAtIndex:indexPath.row] valueForKey:@"startDate"];
                NSString *end_date = [[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] objectAtIndex:indexPath.row] valueForKey:@"endDate"];
                
                if([[[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] objectAtIndex:indexPath.row] valueForKey:@"isPresent"] boolValue])
                    end_date = @"Present";
                
                cell.ValueTF.text = [NSString stringWithFormat:@"%@, %@ - %@",institution,start_date,end_date];
            }
            
            cell.ValueTF.enabled = NO;
            cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
            cell.ValueTF.tag = indexPath.row + 1;
            cell.ValueTF.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            static NSString *cellIdentifier = CUSTOM_SKILLS_CELL_IDENTIFIER;
            CustomSkillsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SKILLS_CELL owner:self options:nil];
                cell = (CustomSkillsCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.titleLbl.textColor = UIColorFromRGB(0x337ab7);
            
            if(indexPath.section == 5)
                cell.titleLbl.text = @" Add Experience";
            else if(indexPath.section == 6)
                cell.titleLbl.text = @" Add Education";
            else cell.titleLbl.text = @" Add Academic  Project";
            
            cell.addButton.hidden = NO;
            
            if (SCREEN_HEIGHT == 568)
            {
                cell.widthConstant.constant = 22;
            }
            else if (SCREEN_HEIGHT == 667)
            {
                if (SYSTEM_VERSION_LESS_THAN(@"11.0"))
                {
                    cell.widthConstant.constant = 36;
                }
                else
                {
                    cell.widthConstant.constant = 28;
                    cell.button_x_constrant.constant =-1;
                }
            }
            else
            {
                cell.widthConstant.constant = 25;
                cell.button_x_constrant.constant =-5;
            }
           cell.label_x_constrant.constant = 8;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else if(indexPath.section == 8){
        if(indexPath.row == 0)
        {
            NewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell"];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewTableViewCell" owner:self options:nil];
                cell = (NewTableViewCell *)[topLevelObjects objectAtIndex:0];
            }
            [[cell viewWithTag:999] removeFromSuperview];
            
            __block CGFloat containerWidth = SCREEN_WIDTH;
            __block CGFloat padding = _tagSpacing;

            if(!tagsView)
            {
                NSArray *tagArray1 = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"skills"];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES];
                NSMutableArray *tagArray =[[tagArray1 sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                tagsView = [[UIView alloc] initWithFrame:cell.bounds];
                int yCoord=0;

                int x,y;
                x=17;y=10;
                for(int i=0; i<tagArray.count; i++)
                {
                    UIButton *button = [[UIButton alloc]init];
                    NSString *myString=[tagArray objectAtIndex:i];
                    [button setTitle:myString forState:UIControlStateNormal];
                    button.titleLabel.font = cell.font;
                    
                    CGSize size = [button systemLayoutSizeFittingSize:UILayoutFittingExpandedSize
                                        withHorizontalFittingPriority:UILayoutPriorityRequired
                                              verticalFittingPriority:UILayoutPriorityDefaultHigh];
                    
                    CGFloat maxWidth = containerWidth - (5 * padding);
                    if (size.width > maxWidth) {
                        size = CGSizeMake(maxWidth, size.height);
                    }
                    CGRect rect = button.frame;
                    rect.origin = CGPointMake(x, y);
                    rect.size = size;
                    button.frame = CGRectMake(x,y,size.width+20, size.height);;
                    x += (size.width + padding+25);
                    
                    if ((x >= containerWidth - padding) && (i > 0))
                    {
                        x = padding+17;
                        y += size.height + padding+5;
                        
                        CGRect rect = button.frame;
                        rect.origin = CGPointMake(x, y);
                        rect.size = size;
                        button.frame = CGRectMake(x,y,size.width+20, size.height);;
                        x += (size.width + padding+25);
                        
                        yCoord += size.height + padding+5;

                    }

                    button.layer.cornerRadius=5.0;
                    button.backgroundColor = UIColorFromRGB(0x337ab7);
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [button setTag:i];
                    tagsView.tag = 999;
                    [tagsView addSubview:button];
                }
                [scrollView setContentSize:CGSizeMake(100, yCoord+55)];

                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell addSubview:tagsView];
            
            return cell;
        }
        else{
            static NSString *cellIdentifier = CUSTOM_SKILLS_CELL_IDENTIFIER;
            CustomSkillsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SKILLS_CELL owner:self options:nil];
                cell = (CustomSkillsCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.titleLbl.textColor = UIColorFromRGB(0x337ab7);
            cell.titleLbl.text = @" Add Skills";
            cell.addButton.hidden = NO;
            if (SCREEN_HEIGHT == 568) {
                cell.widthConstant.constant = 22;
            }else if (SCREEN_HEIGHT == 667)
            {
                if (SYSTEM_VERSION_LESS_THAN(@"11.0"))
                {
                    cell.widthConstant.constant = 36;
                }
                else
                {
                    cell.widthConstant.constant = 28;
                    cell.button_x_constrant.constant =-1;
                }
                
            }
            else{
                cell.widthConstant.constant = 25;
                cell.button_x_constrant.constant =-5;
            }
            cell.label_x_constrant.constant = 8;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else{
        if(indexPath.row  == 0){
            static NSString *cellIdentifier = CUSTOM_SALARY_SLIDER_CELL_IDENTIFIER;
            CustomSalarySilderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SALARY_SLIDER_CELL owner:self options:nil];
                cell = (CustomSalarySilderCell *)[topLevelObjects objectAtIndex:0];
                cell.rangeSliderCustom.selectedMaximum = 10;
            }
            cell.titleLbl.text = @"Salary Range (lakhs per annum)";
            cell.rangeSliderCustom.tag = 100;
            cell.rangeSliderCustom.delegate = self ;
            cell.rangeSliderCustom.minValue = 0.0;
            cell.rangeSliderCustom.maxValue = 50.0;
            cell.rangeSliderCustom.selectedMinimum = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"minSalaryExp"] floatValue];
            cell.rangeSliderCustom.selectedMaximum = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"maxSalaryExp"] floatValue];
            cell.valueLbl.text = [NSString stringWithFormat:@"₹ %.1fL - %.1fL",[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"minSalaryExp"] floatValue],[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"maxSalaryExp"]floatValue]];
            experianceLbl = cell.valueLbl;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            static NSString *cellIdentifier = CUSTOM_SWITCH_CELL_IDENTIFIER;
            CustomSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SWITCH_CELL owner:self options:nil];
                cell = (CustomSwitchCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.titleLbl.text = @"Hide Salary Range";
            
            cell.valueSwitch.on = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"hideSalary"] boolValue];
            
            [cell.valueSwitch addTarget:self action:@selector(hideSalaryStatusUpdate:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.save_button.hidden = NO;
    CustomTextField *text_field = (CustomTextField *)textField;
    if(text_field.section == 4 && text_field.row == 0){
        [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }else{
        
        return YES;
    }
}
-(void)showPickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
    if(isPickerShown)
        return;
    
    selected_text_field = (CustomTextField *)sender;
    
//    if ([selected_text_field.text isEqualToString:@"years years"])
//    {
//        selected_text_field.text = @"0.0 years";
//    }
    
    NSString *fullString = selected_text_field.text;
    NSString *prefix = nil;
    NSString *fname, *lname ;
    if ([fullString length] >= 3)
    {
        prefix = [fullString substringToIndex:5];
    }
    
    if ([prefix isEqualToString:@"years"])
    {
        
    }
    else{
        if ([selected_text_field.text  isEqualToString: @"0 years"]) {
            fname = @"0";
            lname = @"0";
        } else {
            NSRange range = [selected_text_field.text rangeOfString:@"."];
            fname = [selected_text_field.text substringToIndex:range.location];
            lname = [selected_text_field.text substringFromIndex:range.location+1];
        }
        NSLog(@"%@ %@",fname,lname );
    }
   
    
    NSString *titleString = @"";
    
    NSMutableArray *tempArray = nil;
    NSMutableArray *tempArray1 = nil;
    int numberOfComponents = 0;
    //int idx = 0;
    
    numberOfComponents = 2;
    
    titleString = @"Select experience";
    tempArray = [CompanyHelper getYearsArray];
    tempArray1 = [CompanyHelper getMonthsArray];
    
    //idx = [CompanyHelper getJobRoleIdWithValue:[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:LOCATION_KEY]  valueForKey:@"title"] parantKey:@"locations" childKey:@"title"];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        }];
        
        [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        
        selected_text_field = (CustomTextField *)sender;
        if(!picker_object){
            picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
            if(self.tabBarController)
                [self.tabBarController.view addSubview:picker_object];
            else
                [self.view addSubview:picker_object];
            
        }
        
        [picker_object.done_button setTitle:@"Done" forState:UIControlStateNormal];
        
        
        picker_object.view_height = self.view.frame.size.height;
        picker_object.delegate = self;
        picker_object.objectsArray = tempArray;
        picker_object.subObjectsArray = tempArray1;
        picker_object.numberOfComponents = numberOfComponents;
        [picker_object.picker_view reloadAllComponents];
        [picker_object.picker_view selectRow:[fname integerValue] inComponent:0 animated:YES];
        [picker_object.picker_view selectRow:[lname integerValue] inComponent:1 animated:YES];
        
        picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
        [picker_object showPicker];
    });
    isPickerShown = YES;
}


-(void)didSelectPickerWithDoneClicked:(NSString *)value withSubRow:(NSString *)subValue forTag:(int)tag
{
    isPickerShown = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.table_view.contentInset = UIEdgeInsetsZero;
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
    
    if(tag == -1) //For cancel
        return;

    NSString *years = [[value componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString *months = [[subValue componentsSeparatedByString:@" "] objectAtIndex:0];
    
    if([years integerValue] > 0)
        selected_text_field.text = [NSString stringWithFormat:@"%@.%@ years",years,months];
    else
        selected_text_field.text = [NSString stringWithFormat:@"%@.%@ years" ,years,months];
    
    
    [[ApplicantHelper sharedInstance].paramsDictionary setObject:selected_text_field.text forKey:@"totalexperiencedisplay"];
    
    totalexperiencedisplay = [NSString stringWithFormat:@"%@",[[ApplicantHelper sharedInstance].paramsDictionary  valueForKey:@"totalexperiencedisplay"]];
    
    [FireBaseAPICalls captureMixpannelEvent:APPLICANT_EDIT_YOE];
    
    [self.table_view reloadData];
}

-(void)hideSalaryStatusUpdate:(id)sender
{
    UISwitch *switch_object = (UISwitch *)sender;
    [[ApplicantHelper sharedInstance].paramsDictionary setObject:[NSNumber numberWithBool:switch_object.isOn] forKey:@"hideSalary"];
    self.save_button.hidden = NO;
}

-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum
{
    NSString *experienceMin = [NSString stringWithFormat:@"%.1f",selectedMinimum];
    NSString *experienceMax = [NSString stringWithFormat:@"%.1f",selectedMaximum];
    experianceLbl.text = [NSString stringWithFormat:@"₹ %@L - %@L", experienceMin,experienceMax];
    
    [[ApplicantHelper sharedInstance].paramsDictionary setObject:experienceMin forKey:@"minSalaryExp"];
    [[ApplicantHelper sharedInstance].paramsDictionary setObject:experienceMax forKey:@"maxSalaryExp"];
    
    self.save_button.hidden = NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // self.save_button.hidden = NO;
    if(indexPath.section == 1){
        self.save_button.hidden = YES;

        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"resume"] length] > 0)
        {
            WRResumePreview *controller = [[WRResumePreview  alloc] initWithNibName:@"WRResumePreview" bundle:nil];
            NSURL *url = [NSURL URLWithString:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"resume"]];
            if([url.scheme isEqualToString: @"file"])
                controller.string_url = [NSString stringWithFormat:@"%@",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"resume"]];
            else
                controller.string_url = [NSString stringWithFormat:@"%@%@",IMAGE_BASE_URL,[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"resume"]];
            controller.hidesBottomBarWhenPushed = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:controller animated:YES completion:nil];
            });
        }else
            [self tapDocumentMenuView];
        
        return;
    }else if(indexPath.section == 3){
        self.save_button.hidden = NO;
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        WRChooseCompanyIndustry *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
        controller.isCommingFromEditApplicant = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if(indexPath.section == 5){
        self.save_button.hidden = YES;

        if(indexPath.row == [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] count]){
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            controller.Flag = 0;
            controller.isFirstTime = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            controller.Flag = 0;
            controller.isFirstTime = YES;
            controller.index = (int)indexPath.row;
            controller.selectedDictionary = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }else if(indexPath.section == 6){
        self.save_button.hidden = YES;

        if(indexPath.row == [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] count]){
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            controller.Flag = 1;
            controller.isFirstTime = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            controller.Flag = 1;
            controller.isFirstTime = YES;
            controller.index = (int)indexPath.row;
            controller.selectedDictionary = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }else if(indexPath.section == 7){
        self.save_button.hidden = YES;

        if(indexPath.row == [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] count]){
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            controller.Flag = 2;
            controller.isFirstTime = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            controller.Flag = 2;
            controller.index = (int)indexPath.row;
            controller.isFirstTime = YES;
            controller.selectedDictionary = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }else if(indexPath.section == 8){
        self.save_button.hidden = YES;

        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRSkillsViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRSKILLS_VIEWCONTROLLER_IDENTIFIER];
        controller.isCommingFromEditContact = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(BOOL)isHaveObject:(NSString *)key
{
    if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:key]  count] > 0)
        return YES;
    else return NO;
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.save_button.hidden = NO;
    
    if([textView.text isEqualToString:@"Enter  Summary"])
    {
        [textView setTextColor:placeHolderColor];
        [textView setText:@""];
    }
    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0 || [textView.text isEqualToString:@"Enter  Summary"]) {
        textView.text = @"Enter  Summary";
        [textView setTextColor: placeHolderColor];//2f2f2f
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *completeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    completeString = [Utility trim:completeString];
    
    if([text isEqualToString:@""]){
        [textView setTextColor: MainTextColor];//2f2f2f
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"about"];
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"coverLetter"];
        
        local_text_view_cell.wordCount.text = [NSString stringWithFormat:@"%d",(int)(150 - [completeString length])];
        return YES;
    }
    
    if([completeString length] <=150){
        [textView setTextColor: MainTextColor];//2f2f2f
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"about"];
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"coverLetter"];
        
        local_text_view_cell.wordCount.text = [NSString stringWithFormat:@"%d",(int)(150 - [completeString length])];
        return YES;
    }else{
        local_text_view_cell.wordCount.text = @"0";
        return NO;}
}

-(void)showPickerOption:(id)sender
{
    
    self.save_button.hidden = NO;
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
    self.save_button.hidden = NO;
    
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

-(void)popCamera:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.edgesForExtendedLayout = UIRectEdgeAll;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[[UIApplication sharedApplication].delegate window] rootViewController] presentViewController:imagePickerController animated:YES completion:nil];
    });
}

-(void)camDenied
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    
    if(buttonIndex == 2){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    [FireBaseAPICalls captureMixpannelEvent:APPLICANT_ADD_PHOTO];
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
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    //    [ApplicantHelper sharedInstance].profile_image = croppedImage;
    [self.navigationController popViewControllerAnimated:YES];
    UIImage *image = [Utility resizeImage:croppedImage];
    profile_image.image  = image;
    NSData *imageData = UIImageJPEGRepresentation(image,0.5);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"cached"]];
    
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        NSLog((@"Failed to cache image data to disk"));
    }
    else
    {
        NSLog(@"the cachedImagedPath is %@",imagePath);
        [self uploadProfilePicWithURL:imagePath];
    }
    [self.table_view reloadData];
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
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", API_BASE_URL,UPLOAD_PROFILE_PIC] parameters:parmas constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
                      dispatch_async(dispatch_get_main_queue(), ^{});
                  }completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          
                          NSLog(@"%@ %@", response, responseObject);
                          if([[responseObject valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
                          {
                              [[ApplicantHelper sharedInstance] setParamsValue:[[responseObject valueForKey:@"data"] valueForKey:@"filePath"] forKey:@"pic"];
                              [[ApplicantHelper sharedInstance] setParamsValue:[[responseObject valueForKey:@"data"] valueForKey:@"filePath"] forKey:@"picture"];
                              
                              [self.table_view reloadData];
                          }
                      }
                  }];
    [uploadTask resume];
}

/*
 -(void)calculateExperiance
 {
 NSMutableArray *experiance_array = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"];
 
 if(experiance_array == nil)
 experiance_array = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userExperienceSet"];
 
 if(experiance_array.count == 0 || experiance_array == nil){
 //[[ApplicantHelper sharedInstance] setParamsValue:@"0" forKey:@"totalexperience"];
 //[[ApplicantHelper sharedInstance] setParamsValue:@"0" forKey:@"display"];
 }else{
 NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
 for(NSMutableDictionary *dic_object in experiance_array){
 NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
 [dictionary setObject:[dic_object valueForKey:@"startDate"] forKey:@"start"];
 
 if([[dic_object valueForKey:@"isPresent"] boolValue])
 [dictionary setObject:[Utility getStringWithDate:[NSDate date] withFormat:@"MMM yyyy"] forKey:@"end"];
 else
 [dictionary setObject:[dic_object valueForKey:@"endDate"] forKey:@"end"];
 [tempArray addObject:dictionary];
 }
 
 NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
 [params setObject:tempArray forKey:@"experience"];
 [[ApplicantHelper sharedInstance] getApplicantProfile:self requestType:102];
 
 }
 }
 
 */


-(UIView *)getProgressViewInHeader
{
    UIView *view_bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, isSectionHeaderShow?199:60)];
    int y_postions = 0;
    if(isSectionHeaderShow)
        y_postions = 140;
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10+y_postions, self.view.frame.size.width, 30)];
    label_title.text = [NSString stringWithFormat:@"Profile percentage - %.0f%%",[ApplicantHelper sharedInstance].profilePercentage];
    label_title.font = [UIFont fontWithName:GlobalFontSemibold size:15.0f];
    label_title.textColor = UIColorFromRGB(0x6A6A6A);
    label_title.textAlignment = NSTextAlignmentCenter;
    [view_bg addSubview:label_title];
    
    YLProgressBar  *progressBarRoundedFat = [[YLProgressBar alloc] initWithFrame:CGRectMake(20, 40+y_postions, self.view.frame.size.width-40, 10)];
    if([ApplicantHelper sharedInstance].profilePercentage <= 0)
        progressBarRoundedFat.progress = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"percentage"] floatValue]/100;
    else
        progressBarRoundedFat.progress = [ApplicantHelper sharedInstance].profilePercentage/100;

    progressBarRoundedFat.progressTintColor = UIColorFromRGB(0x337ab7);
    progressBarRoundedFat.trackTintColor = placeHolderColor;
    progressBarRoundedFat.hideGloss = YES;
    progressBarRoundedFat.progressStretch = YES;
    progressBarRoundedFat.uniformTintColor = YES;
    progressBarRoundedFat.hideStripes = YES;
    [view_bg addSubview:progressBarRoundedFat];
    return view_bg;
}


@end



