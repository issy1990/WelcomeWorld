//
//  WRCandidateProfileController.m
//  workruit
//
//  Created by Admin on 10/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

#import "WRCandidateProfileController.h"
#import "WRACMatchScreen.h"
#import "GoodLuckCardViewController.h"
#import "LoadOtherJobsViewController.h"

static const NSUInteger externalJobsFetchLimit = 8;
static const NSUInteger externalJobsPerDayLimit = 7;
static const NSString *actionCountKey = @"actionCount";


@interface WRCandidateProfileController ()<YSLDraggableCardContainerDelegate, YSLDraggableCardContainerDataSource,HTTPHelper_Delegate>{
    
    NSMutableArray *profilesForJobsArray;
    
    NSInteger swipe_index;
    
    BOOL checkLoginStatus;
    BOOL isFirstLoad;
    
    IBOutlet UIView * myView;
    NSMutableArray * savedArray;
    NSMutableDictionary * savedDict, * nodataDict;
    NSMutableArray *results;
    NSMutableArray  * firebaseARray, * mainfirebasAryy;
}

@property (nonatomic, strong)NSNumber *countOfActions;
@property (nonatomic, assign)NSUInteger skipIndex;
@property (nonatomic, assign)BOOL fetchPending;

@end

@implementation WRCandidateProfileController
@synthesize demoCardArray;

-(IBAction)createNewJobAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if([Utility isComapany])
    {
        if([btn.titleLabel.text isEqualToString:@"Change Preferences"])
        {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Preferences"];
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:RECRUITER_REGISTRATION_ID];
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            
            [Utility getMixpanelData:COMPANY_HOME_JOBS_NOAPPLICANTS_PREFCLICK setProperties:userName];
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToPrefrencesScreen:0];
            return;
        }
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:COMPANY_HOME_POSTJOBCLICK setProperties:userName];
        
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRCreateNewJobController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRCREATE_NEW_JOB_CONTROLLER_IDENTIFIER];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        if ([btn.titleLabel.text isEqualToString:@"Edit Account"])
        {
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:100];
        }
        else{
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:101];
        }
    }
}

//Anwer Hussain
//-(void)loadJobsFromServer
//{
//    [[CompanyHelper sharedInstance] getApplicantProfilesWithDelegate:self requestType:jobsArray?-105:105];
//}



-(IBAction)goToPreferences:(id)sender
{
    self.tabBarController.selectedIndex = 2;
    UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
    [[[controller viewControllers] firstObject] moveToPrefrencesScreen:0];
    return;
}

-(IBAction)onClickMovedToPreferces:(id)sender
{
    if([[self.navigationController topViewController] isKindOfClass:[WRPreferencesController class]])
        return;
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
    WRPreferencesController *prefrence_controller = [mystoryboard instantiateViewControllerWithIdentifier:WRPREFERECES_CONTROLER_IDENTIFIER];
    prefrence_controller.flag = (int)(100 + index);
    [self.navigationController pushViewController:prefrence_controller animated:YES];
}
-(void)reloadTheData
{
    self.welcomeToView.hidden = YES;
    isFirstLoad = YES;
    
    if([Utility isComapany])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *lastCreatedJobId = [defaults valueForKey:@"lastCreatedJobId"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([lastCreatedJobId intValue]  <=  0)
            [[CompanyHelper sharedInstance] getApplicantProfilesWithDelegate:self requestType:102];
        else{
            NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:PROFILEFORJOBARRAY];
            profilesForJobsArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:RECRUITER_REGISTRATION_ID];
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            
            [Utility getMixpanelData:COMPANY_HOME_POSTJOBVIEW setProperties:userName];
            
            
            if([CompanyHelper sharedInstance].loadJobCardsWithPrefreceSettings)
            {
                NSLog(@"********* Prefreces **********");
                profilesForJobsArray = [CompanyHelper sharedInstance].companyProfiles;
                
                if([profilesForJobsArray count] == 0)
                {
                    [self callRecurutorPrefrences];
                }
            } else {
                NSLog(@"********* Default **********");
                [[CompanyHelper sharedInstance] getProfilesForJob:self requestType:100];
            }
            
            if(_container)
                [_container reloadCardContainer];
            else
                [self reloadTheContainerView];
            
            if([profilesForJobsArray count] == 0)
            {
                //  self.welcomeToView.hidden = NO;
                [self bindTheMessagesToUI:nil];
                NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:FIRST_NAME_KEY];
                NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                            valueForKey:RECRUITER_REGISTRATION_ID];
                
                NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
                
                [Utility getMixpanelData:COMPANY_HOME_JOBS_NOAPPLICANTS setProperties:userName];
                
                [self.create_job_btn setTitle:@"Change Preferences" forState:UIControlStateNormal];
            }
            else self.welcomeToView.hidden = YES;
        }
    }
    else
    {
        NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:USERJOBSFORAPPLICANTARRAY];
        profilesForJobsArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
        [[ApplicantHelper sharedInstance] getUserJobsForApplicant:self requestType:103];
        
        if([profilesForJobsArray count] == 0){
            
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:APPLICANT_REGISTRATION_ID];
            
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            [Utility getMixpanelData:APPLICANT_JOBS_NOJOBS setProperties:userName];
            
            [self.create_job_btn setTitle:@"Edit Profile" forState:UIControlStateNormal];
        }
        
        if(_container)
            [_container reloadCardContainer];
        else
            [self reloadTheContainerView];
    }
    
    if(![Utility notificationServicesEnabled]){
        ConnectionManager *conn_manager = [[ConnectionManager alloc] init];
        conn_manager.delegate = self;
        [conn_manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,VERSION_URL] WithParams:nil forRequest:-111 controller:self httpMethod:HTTP_GET];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![Utility isComapany]) {
        [self refreshJobsActionCountForToday];
    }
    self.welcomeToView.hidden = YES;
    
    [FireBaseAPICalls captureMixpannelEvent:[Utility isComapany]?COMPANY_APPLICANTS:APPLICANTS_JOBS];
    
    if (isFirstLoad)
        [self reloadTheData];
    
    [self loadtheHeaderData];
    
    
    [self checkLoginStatus];
}
-(void)loadtheHeaderData
{
    if([Utility isComapany])
    {
        // NSString *jobFunction_name = [CJCompanyHelper getJobRoleIdWithidx:[[[NSUserDefaults standardUserDefaults]valueForKey:@"lastCreatedJobId"]intValue] parantKey:@"jobFunctions" childKey:@"jobFunctionId" withValueKey:@"jobFunctionName"];
        
        NSString * jobName = [[NSUserDefaults standardUserDefaults]valueForKey:@"lastCreatedJobName"];
        
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"showJobHeader"] ==nil)
        {
            if (SCREEN_HEIGHT==736)
            {
                self.headerJoblbl.font = [UIFont fontWithName:GlobalFontRegular size:16];
            }
            else
            {
                if (SCREEN_HEIGHT == 812) {
                    self.top_contsraint.constant =54;
                }
                self.headerJoblbl.font = [UIFont fontWithName:GlobalFontRegular size:13];
            }
            self.headerJoblbl.text=jobName;
        }
        else
        {
            self.headerJoblbl.text= jobName;//[[NSUserDefaults standardUserDefaults]objectForKey:@"showJobHeader"];
        }
        
        self.btn_Contsrint.constant = -10;
        self.headerJoblbl.hidden= NO;
        [self.preferenceButton setImage:[UIImage imageNamed:@"ic_keyboard_arrow_down_white_18pt.png"] forState:UIControlStateNormal];
        
        UITapGestureRecognizer * tapLabel =[[UITapGestureRecognizer alloc]init];
        [tapLabel setDelegate:(id)self];
        [tapLabel addTarget:self action:@selector(clcikOnGeaderLabel)];
        self.headerJoblbl.userInteractionEnabled = YES;
        [self.headerJoblbl addGestureRecognizer:tapLabel];
    }
    else
    {
        [self.preferenceButton setImage:[UIImage imageNamed:@"ic_filter_list_white"] forState:UIControlStateNormal];
        self.headerJoblbl.hidden= YES;
    }
}
-(void)clcikOnGeaderLabel
{
    if([[self.navigationController topViewController] isKindOfClass:[WRPreferencesController class]])
        return;
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
    WRPreferencesController *prefrence_controller = [mystoryboard instantiateViewControllerWithIdentifier:WRPREFERECES_CONTROLER_IDENTIFIER];
    prefrence_controller.flag = (int)(100 + index);
    [self.navigationController pushViewController:prefrence_controller animated:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReciveHistoryWithData:)
                                                 name:DIDRECIVEHISTORYWITHDATA
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationRecived:)
                                                 name:DIDRECIVE_REMOTE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onClickNotificationNavigation:)
                                                 name:DIDRECIVE_REMOTE_NOTIFICATION_ON_CLICK
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callAPIsToRefreshTheData:)
                                                 name:@"callAPIsToRefreshTheData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTheData)
                                                 name:UPDATEDATANOTIFICATION
                                               object:nil];
    if([Utility isComapany])
    {
        self.message_lbl.text = @"Get started by creating your first job.";
        [self.create_job_btn setTitle:@"Create Job" forState:UIControlStateNormal];
        
        [FireBaseAPICalls captureScreenDetails:APPLICANT_CARD];
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:COMPANY_JOB_POST setProperties:userName];
        [Utility getMixpanelData:COMPANY_HOME_SCREEN setProperties:userName];
        
    }
    else
    {
        self.message_lbl.text = @"Change your preferences to see new exciting jobs.";
        [self.create_job_btn setTitle:@"Change Preferences" forState:UIControlStateNormal];
        self.topConstraint.constant = 30;
        
        [FireBaseAPICalls captureScreenDetails:JOB_CARD];
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:APPLICANT_JOBS_VIEWJOBS setProperties:userName];
    }
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view bringSubviewToFront:self.headerView];
    
    [Utility setThescreensforiPhonex:myView];
    
    savedArray=[[NSMutableArray alloc]init];
}

