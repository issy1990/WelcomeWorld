//
//  WRLoginViewController.m
//  workruit
//
//  Created by Admin on 11/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRLoginViewController.h"
#import "WRForgotPasswordController.h"
#import "HomeCustomButton.h"
#import "WRVerifyMobileController.h"
#import "WRJobFunctionViewController.h"
#import "WRAddExperianceController.h"
#import "WRNotesViewController.h"
#import "Mixpanel/Mixpanel.h"
#import "LoadDataManager.h"
#import <Crashlytics/Crashlytics.h>

@interface WRLoginViewController ()<UITextFieldDelegate>
{
    NSString *user_name,*password;
    UITextField *userNameTF, *passWordTF;
    IBOutlet UIView * myView;
    UITabBarController *tabBarController;
}
@end

@implementation WRLoginViewController

-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"lastCreatedJobId"];
    [defaults removeObjectForKey:@"lastCreatedJobName"];
    [defaults removeObjectForKey:@"lastCreatedJobObject"];
    [defaults removeObjectForKey:@"showJobHeader"];
    [defaults removeObjectForKey:@"saveNewJobIDs"];
    [defaults removeObjectForKey:@"savedExternalJobsValue"];
    [defaults removeObjectForKey:@"firstLoad"];
    [defaults removeObjectForKey:@"locationId"];
    [defaults removeObjectForKey:@"jobTypeId"];
    [defaults removeObjectForKey:@"CheckDay_ExtJobs"];    
    [defaults synchronize];
}