-(void)refreshJobsActionCountForToday {
    NSString *userID = [[NSUserDefaults standardUserDefaults]
                        valueForKey:APPLICANT_REGISTRATION_ID];
    NSString *externalJobKey = [NSString stringWithFormat:@"%@-externalJobActions", userID];
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat: @"MM/dd/yyyy"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    FIRDatabaseReference *externalJobsTodaysActionReference = [[[[FIRDatabase database] reference] child:externalJobKey] child:dateString];
    [externalJobsTodaysActionReference observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ([snapshot exists]) {
            NSDictionary *actionCount = snapshot.value;
            if ([actionCount isKindOfClass:[NSDictionary class]]) {
                NSNumber *count = actionCount[actionCountKey];
                [self setCountOfActions:count];
                if (self.fetchPending) {
                    [self User_getotherCompany_JobsList:externalJobsFetchLimit];
                    [self setFetchPending: NO];
                }
            } else {
                [self setCountOfActions:@0];
            }
        } else {
            [self setCountOfActions:@0];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

-(void)updateJobsActionCountForTodayInStoreWithValue:(NSNumber *)count {
    if (count) {
        NSString *userID = [[NSUserDefaults standardUserDefaults]
                            valueForKey:APPLICANT_REGISTRATION_ID];
        NSString *externalJobKey = [NSString stringWithFormat:@"%@-externalJobActions", userID];
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        [dateFormat setDateFormat: @"MM/dd/yyyy"];
        NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
        FIRDatabaseReference *externalJobsTodaysActionReference = [[[[FIRDatabase database] reference] child:externalJobKey] child:dateString];
        [externalJobsTodaysActionReference updateChildValues:@{actionCountKey: count} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                NSLog(@"%@", error);
            } else {
                [self refreshJobsActionCountForToday];
            }
        }];
    }
}

-(void)notificationRecived:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if([Utility isComapany]){
        if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_Candidates"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Jobseeker_Interest"]){
            //Home scree
            self.tabBarController.selectedIndex = 0;
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_No_Candidates"]){
            //prefrences
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToPrefrencesScreen:0];
            return;
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_JobMatch"] || [[userInfo valueForKeyPath:@"category"] isEqualToString:@"Notif_Recruiter_JobMatch"]){
            //It’s a match. (NEW SCREEN)
            self.tabBarController.selectedIndex = 0;
            [self showMatchWindowWithObject:userInfo];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_No_JobPost"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Active"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Closed"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Reject"]){
            
            //Jobs screen
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:112];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RELOADJOBSLIST object:nil];
        }
    }else{
        
        if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Active_Users"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Comp_Interest"]){ //Home
            self.tabBarController.selectedIndex = 0;
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Active_User_No_Match"]){ // Edit profile
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] editButtonActionOnClick:nil];
            return;
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_User_InActive_Has_Match"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_InActive_User"]){ //(ACCOUNT)
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:100];
            return;
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_JobSeeker_JobMatch"] || [[userInfo valueForKeyPath:@"category"] isEqualToString:@"Notif_JobSeeker_JobMatch"]){
            //One time screen. It’s a match. (NEW SCREEN)
            self.tabBarController.selectedIndex = 0;
            [self showMatchWindowWithObject:userInfo];
        }
    }
}
-(void)onClickNotificationNavigation:(NSNotification *)notification
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate.notification_container dismissNotification];
    
    NSDictionary *userInfo = notification.userInfo;
    if([Utility isComapany])
    {
        
        if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_Update_Company_Profile"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:101];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_Update_Account"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:100];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_Add_Job"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:113];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_View_Jobs"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:112];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_Update_Preferences"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:108];
            
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_Settings"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:109];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_View_Profiles"]){
            self.tabBarController.selectedIndex = 0;
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_View_Interested"]){
            
            self.tabBarController.selectedIndex = 1;
            WRActivityViewController *activity_controller = [[[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] firstObject];
            [activity_controller onClickNotificationChange:0];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Employer_View_Matched"]){
            self.tabBarController.selectedIndex = 1;
            WRActivityViewController *activity_controller = [[[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] firstObject];
            [activity_controller onClickNotificationChange:1];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_Candidates"]){ //Home scree
            
            self.tabBarController.selectedIndex = 0;
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_No_Candidates"]){ //prefrences
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToPrefrencesScreen:0];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Jobseeker_Interest"]){
            
            //HOME SCREEN (CANDIDATES)- Done
            self.tabBarController.selectedIndex = 0;
            
            [self reloadTheData];
            //Need to reload
            
        }else if([[userInfo valueForKeyPath:@"gcm.notification.notification_type"] isEqualToString:@"FCM"] || [[userInfo valueForKeyPath:@"notification_type"] isEqualToString:@"FCM"]){//notification_type
            self.tabBarController.selectedIndex = 1;
            UINavigationController *controller = [[self.tabBarController viewControllers] objectAtIndex:1];
            [[[controller viewControllers] firstObject] onFCMNotificationClicked:userInfo];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_No_JobPost"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Active"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Closed"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Reject"]){
            
            //Jobs screen
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:112];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RELOADJOBSLIST object:nil];
        }
        
        
    }else{
        
        if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Update_Profile"]){ //To remind user to add edit profile information.
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:101];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Add_Experience"]){ //To remind user to add edit profile information.
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:102];
            
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Add_Education"]){ //To remind user to add a new education
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:103];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Add_Academic_Project"]){// To remind user to add a new academic project
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:104];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Update_JobFunction"]){ //To remind user to update job function
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:105];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Update_Skills"]){ //To remind user to update job function
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:106];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Update_CurrentStatus"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:107];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Update_Preferences"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:108];
            
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Update_Settings"]){
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:109];
            
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_View_Jobs"]){
            
            self.tabBarController.selectedIndex = 0;
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_View_Applied"]){
            
            self.tabBarController.selectedIndex = 1;
            WRActivityViewController *activity_controller = [[[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] firstObject];
            
            [activity_controller onClickNotificationChange:0];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Appicant_View_Matched"]){
            
            self.tabBarController.selectedIndex = 1;
            WRActivityViewController *activity_controller = [[[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] firstObject];
            activity_controller.isConversationFlag = YES;
            [activity_controller onClickNotificationChange:1];
            
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Active_Users"]){ //Home
            self.tabBarController.selectedIndex = 0;
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Active_User_No_Match"]){ // Edit profile
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] editButtonActionOnClick:nil];
            return;
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Comp_Interest"]){
            
            self.tabBarController.selectedIndex = 0;
            
            //Need to reload
            [self reloadTheData];
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_User_InActive_Has_Match"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_InActive_User"]){ //(ACCOUNT)
            
            self.tabBarController.selectedIndex = 2;
            UINavigationController *controller = [[self.tabBarController viewControllers] lastObject];
            [[[controller viewControllers] firstObject] moveToScreenByScreenId:100];
            return;
            
        }else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Comp_Interest"]){//HOME SCREEN (JOBS)
            self.tabBarController.selectedIndex = 0;
        }else if([[userInfo valueForKeyPath:@"gcm.notification.notification_type"] isEqualToString:@"FCM"] || [[userInfo valueForKeyPath:@"notification_type"] isEqualToString:@"FCM"]){
            self.tabBarController.selectedIndex = 1;
            UINavigationController *controller = [[self.tabBarController viewControllers] objectAtIndex:1];
            [[[controller viewControllers] firstObject] onFCMNotificationClicked:userInfo];
        }
        
    }
}
- (void)showJobMatchOnCardLayout:(NSDictionary *)dictionary {
    [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController] dismissViewControllerAnimated:false completion:nil];
    
    UIViewController *presentingController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRACMatchScreen *controller = [mystoryboard instantiateViewControllerWithIdentifier:@"WRACMatchScreenIdentifier"];
    controller.notification_payload = dictionary;
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [presentingController presentViewController:controller animated:YES completion:nil];
}

-(void)showMatchWindowWithObject:(NSDictionary *)dictionary
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startConversationNotifier:)
                                                 name:STARTCONVERSATION_NOTIFICATION
                                               object:nil];
    
    // Dismiss any controller that was presented on top of this!
    [self showJobMatchOnCardLayout:dictionary];
}

-(void)startConversationNotifier:(NSNotification *) notification
{
    
    NSMutableDictionary *userInfo = [notification.userInfo mutableCopy];
    //NSLog(@"%@",userInfo);
    if (userInfo) {
        self.tabBarController.selectedIndex = 1;
        
        UINavigationController *controller = [[self.tabBarController viewControllers] objectAtIndex:1];
        [[[controller viewControllers] firstObject] navigateToConverstaionScreenOnReciveMatch:userInfo];
    }
}

-(void)callRecurutorPrefrences
{
    [[CompanyHelper sharedInstance] setPrefrancesParams:[NSNumber numberWithInt:[[[CompanyHelper sharedInstance].prefrences_object valueForKeyPath:@"experienceMax"] intValue]] forKey:@"experienceMax"];
    [[CompanyHelper sharedInstance] setPrefrancesParams:[NSNumber numberWithInt:[[[CompanyHelper sharedInstance].prefrences_object valueForKeyPath:@"experienceMin"] intValue]] forKey:@"experienceMin"];
    [[CompanyHelper sharedInstance] setPrefrancesParams:[NSNumber numberWithInt:[[[CompanyHelper sharedInstance].prefrences_object valueForKeyPath:@"jobPostId"] intValue]] forKey:@"jobPostId"];
    [[CompanyHelper sharedInstance] setPrefrancesParams:[[[CompanyHelper sharedInstance].prefrences_object valueForKeyPath:@"jobType"] mutableCopy] forKey:@"jobType"];
    [[CompanyHelper sharedInstance] updatePrefrences:self requestType:100 params:[[CompanyHelper sharedInstance] companyPrefrencesParams]];
}

-(void)bindTheMessagesToUI:(NSDictionary *)data
{
    if([Utility isComapany])
    {
        if(data == nil){
            self.title_lbl.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"profile_screen_title"];
            self.message_lbl.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"profile_screen_msg"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"title"] forKey:@"profile_screen_title"];
            [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"msg"] forKey:@"profile_screen_msg"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[[data valueForKey:@"limit"] boolValue]] forKey:@"limit"];
            
            self.title_lbl.text = [data valueForKey:@"title"];
            self.message_lbl.text = [data valueForKey:@"msg"];
            
            if([self.title_lbl.text isEqualToString:@"That’s all for today!"] ){
                
                NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:FIRST_NAME_KEY];
                NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                            valueForKey:RECRUITER_REGISTRATION_ID];
                
                
                NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
                [Utility getMixpanelData:COMPANY_HOME_DAILYQUOTAOVER setProperties:userName];
            }
        }
    } else{
        if(data == nil)
        {
            self.title_lbl.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"profile_screen_title"];
            self.message_lbl.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"profile_screen_msg"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"title"] forKey:@"profile_screen_title"];
            [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"msg"] forKey:@"profile_screen_msg"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[[data valueForKey:@"limit"] boolValue]] forKey:@"limit"];
            
            self.title_lbl.text = [data valueForKey:@"title"];
            self.message_lbl.text = [data valueForKey:@"msg"];
            
            if([self.title_lbl.text isEqualToString:@"That’s all for today!"] ){
                
                NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:FIRST_NAME_KEY];
                NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                            valueForKey:APPLICANT_REGISTRATION_ID];
                
                
                NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
                
                
                [Utility getMixpanelData:APPLICANT_JOBS_QUOTAOVER setProperties:userName];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.view bringSubviewToFront:self.welcomeToView];
    [self.view bringSubviewToFront:self.headerView];
}


-(void)setExternalJobsSaved {
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat: @"MM/dd/yyyy"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults]setObject:dateString forKey:@"CheckDay_ExtJobs"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    FIRDatabaseReference *chatReference1 = [[FIRDatabase database] reference];
    NSDictionary *post1 = @{@"_date": dateString};
    NSDictionary *childUpdates1 =@{[NSString stringWithFormat:@"/user/%@/", [[NSUserDefaults standardUserDefaults]
                                                                             valueForKey:APPLICANT_REGISTRATION_ID]]:post1};
    [chatReference1 updateChildValues:childUpdates1];
}