-(void)viewDidAppear:(BOOL)animated
{
    [userNameTF becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    user_name = @"m5@workruit.com";
//    password = @"welcomeworld";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:UPDATEDATANOTIFICATION object:nil];

    UIView *borderLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    [borderLine1 setBackgroundColor:DividerLineColor];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    UIView *borderLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    [borderLine2 setBackgroundColor:DividerLineColor];
    
    HomeCustomButton *login_button = [HomeCustomButton buttonWithType:UIButtonTypeCustom];
    [login_button setBackgroundColor:[UIColor colorWithRed:51/255.0f green:122/255.0f blue:183/255.0f alpha:1.0f]];
    [login_button setTitle:@"Login" forState:UIControlStateNormal];
    login_button.titleLabel.font = [UIFont fontWithName:GlobalFontSemibold size:15.0f];
    login_button.layer.cornerRadius = 25.0f;
    login_button.frame = CGRectMake(10, 20, 300, 50);
    login_button.center = CGPointMake(self.view.center.x, 40);
    [login_button addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:login_button];
    
    UIButton *forgot_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgot_button setTitle:@"Forgot your password?" forState:UIControlStateNormal];
    forgot_button.titleLabel.font = [UIFont fontWithName:GlobalFontRegular size:15.0f];
    [forgot_button setTitleColor:[UIColor colorWithRed:51/255.0f green:122/255.0f blue:183/255.0f alpha:1.0f] forState:UIControlStateNormal];
    forgot_button.layer.cornerRadius = 5.0f;
    forgot_button.frame = CGRectMake(20, 70, self.view.frame.size.width-40, 40);
    [forgot_button addTarget:self action:@selector(forgotButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:forgot_button];

    [footerView addSubview:borderLine2];
	
	UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(20, 80, 100, 30);
	[button setTitle:@"Crash" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(crashButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[footerView addSubview:button];
	
	
    self.table_view.tableHeaderView = borderLine1;
    self.table_view.tableFooterView = footerView;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];

    [Utility setThescreensforiPhonex:myView];
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];

	


}

- (IBAction)crashButtonTapped:(id)sender {
	[[Crashlytics sharedInstance] crash];
	NSLog(@"crash test");
}


-(void)loginButtonAction:(id)sender
{
    NSString *validation_message = @"";
    if([[Utility trim:userNameTF.text] length]  <=0 || [[Utility trim:passWordTF.text] length] <= 0)
        validation_message = @"User name password required to login.";
    
    if([validation_message length] > 0){
        [CustomAlertView showAlertWithTitle:@"Error" message:validation_message OkButton:@"OK" delegate:self];
        return;
    }

    //NSLog(@"Login Button press");
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:userNameTF.text forKey:@"username"];
    [params setObject:passWordTF.text forKey:@"password"];
    if([[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID])
        [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID] forKey:@"regdId"];
    [params setObject:DEVICE_TYPE_STRING forKey:@"deviceType"];
    [params setObject:[Utility getAppVersionNumber] forKey:@"appVersion"];

    if([Utility isComapany]){
        [params setObject:@"recruiter" forKey:@"role"];
         [[CompanyHelper sharedInstance] loginComapny:self requestType:121212 params:params];
    }else{
        [params setObject:@"jobSeeker" forKey:@"role"];
        [[CompanyHelper sharedInstance] loginComapny:self requestType:121213 params:params];
    }
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];

    if(tag == 121212 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY] && [Utility isComapany])
    {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"FirstTimeSignIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
       
        [FireBaseAPICalls captureScreenDetails:COMPANY_LOGIN];

        [Utility saveToDefaultsWithKey:SESSION_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:SESSION_ID]]];
        
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID]);
        
        NSMutableDictionary *response = [[[data valueForKey:@"data"]  valueForKey:@"company"] mutableCopy];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"email"] forKey:@"email"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"firstname"] forKey:@"firstname"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[[data valueForKey:@"data"] valueForKey:@"firstname"] forKey:FIRST_NAME_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"lastname"] forKey:@"lastname"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"jobRoleId"] forKey:@"jobRoleId"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"recruiterCompanyName"] forKey:@"recruiterCompanyName"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"recruiterCompanyName"] forKey:COMPANY_NAME_KEY];
        [response setObject:[Utility removeNullFromObject:[[[[data valueForKey:@"data"] valueForKey:@"company"]valueForKey:@"location"] valueForKey:@"title"]] forKey:LOCATION_NAME_KEY];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"telephone"] forKey:@"telephone"];
        [response setObject:[[[data valueForKey:@"data"] valueForKey:@"recruiterSettings"] mutableCopy] forKey:@"userSettings"];
        NSLog(@"%@",response);
        [[CompanyHelper sharedInstance].params setObject:[response valueForKey:@"companyIndustriesSet"] forKey:@"companyIndustriesSet"];
        NSLog(@"%@",[Utility removeNullFromObject:[data valueForKeyPath:@"data.company.picture"]]);
        
        if(![Utility isNullValueCheck:[data valueForKeyPath:@"data.company.pic"]]) //if not null
        {
            [response setObject:[Utility removeNullFromObject:[data valueForKeyPath:@"data.company.pic"]] forKey:@"picture"];
            [response setObject:[Utility removeNullFromObject:[data valueForKeyPath:@"data.company.pic"]] forKey:@"pic"];
        }
        else
             [response setObject:@"" forKey:@"pic"];
        
        if(![Utility isNullValueCheck:[data valueForKeyPath:@"data.company.picture"]]) //if not null
        {
            [response setObject:[Utility removeNullFromObject:[data valueForKeyPath:@"data.company.picture"]] forKey:@"picture"];
            [response setObject:[Utility removeNullFromObject:[data valueForKeyPath:@"data.company.picture"]] forKey:@"pic"];
            
        }else
            [response setObject:@"" forKey:@"picture"];

        [Utility saveToDefaultsWithKey:RECRUITER_REGISTRATION_ID value:[NSString stringWithFormat:@"%@",[[data valueForKey:@"data"] valueForKey:@"userId"]]];
        
        //NSLog(@"--------- data.company.companyId : %d ----------",[[data valueForKeyPath:@"data.company.companyId"] intValue]);

        [Utility saveToDefaultsWithKey:SAVE_COMPANY_ID value:[NSString stringWithFormat:@"%@",[Utility removeNullFromObject:[[[data valueForKey:@"data"] valueForKey:@"company"] valueForKey:@"companyId"]]]];

        [CompanyHelper sharedInstance].params = response;
        [Utility saveCompanyObject:[CompanyHelper sharedInstance]];

        if([[data valueForKeyPath:@"data.company.companyIndustriesSet"] count]  > 0){
            [self createMeTabBarController];
        }else{
            
            
            
            [self editProfileScreen:nil];
        }

        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        [Utility getMixpanelData:COMPANY_GENERAL_LOGIN setProperties:userName];
   
    
    }else if(tag == 121213 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY] && ![Utility isComapany]){
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"FirstTimeSignIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_USERLOGIN];
        
        [FireBaseAPICalls captureScreenDetails:APPLICANT_LOGIN];
        
        [Utility saveToDefaultsWithKey:SESSION_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:SESSION_ID]]];

        ;
        NSMutableDictionary *responseData = [[data valueForKey:@"data"] mutableCopy];

        NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithCapacity:0];
        [response setObject:[responseData valueForKey:@"coverLetter"] forKey:@"coverLetter"];
        [response setObject:[responseData valueForKey:@"coverLetter"] forKey:@"about"];
        [response setObject:[responseData valueForKey:@"deviceType"] forKey:@"deviceType"];
        [response setObject:[responseData valueForKey:@"email"] forKey:@"email"];
        [response setObject:[responseData valueForKey:@"firstname"] forKey:@"firstname"];
        [response setObject:[responseData valueForKey:@"jobFunctions"] forKey:@"jobfunctions"];
        [response setObject:[responseData valueForKey:@"lastname"] forKey:@"lastname"];
        [response setObject:[responseData valueForKey:@"location"] forKey:@"location"];
        [response setObject:[responseData valueForKey:@"status"] forKey:@"status"];
        [response setObject:[responseData valueForKey:@"telephone"] forKey:@"telephone"];
        [response setObject:[NSString stringWithFormat:@"%.1f",[[responseData valueForKey:@"totalExperience"] floatValue]] forKey:@"totalexperience"];
        [response setObject:[NSString stringWithFormat:@"%@",[responseData valueForKey:@"totalExperienceText"]] forKey:@"totalExperienceText"];
        [response setObject:[responseData valueForKey:@"userAcademic"] forKey:@"academic"];
        [response setObject:[[responseData valueForKey:@"userSettings"] mutableCopy] forKey:@"userSettings"];
        [response setObject:[[responseData  valueForKey:@"userPreferences"] mutableCopy] forKey:@"userPreferences"];
        [response setObject:[[responseData valueForKey:@"totalExperienceDisplay"] mutableCopy] forKey:@"totalexperiencedisplay"];
        [response setObject:[responseData valueForKey:@"resume"] forKey:@"resume"];

        if ([responseData valueForKey:@"lastUpdatedDate"]!=nil)
        {
            [response setObject:[responseData valueForKey:@"lastUpdatedDate"] forKey:@"lastUpdatedDate"];
        }
        else{
            [response setObject:@"NA" forKey:@"lastUpdatedDate"];
        }
        
       // [response setObject:[data valueForKey:@"percentage"] forKey:@"percentage"];

        NSDictionary * dictValue = [responseData valueForKey:@"userPreferences"];
        
        if ([dictValue  isEqual:@""])
        {
            [[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"savedExternalJobsValue"];
        }
        else{
            [[NSUserDefaults standardUserDefaults]setValue:[responseData valueForKeyPath:@"userPreferences.hide_ext"] forKey:@"savedExternalJobsValue"];
        }
        
        NSLog(@"my respones:%@",response);
        if(![Utility isNullValueCheck:[responseData valueForKey:@"pic"]]) //if not null
            [response setObject:[responseData valueForKey:@"pic"] forKey:@"pic"];
        else
            [response setObject:@"" forKey:@"pic"];
        
        if([[responseData valueForKey:@"userJobTitle"] length] > 0)
            [response setObject:[responseData valueForKey:@"userJobTitle"] forKey:@"title"];
        
       NSMutableArray *educationArray = [[responseData valueForKey:@"userEducationSet"] mutableCopy];
        
        for(NSMutableDictionary *dictionary in educationArray){
            NSMutableDictionary *degree_object = [dictionary valueForKey:@"degree"];
            NSString *short_title = [degree_object valueForKey:@"shortTitle"];
            NSString *degree_name = [degree_object valueForKey:@"title"];
            
            [degree_object removeObjectForKey:@"shortTitle"];
            [degree_object removeObjectForKey:@"title"];
            
            [dictionary setObject:short_title forKey:@"degree_short_name"];
            [dictionary setObject:degree_name forKey:@"degree_name"];
        }
        [response setObject:educationArray forKey:@"education"];
        [response setObject:[responseData valueForKey:@"userExperienceSet"] forKey:@"experience"];
        
        NSMutableArray *array = [responseData valueForKey:@"userSkillsSet"];
        NSMutableArray *skills_array = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSMutableDictionary *dictionary in array){
            [skills_array addObject:[dictionary valueForKey:@"title"]];
        }
        [response setObject:skills_array forKey:@"skills"];
        
        [Utility saveToDefaultsWithKey:APPLICANT_REGISTRATION_ID value:[NSString stringWithFormat:@"%@",[responseData valueForKey:@"userId"]]];
        [ApplicantHelper sharedInstance].paramsDictionary = response;
        
        NSMutableDictionary *tempDicationary = [data  mutableCopy];

        if([[tempDicationary valueForKey:@"percentage"] floatValue] > 0)
            [ApplicantHelper sharedInstance].profilePercentage = [[tempDicationary valueForKey:@"percentage"] floatValue];
        
        [ApplicantHelper sharedInstance].halfProfile = [[tempDicationary valueForKey:@"halfProfile"] boolValue];
        
        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];

       // [self getTheDataFromTheFirebase:tempDicationary];
        
        