-(void)didReceivedResponseWithData:(NSMutableDictionary *)data forTag:(int)tag
{
    self.demoCardArray = [data valueForKey:@"demo"];
    if (self.demoCardArray.count > 0)
    {
        NSString *demoButton = [NSString stringWithFormat:@"%@",[self.demoCardArray valueForKey:@"demo_button"]];
        NSString *demoHeading = [NSString stringWithFormat:@"%@",[self.demoCardArray valueForKey:@"demo_heading"]];
        
        NSString *demoImage = [NSString stringWithFormat:@"%@",[self.demoCardArray valueForKey:@"demo_image"]];
        NSString *demoText = [NSString stringWithFormat:@"%@",[self.demoCardArray valueForKey:@"demo_text"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:demoButton forKey:@"demo_button"];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:demoHeading forKey:@"demo_heading"];
        [[NSUserDefaults standardUserDefaults] setObject:demoImage forKey:@"demo_image"];
        [[NSUserDefaults standardUserDefaults] setObject:demoText forKey:@"demo_text"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if(tag == 102  &&  [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
    {
        NSMutableArray *jobsArray = [data valueForKey:@"data"];
        NSString *userName = [NSString stringWithFormat:@"%@_%@",FIRST_NAME_KEY,RECRUITER_REGISTRATION_ID];
        
        [Utility getMixpanelData:@"AS - Home (Profile - Success)" setProperties:userName];
        
        if([jobsArray count] == 0)
        {
            self.welcomeToView.hidden = NO;
            self.title_lbl.text = @"Welcome to Workruit";
            self.message_lbl.text = @"Get started by creating your first job.";
            [self.create_job_btn setTitle:@"Create Job" forState:UIControlStateNormal];
            return;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *lastCreatedJobId = [[jobsArray firstObject] valueForKey:@"jobPostId"];
        
        if([lastCreatedJobId intValue] > 0){
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:[jobsArray firstObject]];
            [defaults setObject:dataArray forKey:@"lastCreatedJobObject"];
            
            [defaults setObject:[NSString stringWithFormat:@"%@",lastCreatedJobId] forKey:@"lastCreatedJobId"];
            [defaults setObject:[[jobsArray firstObject] valueForKey:@"title"] forKey:@"lastCreatedJobName"];
            [defaults setObject:[[jobsArray firstObject] valueForKey:@"title"] forKey:@"showJobHeader"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //NSLog(@"%@  %@", [defaults objectForKey:LAST_CREATED_JOB_ID],[defaults objectForKey:LAST_CREATED_JOB_NAME]);
            [defaults synchronize];
        }
        
        [self loadtheHeaderData];
        
        NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:USERJOBSFORAPPLICANTARRAY];
        profilesForJobsArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
        
        if([lastCreatedJobId intValue]  >  0){
            [[CompanyHelper sharedInstance] getProfilesForJob:self requestType:profilesForJobsArray?100:-101];
        }
    }
    else if((tag == 100 ||  tag == -101)  &&  [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
    {
        [FireBaseAPICalls captureMixpannelEvent:@"AS - Home (Profile - Success)"];
        profilesForJobsArray = [data valueForKey:@"data"];
        
        //NSLog(@"==========%@ %@",[[profilesForJobsArray objectAtIndex:0] valueForKey:@"firstname"],[[profilesForJobsArray objectAtIndex:0] valueForKey:@"lastname"]);
        
        NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
        [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:PROFILEFORJOBARRAY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        if(_container)
            [_container reloadCardContainer];
        else
            [self reloadTheContainerView];
        
        if([profilesForJobsArray count] == 0)
        {
            self.welcomeToView.hidden = NO;
            [self.create_job_btn setTitle:@"Change Preferences" forState:UIControlStateNormal];
            [self bindTheMessagesToUI:data];
            
            if([ApplicantHelper sharedInstance].halfProfile)
                [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPNOJOBS];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:0] forKey:@"limit"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.welcomeToView.hidden = YES;
            
            [FireBaseAPICalls captureMixpannelEvent:COMPANY_HOME_VIEWAPPLICANTS];
            
            if([ApplicantHelper sharedInstance].halfProfile)
                [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETE_JOBSVIEW];
        }
        //Intiate service for get the User Histroy from server for company
        if(![[[NSUserDefaults standardUserDefaults] valueForKey:FIRSTTIMECALLCONVERSATIONS] boolValue]){
            [[CompanyHelper sharedInstance] getRecruterMatches:self requestType:-110];
        }
    }
    else if(tag == -121 || tag == -111)
    {
        if([[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
            if([profilesForJobsArray count] == 0){
                [self callAPIsToRefreshTheData:nil];
            }
            if(checkLoginStatus)
            {
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [delegate getLoginStatusFromServer];
                checkLoginStatus = NO;
            }
        }
    }
    //    else if(tag == -111)
    //    {
    //        NSLog(@"Applicant cards swipe card response %@",data);
    //
    //        if([profilesForJobsArray count] == 0)
    //        {
    //            [[CompanyHelper sharedInstance] getProfilesForJob:self requestType:100];
    //        }
    //    }
    //    else if(tag == -121)
    //    {
    //        NSLog(@"Job cards swipe card response %@",data);
    //    }
    else if(tag == -200)
    {
        NSLog(@"External jobs swipe card response %@",data);
        [self ExternalJobuserActionservice_API:[data valueForKey:@"data"]];
    }
    else if(tag == -300)
    {
        NSLog(@"External jobs swipe card final response %@",data);
    }
    else if((tag == 103 || tag == -103)  &&  [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
    {
        if ([[[data valueForKey:@"data"] mutableCopy]count] !=0)
        {
            //          if ([[data valueForKey:@"title"]isEqualToString:@"Update your status"]) {
            //            }else{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"external_jobs contains[cd] %@", @"1"];
            results = [[profilesForJobsArray filteredArrayUsingPredicate:predicate] mutableCopy];
            [profilesForJobsArray removeAllObjects];
            
            profilesForJobsArray=[[[[data valueForKey:@"data"] mutableCopy] arrayByAddingObjectsFromArray:results] mutableCopy];
            
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:USERJOBSFORAPPLICANTARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // }
        }
        else
        {
            if (profilesForJobsArray ==nil)
            {
                profilesForJobsArray = [[data valueForKey:@"data"] mutableCopy];
            }
            else
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"external_jobs contains[cd] %@", @"1"];
                results = [[profilesForJobsArray filteredArrayUsingPredicate:predicate] mutableCopy];
                [profilesForJobsArray removeAllObjects];
                
                profilesForJobsArray=[[[[data valueForKey:@"data"] mutableCopy] arrayByAddingObjectsFromArray:results] mutableCopy];
                
                NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
                [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:USERJOBSFORAPPLICANTARRAY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        // Get the Other comapany Jobs
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        [dateFormat setDateFormat: @"MM/dd/yyyy"];
        NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
        
        if (![[[NSUserDefaults standardUserDefaults]valueForKey:@"CheckDay_ExtJobs"]isEqualToString:dateString])
        {
            if ([[NSUserDefaults standardUserDefaults]integerForKey:@"savedExternalJobsValue"] == 1)
            {
                //               if ([[data valueForKey:@"title"]isEqualToString:@"Update your status"]){
                //               }
                //               else{
                NSUInteger expectedCount = externalJobsPerDayLimit - [self.countOfActions integerValue];
                if (expectedCount > 0) {
                    if (self.countOfActions) {
                        [self User_getotherCompany_JobsList:externalJobsFetchLimit];
                    } else {
                        [self setFetchPending:YES];
                    }
                } else {
                    [MBProgressHUD hideHUDForView:self.view animated:NO];
                    [self setExternalJobsSaved];
                }
                // }
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:NO];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        }
        
        if([profilesForJobsArray count] == 0)
        {
            if ([[NSUserDefaults standardUserDefaults]integerForKey:@"savedExternalJobsValue"] == 1)
            {
                if ([[NSUserDefaults standardUserDefaults]valueForKey:@"CheckDay_ExtJobs"] !=nil)
                {
                    nodataDict = data;
                    
                    if ([[data valueForKey:@"title"]isEqualToString:@"Update your status"])
                    {
                        [self.create_job_btn setTitle:@"Edit Account" forState:UIControlStateNormal];
                    }
                    else
                    {
                        [self.create_job_btn setTitle:@"Edit Profile" forState:UIControlStateNormal];
                    }
                    self.welcomeToView.hidden = NO;
                    [self bindTheMessagesToUI:data];
                }else{
                    nodataDict = data;
                }
            }
            else
            {
                nodataDict = data;
                if ([[data valueForKey:@"title"]isEqualToString:@"Update your status"])
                {
                    [self.create_job_btn setTitle:@"Edit Account" forState:UIControlStateNormal];
                }
                else
                {
                    [self.create_job_btn setTitle:@"Edit Profile" forState:UIControlStateNormal];
                }
                self.welcomeToView.hidden = NO;
                [self bindTheMessagesToUI:data];
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:0] forKey:@"limit"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.welcomeToView.hidden = YES;
        }
        
        if(_container)
            [_container reloadCardContainer];
        else
            [self reloadTheContainerView];
        
        if(![[[NSUserDefaults standardUserDefaults] valueForKey:FIRSTTIMECALLCONVERSATIONS] boolValue])
        {
            //Intiate service for get the User Histroy from server
            [[ApplicantHelper sharedInstance] getApplicantJobMatches:self requestType:-110];
        }
    }
    else if(tag == 200)
    {
        // get the other company jobs details here
        [self setExternalJobsSaved];
        
        savedArray =[[[NSUserDefaults standardUserDefaults]objectForKey:@"saveNewJobIDs"] mutableCopy];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"external_jobs contains[cd] %@", @"1"];
        NSMutableArray *results1 = [[profilesForJobsArray filteredArrayUsingPredicate:predicate] mutableCopy];
        NSUInteger externalJobsCounter = results1.count;
        NSUInteger expectedCount = externalJobsPerDayLimit - [self.countOfActions integerValue];
        for (int j=0; j<[[data valueForKey:@"data"]count]; j++)
        {
            savedDict = [[NSMutableDictionary alloc]init];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext__id"] forKey:@"_id"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_company"] forKey:@"company"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_link"] forKey:@"link"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_experience"] forKey:@"experience"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_location"] forKey:@"location"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_postedOn"] forKey:@"postedOn"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_salary"] forKey:@"salary"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_searchTitle"] forKey:@"searchTitle"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_summary"] forKey:@"summary"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_title"] forKey:@"title"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_website"] forKey:@"website"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_logo"] forKey:@"logo"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_skills"] forKey:@"skills"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_functionalArea"] forKey:@"functionalArea"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_industry"] forKey:@"industry"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_role"] forKey:@"role"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_roleCategory"] forKey:@"roleCategory"];
            [savedDict setValue:[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext_employmentType"] forKey:@"employmentType"];
            
            [savedDict setValue:@"1" forKey:@"external_jobs"];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id contains[cd] %@",[[[data valueForKey:@"data"]objectAtIndex:j] valueForKey:@"ext__id"]];
            NSMutableArray *results2 = [[profilesForJobsArray filteredArrayUsingPredicate:predicate] mutableCopy];
            if (results2.count == 0) {
                if (![savedArray containsObject:savedDict[@"_id"]]) {
                    externalJobsCounter = externalJobsCounter + 1;
                    [profilesForJobsArray addObject:savedDict];
                }
            }
            if (externalJobsCounter >= expectedCount) {
                break;
            }
        }
        
        //NSMutableArray * countARray =[[NSMutableArray alloc]init];
        //savedArray =[[[NSUserDefaults standardUserDefaults]objectForKey:@"saveNewJobIDs"] mutableCopy];
        
        //        for (int i=0; i<savedArray.count; i++)
        //        {
        //            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", [savedArray objectAtIndex:i]];
        //            NSMutableArray *results = [[profilesForJobsArray filteredArrayUsingPredicate:predicate] mutableCopy];
        //            NSUInteger index = [profilesForJobsArray  indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        //                return [predicate evaluateWithObject:obj];
        //            }];
        //
        //            if(results.count !=0)
        //            {
        //                [profilesForJobsArray removeObjectAtIndex:index];
        //                [countARray addObject:@"1"];
        //            }
        //        }
        
        //NSInteger totalcount = 7 - profilesForJobsArray.count;
        // Check for the external Jobs count
        if (externalJobsCounter < expectedCount) {
            if (![[NSUserDefaults standardUserDefaults]boolForKey:@"first_time"])
            {
                NSUInteger fetchedCount = [[data valueForKey:@"data"]count];
                if (fetchedCount >= externalJobsFetchLimit) {
                    self.skipIndex = self.skipIndex + fetchedCount;
                    [self User_getotherCompany_JobsList:externalJobsFetchLimit];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        [MBProgressHUD hideHUDForView:self.view animated:NO];
                    });
                    self.skipIndex = 0;
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [MBProgressHUD hideHUDForView:self.view animated:NO];
            });
            self.skipIndex = 0;
        }
        //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"external_jobs contains[cd] %@", @"1"];
        //        NSMutableArray *results1 = [[profilesForJobsArray filteredArrayUsingPredicate:predicate] mutableCopy];
        //        if ([results1 count]<expectedCount)
        //        {
        //            if (![[NSUserDefaults standardUserDefaults]boolForKey:@"first_time"])
        //            {
        //                if ([[data valueForKey:@"data"]count] >= expectedCount) {
        //                    self.skipIndex = self.skipIndex + expectedCount;
        //                    [self User_getotherCompany_JobsList:expectedCount+countARray.count];
        //                }
        //            }
        //        }
        //        else
        //        {
        //        NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
        //        [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:USERJOBSFORAPPLICANTARRAY];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        //        }
        
        NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
        [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:USERJOBSFORAPPLICANTARRAY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if([profilesForJobsArray count] == 0)
        {
            data = [[NSMutableDictionary alloc]init];
            [data setValue:[nodataDict valueForKey:@"msg"] forKey:@"msg"];
            [data setValue:[nodataDict valueForKey:@"status"] forKey:@"status"];
            [data setValue:[nodataDict valueForKey:@"title"] forKey:@"title"];
            
            if ([[nodataDict valueForKey:@"title"]isEqualToString:@"Update your status"])
            {
                [self.create_job_btn setTitle:@"Edit Account" forState:UIControlStateNormal];
            }
            else
            {
                [self.create_job_btn setTitle:@"Edit Profile" forState:UIControlStateNormal];
            }
            
            //            if (savedArray.count == 7+countARray.count)
            //            {
            //                self.welcomeToView.hidden = NO;
            //                [self bindTheMessagesToUI:data];
            //            }
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"first_time"]) {
                self.welcomeToView.hidden = NO;
                [self bindTheMessagesToUI:data];
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"first_time"];
            }
            else{
                self.welcomeToView.hidden = NO;
                [self bindTheMessagesToUI:data];
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"first_time"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:0] forKey:@"limit"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.welcomeToView.hidden = YES;
        }
        
        if(_container)
            [_container reloadCardContainer];
        else
            [self reloadTheContainerView];
        
    }
    else if(tag == -110  &&  [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:1] forKey:FIRSTTIMECALLCONVERSATIONS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSMutableArray *arrayObjects = [data valueForKey:@"data"];
        
        for(NSMutableDictionary *dictionary in arrayObjects){
            NSMutableArray *Objects =  [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list where channel_name = '%@'  order by last_update_date DESC",[Utility getChannelName:dictionary]]];
            
            NSString *json_params = [Utility convertDictionaryToJSONString:dictionary];
            json_params = [json_params stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            if([Objects count] <=  0){
                
                NSDate *date = [NSDate date];
                
                if(![Utility isComapany])
                    date =  [Utility getDateWithStringDate:[dictionary valueForKeyPath:@"conversationMatchDate"] withFormat:@"MMM yyyy dd  HH:mm a"];
                else
                    date =  [Utility getDateWithStringDate:[dictionary valueForKeyPath:@"jobPostId.conversationMatchDate"] withFormat:@"MMM yyyy dd  HH:mm a"];
                
                NSString *userId = [Utility isComapany]?[dictionary valueForKeyPath:@"userId.userId"]:[dictionary valueForKeyPath:@"recruiter.userId"];
                
                [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"insert or replace into conversation_list (channel_name,last_update_date,json_text,un_read_count) VALUES ('%@','%@','%@',%d)",[Utility getChannelName:dictionary],date,json_params,[userId intValue]]];
            }
        }
        
        arrayObjects =  [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list order by last_update_date DESC"]];
        if([arrayObjects count] > 0){
            [self subcribeAllChannelsForPush:arrayObjects isFromPushNotification:NO];
        }
    }
    else if(tag == -111  &&  [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
    {
        //Application critical update
        if([[data valueForKeyPath:@"data.ios.critical"] boolValue] && [Utility converVersionToFloat:[data valueForKeyPath:@"data.ios.version"]] > [Utility converVersionToFloat:[Utility getAppVersionNumber]]){
            
            [[NSUserDefaults standardUserDefaults] setObject:[data valueForKeyPath:@"data.ios.version"] forKey:APP_CRITICAL_UPDATE_OS_VERSION];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:APPCRITICAL_UPDATE_NOTIFICATION object:nil];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)callAPIsToRefreshTheData:(NSNotification *)notification
{
    if([Utility isComapany]){
        if([CompanyHelper sharedInstance].loadJobCardsWithPrefreceSettings) {
            [self callRecurutorPrefrences];
        } else {
            [[CompanyHelper sharedInstance] getProfilesForJob:self requestType:notification?100:-101];
        }
    }else{
        [[ApplicantHelper sharedInstance] getUserJobsForApplicant:self requestType:notification?103:-103];
    }
    
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag withData:(NSDictionary *)data
{
    if(tag == -2000){
        UIAlertController *alertView  =   [UIAlertController
                                           alertControllerWithTitle:[data valueForKey:@""]
                                           message:[data valueForKey:@""]
                                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 if(![Utility isComapany])
                                     [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETEJOBS_NOCLICK];
                                 
                                 
                                 if(_container)
                                     [_container reloadCardContainer];
                                 else
                                     [self reloadTheContainerView];
                                 [alertView dismissViewControllerAnimated:YES completion:nil];
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Update"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     if(![Utility isComapany])
                                         [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETEJOBS_YESCLICK];
                                     
                                     [self passButtonActionWithIndex:(int)index];
                                     [alertView dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alertView addAction:ok];
        [alertView addAction:cancel];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}
-(void)subcribeAllChannelsForPush:(NSMutableArray *)arrayOfConversations  isFromPushNotification:(BOOL)isFromPush
{
    for(NSMutableDictionary *dictionary_new in arrayOfConversations){
        NSMutableDictionary *dictionary = [Utility getDictionaryFromString:[dictionary_new valueForKey:@"json_text"]];
        NSString *channel_name = @"";
        if([Utility isComapany]){
            //Channel name 83174
            channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[dictionary valueForKeyPath:@"jobPostId.jobPostId"],[dictionary  valueForKeyPath:@"userId.userId"]];
        }else{
            //Channel name
            channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[dictionary  valueForKeyPath:@"jobPostId"],[[NSUserDefaults standardUserDefaults] valueForKeyPath:APPLICANT_REGISTRATION_ID]];
        }
        // [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", channel_name]];
    }
}

-(void)didReciveHistoryWithData:(NSNotification *)notification
{
    [self updateUnreadCount];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)updateUnreadCount
{
    //    [(AppDelegate *)[[UIApplication sharedApplication] delegate] updateUnreadCount];
    
    NSMutableArray *arrayObjects = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list order by last_update_date DESC"]];
    NSInteger unreadConversations = 0;
    
    for(NSDictionary *dictionary_object in arrayObjects){
        NSString *count = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_unread_count",[dictionary_object valueForKey:@"channel_name"]]];
        if([count intValue] > 0)
            unreadConversations ++;
    }
    
    if(unreadConversations > 0){
        [[[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%ld",(long)unreadConversations]];
        
        for (UIView *tabBarButton in self.navigationController.tabBarController.tabBar.subviews)
        {
            for (UIView *badgeView in tabBarButton.subviews)
            {
                NSString *className = NSStringFromClass([badgeView class]);
                
                // Looking for _UIBadgeView
                if ([className rangeOfString:@"BadgeView"].location != NSNotFound)
                {
                    badgeView.layer.transform = CATransform3DIdentity;
                    badgeView.layer.transform = CATransform3DMakeTranslation(-8.0, 0.0, 1.0);
                }
            }
        }
        
    }else{
        [[[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:nil];
    }
}
- (void)addLocalNotifications:(NSString *)message
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] initWithCapacity:0];
    [aps setObject:[Utility isComapany]?@"Employer_View_Matched":@"Appicant_View_Matched" forKey:@"category"];
    [payload setObject:aps forKey:@"aps"];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.userInfo = payload;
    notification.alertTitle = @"Workruit";
    notification.alertBody = [NSString stringWithFormat:@"You have some unread messages."];
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app showMessage:@"You have some unread messages." withPayLoad:payload];
    }];
}

-(void)checkLoginStatus
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate getLoginStatusFromServer];
}


// Need to modify the swipe card from here

-(void)reloadTheContainerView
{
    if([profilesForJobsArray count] > 0)
    {
        _container = [[YSLDraggableCardContainer alloc] init];
        _container.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _container.backgroundColor = [UIColor clearColor];
        _container.dataSource = self;
        _container.delegate = self;
        _container.canDraggableDirection = YSLDraggableDirectionLeft | YSLDraggableDirectionRight;
        [self.view addSubview:_container];
        [_container reloadCardContainer];
        
        
        [self.view bringSubviewToFront:self.headerView];
        
        if([[[[profilesForJobsArray firstObject] valueForKeyPath:@"experienceMax"]stringValue] isEqualToString:[NSString stringWithFormat:@"-1"]])
        {
            UIViewController *presentingController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
            GoodLuckCardViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:@"GoodLuckCardIdentifier"];
            
            controller.lable_2 = [self.demoCardArray valueForKey:@"demo_heading"];
            controller.lable_1 = [self.demoCardArray valueForKey:@"demo_text"];
            NSString *urlString = [self.demoCardArray valueForKey:@"demo_image"];
            NSString *buttonTitle  = [self.demoCardArray valueForKey:@"demo_button"];
            [controller.image_view sd_setImageWithURL:[NSURL URLWithString:urlString]];
            [controller.button setTitle:buttonTitle forState:UIControlStateNormal];
            [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            [presentingController presentViewController:controller animated:YES completion:nil];
        }
    }
}
#pragma mark -- YSLDraggableCardContainer DataSource
- (UIView *)cardContainerViewNextViewWithIndex:(NSInteger)index
{
    if([Utility isComapany])
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARDVIEW owner:self options:nil];
        JobsCardView *job_card_view = (JobsCardView *)[topLevelObjects objectAtIndex:0];
        job_card_view.center = self.view.center;
        CGSize card_size = [Utility getCardHeight];
        job_card_view.profile_dictionary = [profilesForJobsArray objectAtIndex:index];
        job_card_view.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - card_size.width)/2, ([UIScreen mainScreen].bounds.size.height - card_size.height)/2, card_size.width, card_size.height);
        job_card_view.tag = index;
        job_card_view.layer.cornerRadius = 10.0f;
        job_card_view.layer.masksToBounds = YES;
        job_card_view.layer.borderColor = [[UIColor colorWithRed:228/255 green:228/255 blue:228/255 alpha:0.15] CGColor];
        job_card_view.layer.borderWidth = 1.0f;
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [job_card_view addGestureRecognizer:singleFingerTap];
        [job_card_view.table_view reloadData];
        
        return job_card_view;
        
    }else{
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:APPLICANTCARDVIEW owner:self options:nil];
        ApplicantCardView *job_card_view = (ApplicantCardView *)[topLevelObjects objectAtIndex:0];
        
        if([[[[profilesForJobsArray firstObject] valueForKeyPath:@"experienceMax"] stringValue] isEqualToString:[NSString stringWithFormat:@"-1"]])
        {
            job_card_view.center = self.view.center;
            CGSize card_size = [Utility getCardHeight];
            job_card_view.profile_dictionary = [profilesForJobsArray objectAtIndex:index];
            job_card_view.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - card_size.width)/2, ([UIScreen mainScreen].bounds.size.height - card_size.height)/2, card_size.width, card_size.height);
            job_card_view.layer.cornerRadius = 10.0f;
            job_card_view.layer.masksToBounds = YES;
            job_card_view.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15] CGColor];
            job_card_view.layer.borderWidth = 1.0f;
            job_card_view.tag = index;
            /*job_card_view.imageView.hidden = NO;
             [job_card_view startAnim];*/
            
            _container.canDraggableDirection =  YSLDraggableDirectionRight;
        } else {
            job_card_view.center = self.view.center;
            CGSize card_size = [Utility getCardHeight];
            job_card_view.profile_dictionary = [profilesForJobsArray objectAtIndex:index];
            job_card_view.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - card_size.width)/2, ([UIScreen mainScreen].bounds.size.height - card_size.height)/2, card_size.width, card_size.height);
            job_card_view.layer.cornerRadius = 10.0f;
            job_card_view.layer.masksToBounds = YES;
            job_card_view.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15] CGColor];
            job_card_view.layer.borderWidth = 1.0f;
            job_card_view.tag = index;
            
            job_card_view.imageView.hidden = YES;
            
            _container.canDraggableDirection = YSLDraggableDirectionLeft | YSLDraggableDirectionRight;
        }
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [job_card_view addGestureRecognizer:singleFingerTap];
        [job_card_view.table_view reloadData];
        
        return job_card_view;
    }
}

- (NSInteger)cardContainerViewNumberOfViewInIndex:(NSInteger)index
{
    return profilesForJobsArray.count;
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    ApplicantCardView *job_card_view = [[ApplicantCardView alloc]init];
    job_card_view.imageView.hidden = YES;
    //Do stuff here...
    if([Utility isComapany]){
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRCardDetailsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRCARD_DETAILS_VIEW_CONTROLLER_IDENTIFIER];
        cardObject.profile_dictionary = [profilesForJobsArray objectAtIndex:recognizer.view.tag];
        cardObject.hidesBottomBarWhenPushed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:cardObject animated:YES completion:nil];
        });
    }
    else{
        
        // When click on other jobs card, this will take you to the that particular page
        if ([[[profilesForJobsArray objectAtIndex:recognizer.view.tag]valueForKey:@"external_jobs"]isEqualToString:@"1"])
        {
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            LoadOtherJobsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:@"LoadOtherJobsViewController"];
            cardObject.webLink =[[profilesForJobsArray objectAtIndex:recognizer.view.tag]valueForKey:@"link"];
            cardObject.titleStr =[[profilesForJobsArray objectAtIndex:recognizer.view.tag]valueForKey:@"title"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:cardObject animated:YES completion:nil];
            });
            
            //            if(![savedArray containsObject:[[profilesForJobsArray objectAtIndex:recognizer.view.tag]valueForKey:@"_id"]])
            //            {
            //                if (savedArray == nil) {
            //                    savedArray =[[NSMutableArray alloc]init];
            //                }
            //
            //                [savedArray addObject:[[profilesForJobsArray objectAtIndex:recognizer.view.tag]valueForKey:@"_id"]];
            //                [[NSUserDefaults standardUserDefaults]setObject:savedArray forKey:@"saveNewJobIDs"];
            //            }
        }
        else
        {
            //WRJobCardDetailsViewController
            
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
            WRJobCardDetailsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRJOB_CARD_DETAILS_VIEW_CONTROLLER];
            cardObject.profile_dictionary = [profilesForJobsArray objectAtIndex:recognizer.view.tag];
            cardObject.hidesBottomBarWhenPushed = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:cardObject animated:YES completion:nil];
            });
        }
    }
}