//        // Get the data from the firebase
//        FIRDatabaseReference *chatReference12 = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"/user/%@",[[NSUserDefaults standardUserDefaults]valueForKey:APPLICANT_REGISTRATION_ID]]];
//        [chatReference12 observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
//         {
//             if (snapshot.value != [NSNull null]) {
//            [[NSUserDefaults standardUserDefaults]setObject:[[snapshot value]valueForKey:@"_date"] forKey:@"CheckDay_ExtJobs"];
//                 [self getTheDataFromTheFirebase:tempDicationary];
//             }
//             else{
//                 [self getTheDataFromTheFirebase:tempDicationary];
//             }
//         }];
        
        //[self navigateToScreen:tempDicationary];
        //[[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"First"];

        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"first_time"];
        
        
        [self getTheDataFromTheFirebase:tempDicationary];

    }
    else if([[data valueForKey:STATUS_KEY] isEqualToString:FAILD_KEY]){
        [CustomAlertView showAlertWithTitle:@"Error" message:[data valueForKey:@"msg"] OkButton:@"Ok" delegate:self];
    }
}
-(void)getTheDataFromTheFirebase:(NSMutableDictionary *)datDict
{
    // Get the data from the firebase
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
   NSMutableArray*  firebaseARray= [[NSMutableArray alloc]init];
    NSMutableArray* mainfirebasAryy =[[NSMutableArray alloc]init];
    
    FIRDatabaseReference *chatReference12 = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"/users/%@",[[NSUserDefaults standardUserDefaults]valueForKey:APPLICANT_REGISTRATION_ID]]];
    [chatReference12 keepSynced:YES];
    [chatReference12 observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if (snapshot.value != [NSNull null])
         {
             for(snapshot in snapshot.children){
                 [firebaseARray addObject:snapshot];
             }
             
             for (int i =0; i<[firebaseARray count]; i++)
             {
                 FIRDataSnapshot *snapShot = [firebaseARray objectAtIndex:i];
                 if([[snapShot value] isKindOfClass:[NSDictionary class]])
                 {
                     id obj = snapShot.value[@"_id"];
                     [mainfirebasAryy addObject:obj];
                 }
             }
             [[NSUserDefaults standardUserDefaults]setObject:mainfirebasAryy forKey:@"saveNewJobIDs"];
             [[NSUserDefaults standardUserDefaults]synchronize];
             
             [self navigateToScreen:datDict];
         }else{
            // [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CheckDay_ExtJobs"];
             [self navigateToScreen:datDict];
         }
     }];
    //Need to update latest call back here
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag {

}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag withData:(NSDictionary *)data
{
    if(tag == -1000)
    {
        [Utility saveToDefaultsWithKey:SESSION_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:SESSION_ID]]];

        data = [[data valueForKey:@"data"] mutableCopy];
        NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithCapacity:0];
        [response setObject:[data valueForKey:@"deviceType"] forKey:@"deviceType"];
        [response setObject:[data valueForKey:@"email"] forKey:@"email"];
        [response setObject:[data valueForKey:@"firstname"] forKey:@"firstname"];
        [response setObject:[data valueForKey:@"jobFunctions"] forKey:@"jobfunctions"];
        [response setObject:[data valueForKey:@"lastname"] forKey:@"lastname"];
        [response setObject:[data valueForKey:@"status"] forKey:@"status"];
        [response setObject:[data valueForKey:@"telephone"] forKey:@"telephone"];
        [response setObject:@"0" forKey:@"totalexperience"];
        [response setObject:[data valueForKey:@"userAcademic"] forKey:@"academic"];
        [response setObject:[[data valueForKey:@"userSettings"] mutableCopy] forKey:@"userSettings"];

        [Utility saveToDefaultsWithKey:APPLICANT_REGISTRATION_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:@"userId"]]];
        
        
        [ApplicantHelper sharedInstance].isPartialLogin = YES;
        [ApplicantHelper sharedInstance].paramsDictionary  = response;//[[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_OBJECT_PARAMS] mutableCopy];

        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRVerifyMobileController *controller =[mystoryboard instantiateViewControllerWithIdentifier:WRVERIFY_MOBILE_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:YES];
    
    }else if(tag == -2000){
        [FireBaseAPICalls captureScreenDetails:COMPANY_LOGIN];
        [Utility saveToDefaultsWithKey:SESSION_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:SESSION_ID]]];
        
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID]);
        
        NSMutableDictionary *response = [[[data valueForKey:@"data"]  valueForKey:@"company"] mutableCopy];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"email"] forKey:@"email"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"firstname"] forKey:@"firstname"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"lastname"] forKey:@"lastname"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"jobRoleId"] forKey:@"jobRoleId"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"recruiterCompanyName"] forKey:@"recruiterCompanyName"];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"recruiterCompanyName"] forKey:COMPANY_NAME_KEY];
        [response setObject:[Utility removeNullFromObject:[[[[data valueForKey:@"data"] valueForKey:@"company"]valueForKey:@"location"] valueForKey:@"title"]] forKey:LOCATION_NAME_KEY];
        [response setObject:[[data valueForKey:@"data"] valueForKey:@"telephone"] forKey:@"telephone"];
        [response setObject:[[[data valueForKey:@"data"] valueForKey:@"recruiterSettings"] mutableCopy] forKey:@"userSettings"];
        [Utility saveToDefaultsWithKey:RECRUITER_REGISTRATION_ID value:[NSString stringWithFormat:@"%@",[[data valueForKey:@"data"] valueForKey:@"userId"]]];
        
        //NSLog(@"--------- data.company.companyId : %d ----------",[[data valueForKeyPath:@"data.company.companyId"] intValue]);
        
        [Utility saveToDefaultsWithKey:SAVE_COMPANY_ID value:[NSString stringWithFormat:@"%@",[Utility removeNullFromObject:[[[data valueForKey:@"data"] valueForKey:@"company"] valueForKey:@"companyId"]]]];
        
        [CompanyHelper sharedInstance].params = response;
        [Utility saveCompanyObject:[CompanyHelper sharedInstance]];

        [CompanyHelper sharedInstance].isPartialLogin = YES;

        WRCheckYourEmail *check_your_email = [[UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil] instantiateViewControllerWithIdentifier:WRCHECK_YOUR_EMAIL_IDENTIFIER];
        [self.navigationController pushViewController:check_your_email animated:YES];
    }
}
-(void)editProfileScreen:(id)sender
{
    if([Utility isComapany]) {
        [CompanyHelper sharedInstance].isPartialLogin = YES;
        [CompanyHelper sharedInstance].params  = [[[NSUserDefaults standardUserDefaults] valueForKey:COMPANY_OBJECT_PARAMS] mutableCopy];

        NSLog(@"%d",[[[NSUserDefaults standardUserDefaults] valueForKey:SAVE_COMPANY_ID] intValue]);
        
        if([[[NSUserDefaults standardUserDefaults] valueForKey:SAVE_COMPANY_ID] intValue] <= 0){
            WRCreateCompanyProfile *company_profile = [[UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil] instantiateViewControllerWithIdentifier:WRCREATE_COMPANY_PROFILE_IDENTIFIER];
            [self.navigationController pushViewController:company_profile animated:YES];
        }else{
            
            NSMutableArray *arrayIndustries = [[CompanyHelper sharedInstance].params valueForKey:@"companyIndustriesSet"];
            if (arrayIndustries.count == 0) {
                
                UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
                WRChooseCompanyIndustry *industry = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
              
                industry.isNextButtonHide = NO;
                [self.navigationController pushViewController:industry animated:YES];
            }
            else{
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
            WREditCompanyProfile *edit_profile_controller = [mystoryboard instantiateViewControllerWithIdentifier:WREDIT_COMPANY_PROFILE_IDENTIFIER];
            edit_profile_controller.isCommingFromFlag = 300;
            edit_profile_controller.isSignUpProcess = YES;
            [self.navigationController pushViewController:edit_profile_controller animated:YES];
            }
        }
    }else{
        [ApplicantHelper sharedInstance].isPartialLogin = YES;
        [ApplicantHelper sharedInstance].paramsDictionary  = [[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_OBJECT_PARAMS] mutableCopy];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRLocationViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_LOCATION_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)createMeTabBarController
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISLOGEDIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRCandidateProfileController *jobsController =   [mystoryboard instantiateViewControllerWithIdentifier:WRCANDIDATE_PROFILE_CONTROLLER_IDENTIFIER];
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:jobsController];
    navController1.navigationBarHidden = YES;
    
    if([Utility isComapany]){
        jobsController.title = @"Applicants";
    }else{
        jobsController.title = @"Jobs";
    }
    
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
    
    tabBarController=[[UITabBarController alloc] init];
    tabBarController.tabBar.tintColor  = UIColorFromRGB(0x337ab7);
    tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    tabBarController.tabBar.barTintColor = [UIColor whiteColor];
    tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2,navController3,nil];
    [self.navigationController pushViewController:tabBarController animated:YES];
    
    [LoadDataManager sharedInstance].tabBarController = tabBarController;
    [[LoadDataManager sharedInstance] getApplicationData];
}