#pragma mark -- YSLDraggableCardContainer Delegate
- (void)cardContainerView:(YSLDraggableCardContainer *)cardContainerView didEndDraggingAtIndex:(NSInteger)index draggableView:(UIView *)draggableView draggableDirection:(YSLDraggableDirection)draggableDirection
{
    
    ApplicantCardView *jobCard = [[ApplicantCardView alloc]init];
    
    jobCard.imageView.hidden = YES;
    
    if([[[[profilesForJobsArray firstObject] valueForKeyPath:@"experienceMax"]stringValue] isEqualToString:[NSString stringWithFormat:@"-1"]]){
        jobCard.imageView.hidden = YES;
    }else{
        if(_container)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [_container reloadCardContainer];
            });
        else
            [self reloadTheContainerView];
    }
    
    // When click on external job card, this will take you to the that particular web page
    
    if ([[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"external_jobs"]isEqualToString:@"1"])
    {
        NSString *salarymin,*salaryMax;
        
        if ([[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"salary"] !=nil&&![[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"salary"] isEqual:@""] && ![[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"salary"]isEqualToString:@"nil"])
        {
            NSMutableArray * dataArray =[[[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"salary"] componentsSeparatedByString:@" "] mutableCopy];
            
            if ([[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"salary"]isEqualToString:@"Not disclosed"])
            {
                salarymin =@"0";
                salaryMax =@"0";
            }
            else
            {
                //                NSString * str, *str1;
                //                if ([dataArray count] ==2) {
                //                    str =[dataArray objectAtIndex:0];
                //                    str1=[dataArray objectAtIndex:1];
                //                }
                //                else{
                //                    str =[dataArray objectAtIndex:0];
                //                    str1=[dataArray objectAtIndex:2];
                //                }
            }
        }else{
            salarymin =@"0";
            salaryMax =@"0";
        }
        
        // Create the service call Params for external job card swipe
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        
        [dict setObject:[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"title"] forKey:@"title"];
        [dict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID] forKey:@"user_id"];
        [dict setObject:[NSNumber numberWithDouble:0.1f] forKey:@"experienceMin"];
        [dict setObject:[NSNumber numberWithDouble:0.1f] forKey:@"experienceMax"];
        [dict setObject:[NSNumber numberWithDouble:0.1f] forKey:@"salaryMin"];
        [dict setObject:[NSNumber numberWithDouble:0.1f] forKey:@"salaryMax"];
        [dict setObject:[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"summary"] forKey:@"description"];
        [dict setObject:[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"link"] forKey:@"link"];
        [dict setObject:[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"company"] forKey:@"company"];
        if ([[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"logo"]!=nil) {
            [dict setObject:[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"logo"] forKey:@"logo"];
        }else
        {
            [dict setObject:@"" forKey:@"logo"];
        }
        [dict setObject:[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"website"] forKey:@"via"];
        
        if (draggableDirection == YSLDraggableDirectionLeft)
        {
            [dict setObject:[NSNumber numberWithInteger:2] forKey:@"userJobextAction"];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:2] forKey:@"userJobextAction_value"];
        }
        else{
            [dict setObject:[NSNumber numberWithInteger:1] forKey:@"userJobextAction"];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:1] forKey:@"userJobextAction_value"];
        }
        
        [self sendTheExternalCardData_Server_API:dict];
        
        
        //        [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:NO block:^(NSTimer * _Nonnull timer) {
        //            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        //            LoadOtherJobsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:@"LoadOtherJobsViewController"];
        //            cardObject.webLink =[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"link"];
        //            cardObject.titleStr =[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"title"];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [self presentViewController:cardObject animated:YES completion:nil];
        //            });
        //        }];
        
        // Add the Jobs to the firebase
        FIRDatabaseReference *chatReference1 = [[FIRDatabase database] reference];
        NSString *key = [[chatReference1 child:@"posts"] childByAutoId].key;
        NSDictionary *post = @{@"_id": [[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"_id"]};
        NSDictionary *childUpdates = @{[@"/posts/" stringByAppendingString:key]: post,
                                       [NSString stringWithFormat:@"/users/%@/%@/", [[NSUserDefaults standardUserDefaults]
                                                                                     valueForKey:APPLICANT_REGISTRATION_ID], key]: post};
        [chatReference1 updateChildValues:childUpdates];
        
        NSNumber *nextNumber = @([self.countOfActions integerValue] + 1);
        [self updateJobsActionCountForTodayInStoreWithValue:nextNumber];
        //  [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CheckDay_ExtJobs"];
        
        
        savedArray= [[[NSUserDefaults standardUserDefaults]valueForKey:@"saveNewJobIDs"] mutableCopy];
        if(![savedArray containsObject:[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"_id"]])
        {
            if (savedArray == nil) {
                savedArray =[[NSMutableArray alloc]init];
            }
            [savedArray addObject:[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"_id"]];
            [[NSUserDefaults standardUserDefaults]setObject:savedArray forKey:@"saveNewJobIDs"];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            LoadOtherJobsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:@"LoadOtherJobsViewController"];
            cardObject.webLink =[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"link"];
            cardObject.titleStr =[[profilesForJobsArray objectAtIndex:(int)index]valueForKey:@"title"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:cardObject animated:YES completion:nil];
            });
            
            [profilesForJobsArray removeObjectAtIndex:(int)index];
            
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:USERJOBSFORAPPLICANTARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [_container reloadCardContainer];
            
        });
    }
    else
    {
        
        if (draggableDirection == YSLDraggableDirectionLeft)
        {
            [cardContainerView movePositionWithDirection:draggableDirection
                                             isAutomatic:NO];
            
            ApplicantCardView *jobCard = [[ApplicantCardView alloc]init];
            jobCard.imageView.hidden = YES;
            
            //As per requirement need to show only first time when user swipe the card
            if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"isFristTimeAlertDoneForPass"] isEqualToString:@"YES"]){
                
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isFristTimeAlertDoneForPass"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if(![Utility isComapany])
                    [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETEJOBS_DIALOG];
                
                UIAlertController *alertView  =   [UIAlertController
                                                   alertControllerWithTitle:@"Not Interested?"
                                                   message:[Utility isComapany]?@"Swiping left indicates that you are not interested in this profile.":@"Swiping left indicates that you are not interested in this job."
                                                   preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         if(![Utility isComapany])
                                             [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETEJOBS_NOCLICK];
                                         
                                         
                                         if(_container)
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                 [_container reloadCardContainer];
                                             });
                                         else
                                             [self reloadTheContainerView];
                                         [alertView dismissViewControllerAnimated:YES completion:nil];
                                     }];
                UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:@"Pass"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             if(![Utility isComapany])
                                                 [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETEJOBS_YESCLICK];
                                             
                                             [self passButtonActionWithIndex:(int)index];
                                             [alertView dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                
                [alertView addAction:ok];
                [alertView addAction:cancel];
                [self presentViewController:alertView animated:YES completion:nil];
            }else{
                [self passButtonActionWithIndex:(int)index];
            }
        }
        
        if (draggableDirection == YSLDraggableDirectionRight)
        {
            
            [cardContainerView movePositionWithDirection:draggableDirection
                                             isAutomatic:NO];
            
            if([[[[profilesForJobsArray firstObject] valueForKeyPath:@"experienceMax"]stringValue] isEqualToString:[NSString stringWithFormat:@"-1"]])
            {
                [self likeButtonActionWithIndex:(int)index];
            }else{
                
                ApplicantCardView *jobCard = [[ApplicantCardView alloc]init];
                jobCard.imageView.hidden = YES;
                
                //As per requirement need to show only first time when user swipe the card
                if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"isFristTimeAlertDoneForLike"] isEqualToString:@"YES"]){
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isFristTimeAlertDoneForLike"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    UIAlertController * alertView =   [UIAlertController
                                                       alertControllerWithTitle:[Utility isComapany]?@"Like?":@"Apply?"
                                                       message:[Utility isComapany]?@"Swiping right indicates that you have liked this profile.":@"Swiping right indicates that you have applied to this job."
                                                       preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"Cancel"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             if(![Utility isComapany])
                                                 [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETEJOBS_NOCLICK];
                                             
                                             if(_container)
                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                     [_container reloadCardContainer];
                                                 });
                                             else
                                                 [self reloadTheContainerView];
                                             
                                             [alertView dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    UIAlertAction* cancel = [UIAlertAction
                                             actionWithTitle:[Utility isComapany]?@"Like":@"Apply"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 if(![Utility isComapany])
                                                     [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETEJOBS_YESCLICK];
                                                 
                                                 [self likeButtonActionWithIndex:(int)index];
                                                 [alertView dismissViewControllerAnimated:YES completion:nil];
                                             }];
                    [alertView addAction:ok];
                    [alertView addAction:cancel];
                    [self presentViewController:alertView animated:YES completion:nil];
                    
                }else{
                    [self likeButtonActionWithIndex:(int)index];
                }
            }
        }
    }
}
-(void)passButtonActionWithIndex:(int)index
{
    if([Utility isComapany])
    {
        [FireBaseAPICalls captureScreenDetails:COMPANY_LEFT_SWIPE];
        [FireBaseAPICalls captureMixpannelEvent:COMPANY_HOME_LEFTSWIPE];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:[NSNumber numberWithInteger:2] forKey:@"recruiterProfileAction"];
        
        if ([[profilesForJobsArray objectAtIndex:index]valueForKey:@"suggested"] !=nil)
        {
            [params setValue:[NSNumber numberWithInteger:[[[profilesForJobsArray objectAtIndex:index]valueForKeyPath:@"suggested.suggested"]integerValue]] forKey:@"isSuggested"];
            [params setValue:[[profilesForJobsArray objectAtIndex:index]valueForKeyPath:@"suggested.sort"] forKey:@"sort"];
        }
        else if ([[profilesForJobsArray objectAtIndex:index]valueForKey:@"recommended"]!=nil)
        {
            [params setValue:[NSNumber numberWithInteger:0] forKey:@"isSuggested"];
            [params setValue:[[profilesForJobsArray objectAtIndex:index]valueForKeyPath:@"recommended.sort"] forKey:@"sort"];
        }
        
        NSString *url = [NSString stringWithFormat:@"/job/%@/user/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastCreatedJobId"],[[profilesForJobsArray objectAtIndex:index] valueForKey:@"userId"]];
        
        if([[CompanyHelper sharedInstance].companyProfiles count] > 0)
            url = [NSString stringWithFormat:@"/likeProfileActionInPreferencesSort/job/%@/user/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastCreatedJobId"],[[profilesForJobsArray objectAtIndex:index] valueForKey:@"userId"]];
        
        [[CompanyHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:-111 withURL:url];
    }
    else
    {
        [FireBaseAPICalls captureScreenDetails:APPLICANT_LEFT_SWIPE];
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_JOBS_LEFTSWIPE];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:[NSNumber numberWithInteger:2] forKey:@"userJobAction"];
        
        NSString *url = [NSString stringWithFormat:@"/user/%@/job/%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],[[profilesForJobsArray objectAtIndex:index] valueForKey:@"jobPostId"]];
        [[ApplicantHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:-121 withURL:url];
        
    }
    swipe_index = index;
    
    if([[[profilesForJobsArray objectAtIndex:swipe_index] valueForKeyPath:@"experienceMin"] intValue]== -1 && [[[profilesForJobsArray objectAtIndex:swipe_index] valueForKeyPath:@"experienceMax"] intValue] == -1){
        checkLoginStatus = YES;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [profilesForJobsArray removeObjectAtIndex:swipe_index];
        
        if([Utility isComapany]){
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:PROFILEFORJOBARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:USERJOBSFORAPPLICANTARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [_container reloadCardContainer];
    });
}

-(void)likeButtonActionWithIndex:(int)index
{
    if([Utility isComapany]){
        
        [FireBaseAPICalls captureScreenDetails:COMPANY_RIGHT_SWIPE];
        [FireBaseAPICalls captureMixpannelEvent:COMPANY_HOME_RIGHTSWIPE];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:[NSNumber numberWithInteger:1] forKey:@"recruiterProfileAction"];
        
        if ([[profilesForJobsArray objectAtIndex:index]valueForKey:@"suggested"] !=nil)
        {
            [params setValue:[NSNumber numberWithInteger:[[[profilesForJobsArray objectAtIndex:index]valueForKeyPath:@"suggested.suggested"]integerValue]] forKey:@"isSuggested"];
            
            [params setValue:[[profilesForJobsArray objectAtIndex:index]valueForKeyPath:@"suggested.sort"] forKey:@"sort"];
        }
        else if ([[profilesForJobsArray objectAtIndex:index]valueForKey:@"recommended"]!=nil)
        {
            [params setValue:[NSNumber numberWithInteger:0] forKey:@"isSuggested"];
            
            [params setValue:[[profilesForJobsArray objectAtIndex:index]valueForKeyPath:@"recommended.sort"] forKey:@"sort"];
        }
        
        
        NSString *url = [NSString stringWithFormat:@"/job/%@/user/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastCreatedJobId"],[[profilesForJobsArray objectAtIndex:index] valueForKey:@"userId"]];
        
        if([[CompanyHelper sharedInstance].companyProfiles count] > 0)
            url = [NSString stringWithFormat:@"/likeProfileActionInPreferencesSort/job/%@/user/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastCreatedJobId"],[[profilesForJobsArray objectAtIndex:index] valueForKey:@"userId"]];
        
        [[CompanyHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:-111 withURL:url];
    }else{
        [FireBaseAPICalls captureScreenDetails:APPLICANT_RIGHT_SWIPE];
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_JOBS_RIGHTSWIPE];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:[NSNumber numberWithInteger:1] forKey:@"userJobAction"];
        
        NSString *url = [NSString stringWithFormat:@"/user/%@/job/%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],[[profilesForJobsArray objectAtIndex:index] valueForKey:@"jobPostId"]];
        [[ApplicantHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:-121 withURL:url];
    }
    swipe_index = index;
    
    
    if([[[profilesForJobsArray objectAtIndex:swipe_index] valueForKeyPath:@"experienceMin"] intValue]== -1 && [[[profilesForJobsArray objectAtIndex:swipe_index] valueForKeyPath:@"experienceMax"] intValue] == -1){
        checkLoginStatus = YES;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [profilesForJobsArray removeObjectAtIndex:swipe_index];
        
        if([Utility isComapany]){
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
            [[NSUserDefaults standardUserDefaults] setValue:dataArray forKey:PROFILEFORJOBARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:profilesForJobsArray];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:USERJOBSFORAPPLICANTARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [_container reloadCardContainer];
    });
}
- (void)cardContainerViewDidCompleteAll:(YSLDraggableCardContainer *)container;
{
}
- (void)cardContainerView:(YSLDraggableCardContainer *)cardContainerView didSelectAtIndex:(NSInteger)index draggableView:(UIView *)draggableView
{
    
}
- (void)cardContainderView:(YSLDraggableCardContainer *)cardContainderView updatePositionWithDraggableView:(UIView *)draggableView draggableDirection:(YSLDraggableDirection)draggableDirection widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio
{
    
    //NSLog(@"%f ----------------------- %f",widthRatio,heightRatio);
    if([Utility isComapany]){
        JobsCardView *jobCard = (JobsCardView *)draggableView;
        
        if (draggableDirection == YSLDraggableDirectionLeft) {
            jobCard.passTickImage.alpha = widthRatio;
            return;
        }
        
        if (draggableDirection == YSLDraggableDirectionRight) {
            jobCard.likeTickImage.alpha = widthRatio;
            return;
        }
        
        jobCard.passTickImage.alpha = 0.0f;
        jobCard.likeTickImage.alpha = 0.0f;
        
    }else{
        
        ApplicantCardView *jobCard = (ApplicantCardView *)draggableView;
        
        if([[[[profilesForJobsArray firstObject] valueForKeyPath:@"experienceMax"]stringValue] isEqualToString:[NSString stringWithFormat:@"-1"]]){
            
            if (widthRatio > 0.65) {
                jobCard.imageView.hidden = YES;
            }
            else{
                jobCard.imageView.hidden = NO;
            }
        }
        else{
            jobCard.imageView.hidden = YES;
        }
        
        
        if (draggableDirection == YSLDraggableDirectionLeft) {
            jobCard.passTickImage.alpha = widthRatio;
            ApplicantCardView *jobCard = (ApplicantCardView *)draggableView;
            jobCard.imageView.hidden = YES;
            
            return;
        }
        
        if (draggableDirection == YSLDraggableDirectionRight) {
            jobCard.likeTickImage.alpha = widthRatio;
            jobCard.imageView.hidden = YES;
            return;
        }
        jobCard.passTickImage.alpha = 0.0f;
        jobCard.likeTickImage.alpha = 0.0f;
    }
}