-(void)updateData
{
    if(![[NSUserDefaults standardUserDefaults] valueForKey:ISLOGEDIN] || !tabBarController)
        return;
    
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] updateUnreadCount];

    NSMutableArray *arrayObjects1 =  [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list order by last_update_date DESC"]];
    NSInteger unreadConversations = 0;
    
    for(NSDictionary *dictionary_object1 in arrayObjects1){
        NSString *count = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_unread_count",[dictionary_object1 valueForKey:@"channel_name"]]];
        if([count intValue] > 0)
            unreadConversations ++;
    }
    
    if(unreadConversations > 0){
        [[[[tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%ld",(long)unreadConversations]];
        
        for (UIView *tabBarButton in tabBarController.tabBar.subviews)
        {
            for (UIView *badgeView in tabBarButton.subviews)
            {
                NSString *className = NSStringFromClass([badgeView class]);
                if ([className rangeOfString:@"BadgeView"].location != NSNotFound)
                {
                    badgeView.layer.transform = CATransform3DIdentity;
                    badgeView.layer.transform = CATransform3DMakeTranslation(-8.0, 0.0, 1.0);
                }
            }
        }
    } else {
        [[[[tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:nil];
    }
}

-(void)forgotButtonAction:(id)sender
{
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
    WRForgotPasswordController *controller_object = [mystoryboard instantiateViewControllerWithIdentifier:WRFORGOT_PASSWORD_CONTROLLER_IDENTIFIER];
    [self.navigationController pushViewController:controller_object animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
    CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
        cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        
    }
    
    cell.ValueTF.delegate = self;
    cell.ValueTF.tag = indexPath.row;
    if(indexPath.row == 0){
        userNameTF =cell.ValueTF;
        if([Utility isComapany])
            cell.titleLbl.text = @"Work Email";
        else
            cell.titleLbl.text = @"Email Address or Phone Number";
      
        //-----
    
     if([Utility isComapany]){
            //user_name = @"m1@getrely.co";
            //cell.ValueTF.text = @"m1@getrely.co";
            cell.ValueTF.placeholder = @"Email Address";
        }else{
//            user_name = @"mac1@workruit.com";
   //         cell.ValueTF.text = @"mac1@workruit.com";
            cell.ValueTF.placeholder = @"Email Address or Phone Number";
        }
        //-----
        
        cell.ValueTF.secureTextEntry = NO;
        cell.ValueTF.keyboardType =  UIKeyboardTypeEmailAddress;
        cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        cell.ValueTF.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.ValueTF.returnKeyType = UIReturnKeyNext;
    }else{
        passWordTF =cell.ValueTF;

        cell.titleLbl.text = @"Password";
        cell.ValueTF.placeholder = @"Password";

        //-----
       //
            //cell.ValueTF.text = @"welcomeworld";
            //password = @"welcomeworld";
        //-----
        
        cell.ValueTF.secureTextEntry = YES;
        cell.ValueTF.keyboardType =  UIKeyboardTypeDefault;
        cell.ValueTF.returnKeyType = UIReturnKeyDone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    CreateCompanyCustomCell * currentCell = (CreateCompanyCustomCell *) textField.superview.superview;
    NSIndexPath * currentIndexPath = [self.table_view indexPathForCell:currentCell];
    
    if (currentIndexPath.row != 1) {
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:0];
        CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
        [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [nextCell.ValueTF becomeFirstResponder];
    }else [textField resignFirstResponder];
        
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];
    if(textField.tag == 0)
        user_name = completeString;
    else
        password = completeString;
    return YES;
}

-(void)navigateToScreen:(NSDictionary *)dictionary
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([[dictionary valueForKey:@"screen"] isEqualToString:@"location"]){

        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRLocationViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_LOCATION_VIEW_CONTROLLER_IDENTIFIER];
        controller.isComingFromSignUpProcess = 100;
      
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    else if([[dictionary valueForKey:@"screen"] isEqualToString:@"jobFunction"]){
    
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRJobFunctionViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:@"WRJobFunctionViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    
    }
    else if([[dictionary valueForKey:@"screen"] isEqualToString:@"skills"]){
    
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRSkillsViewController *controller1 = [mystoryboard instantiateViewControllerWithIdentifier:WRSKILLS_VIEWCONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller1 animated:YES];
    }
    
    /*else if([[dictionary valueForKey:@"userExperienceSet"] count] <= 0 && [[dictionary valueForKey:@"userEducationSet"] count] <= 0){
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:YES];
    
    }else if([[dictionary valueForKey:@"userEducationSet"] count] <= 0){
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
        controller.Flag = 1;
        [self.navigationController pushViewController:controller animated:YES];
    
    }else if([[dictionary valueForKey:@"coverLetter"] length] <= 0){
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRNotesViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:@"WRNotesViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
     */
    
    
    
    else{
        [self createMeTabBarController];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