// Get the external jobs list using this service call
-(void)User_getotherCompany_JobsList:(NSInteger)numberofJobs
{
    NSString * location;
    NSString * experience = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"totalexperience"];
    
    if ([[self applicantGetJobTypes:2] isEqualToString:@"All"]) {
        location = @"";
    }else{
        location = [self applicantGetJobTypes:2];
        NSArray *locationsArray = [location componentsSeparatedByString:@","];
        
        if ([locationsArray count] > 0) {
            location = [locationsArray objectAtIndex:0];
        }
    }
    location = [Utility trim:location];
    
    NSString *jobRoles = [ApplicantHelper getJobRolesFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobfunctions"]];
    NSArray *jobRolesArray = [jobRoles componentsSeparatedByString:@","];
        if ([jobRolesArray count] > 0) {
            jobRoles = [jobRolesArray objectAtIndex:0];
        }
    jobRoles = [Utility trim:jobRoles];
    
    NSString* urlStr =[NSString stringWithFormat:@"%@search=%@&experience=%@&skip=%lu&limit=%ld&location=%@",Other_Company_Jobs,jobRoles,experience,(unsigned long)self.skipIndex,(long)numberofJobs,location];
    
    NSString *str =[urlStr stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    
    
    NSURL *url = [[NSURL alloc]initWithString:str];
    NSURLSession *session = [NSURLSession sharedSession];
    NSLog(@"%@",url);

    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data !=nil)
        {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [self didReceivedResponseWithData:dic forTag:200];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [MBProgressHUD hideHUDForView:self.view animated:NO];
            });
            
        }
    }]
     resume];
}

// send the request to the server based on external jobs right and left swipe card actions
-(void)sendTheExternalCardData_Server_API:(NSMutableDictionary *)params
{
    NSString *url = [NSString stringWithFormat:@"/user/%@/postjobExt",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
    [[ApplicantHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:-200 withURL:url];
}
-(void)ExternalJobuserActionservice_API:(NSString *)job_id
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userJobextAction_value"] forKey:@"userJobAction"];
    
    NSString *url = [NSString stringWithFormat:@"/user/%@/jobext/%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],job_id];
    [[ApplicantHelper sharedInstance] updateSwipeActionToServer_ExternalJobs:params delegate:self requestType:-300 withURL:url];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userJobextAction_value"];
}

-(NSString *)applicantGetJobTypes:(int)flag
{
    NSString *value = @"";
    
    if(flag == 1){
        NSMutableArray  *tempArray = nil;
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
            tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobTypes"] mutableCopy];
        else
            tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobTypes"] mutableCopy];
        
        
        NSMutableArray  *jobsArray = [CompanyHelper getArrayWithParentKey:@"jobTypes"];
        
        for(NSMutableDictionary *dictionary in jobsArray){
            for(NSMutableDictionary *dic in tempArray)
                if([[dictionary valueForKey:@"jobTypeId"] intValue] == [[dic valueForKey:@"jobTypeId"] intValue])
                    value = [dictionary valueForKey:@"jobTypeTitle"];
            
        }
        
        if([value length] > 0 && [jobsArray count] != [tempArray count])
            return value;
        else
            return @"All";
        
    } else {
        
        NSMutableArray  *tempArray = nil;
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
            tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobLocations"] mutableCopy];
        else
            tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobLocations"] mutableCopy];
        
        NSMutableArray  *tempArray1 = [[[ApplicantHelper sharedInstance].paramsDictionary  valueForKey:@"SelectedRows"]mutableCopy] ;
        NSMutableArray *jobsArray = [CompanyHelper getArrayWithParentKey:@"locations"];
        
        if (tempArray.count == 0) {
            
            for(NSMutableDictionary *dictionary in jobsArray)
                for(NSMutableDictionary *dic in tempArray1)
                    if([[dictionary valueForKey:@"locationId"] intValue] == [[dic valueForKey:@"locationId"] intValue])
                        value =  [ApplicantHelper getJobLocationFromArray:tempArray1];
            
            if([value length] > 0 && [jobsArray count] != [tempArray1 count])
                return value;
            else
                return @"All";
            
            
        }
        else{
            for(NSMutableDictionary *dictionary in jobsArray)
                for(NSMutableDictionary *dic in tempArray)
                    if([[dictionary valueForKey:@"locationId"] intValue] == [[dic valueForKey:@"locationId"] intValue])
                        value =  [ApplicantHelper getJobLocationFromArray:tempArray];
            
            if([value length] > 0 && [jobsArray count] != [tempArray count])
                return value;
            else
                return @"All";
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

