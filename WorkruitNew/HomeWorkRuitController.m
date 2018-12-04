//
//  HomeWorkRuitController.m
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "HomeWorkRuitController.h"
#import "AppDelegate.h"
#import "HHSlideView.h"
#import "WRHomeButtonsController.h"
#import "WRAddExperianceController.h"
#import "WRJobFunctionViewController.h"
#import "WRVerifyMobileController.h"
#import "WRLoginViewController.h"
#import "LoadDataManager.h"

@interface HomeWorkRuitController ()<HTTPHelper_Delegate,TDBWalkthroughDelegate,HHSlideViewDelegate,UITabBarControllerDelegate>
{
    HMSegmentedControl *segementController;
    
    WRHomeButtonsController *applicant_signIn;
    WRHomeButtonsController *comapany_signIn;
    IBOutlet UIView * myView;

    UITabBarController *tabBarController;
}

@end

@implementation HomeWorkRuitController

#pragma mark - HHSlideViewDelegate

- (NSInteger)numberOfSlideItemsInSlideView:(HHSlideView *)slideView {
    
    return 2;
}

- (NSArray *)namesOfSlideItemsInSlideView:(HHSlideView *)slideView {
    
    NSArray *dataArray = [[NSArray alloc] initWithObjects:@"APPLICANT", @"EMPLOYER", nil];
    return dataArray;
}

- (void)slideView:(HHSlideView *)slideView didSelectItemAtIndex:(NSInteger)index {
    if(index == 0 && [Utility isComapany]){
        [Utility setIsCompany:NO];
        self.messageLbl.text = @"Great jobs inside.\nIs your profile up, yet?";
    }else if(index == 1 && ![Utility isComapany]){
        [Utility setIsCompany:YES];
        self.messageLbl.text = @"Just one step away, from your\nnext star performer!";
    }
}

- (NSArray *)childViewControllersInSlideView:(HHSlideView *)slideView {

    applicant_signIn = [[WRHomeButtonsController alloc] initWithNibName:@"WRHomeButtonsController" bundle:nil];
    comapany_signIn = [[WRHomeButtonsController alloc] initWithNibName:@"WRHomeButtonsController" bundle:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [comapany_signIn.button_one setTitle:@"Login with Work Email"  forState:UIControlStateNormal];
        
        [applicant_signIn.button_one addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [applicant_signIn.button_two addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [comapany_signIn.button_one addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [comapany_signIn.button_two addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    });

    NSArray *childViewControllersArray = @[applicant_signIn, comapany_signIn];
    return childViewControllersArray;
}

- (UIColor *)colorOfSlideView:(HHSlideView *)slideView {
    
    return [UIColor whiteColor];
    
}

- (UIColor *)colorOfSliderInSlideView:(HHSlideView *)slideView {
    return [UIColor colorWithRed:62/255.0f green:187/255.0f blue:100/255.0f alpha:1.0f];
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
    [defaults synchronize];
    
    [Utility setIsCompany:NO];
    [self.slideView selectSelectedIndex:0];
    
    //Getting the master data from server
    [self getMasterData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int screenHeight =[UIScreen mainScreen].bounds.size.height;
    switch ((int)screenHeight) {
        case 480:
            self.htConstraint.constant = 302.0f;
            break;
        case 568:
            self.htConstraint.constant = 370.0f;
            break;
        case 667:
            self.htConstraint.constant = 434.0f;
            break;
        case 736:
            self.htConstraint.constant = 479.0f;
            break;
        case 812:
            self.htConstraint.constant = 479.0f;
            break;
      }

    self.messageLbl.text = @"Great jobs inside.\nIs your profile up, yet?";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if(![[NSUserDefaults standardUserDefaults] valueForKey:ISLOGEDIN] && ![defaults valueForKey:@"WalkThrough"]){
        [self ShowWalkThrough];
        [defaults setObject:@"WalkThrough" forKey:@"WalkThrough"];
        [defaults synchronize];
    }
    
    self.slideView.delegate = self;
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    [self createMeTabBarController];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLogutNotification:)
                                                 name:RECEIVE_LOGOUT_NOTIFICATION_NAME_KEY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAppCriticalUpdateNotification:)
                                                 name:APPCRITICAL_UPDATE_NOTIFICATION
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:UPDATEDATANOTIFICATION object:nil];
    
    //Checking with appstore version for normal update
    if([Utility converVersionToFloat:[self getAppStoreVersion]] > [Utility converVersionToFloat:[Utility getAppVersionNumber]]){
        [CustomAlertView showAlertWithTitle:APP_UPDATE_TITLE message:APP_UPDATE_MESSAGE OkButton:@"Cancel" cancelButton:@"Update" delegate:self withTag:100];
    }
}

/**
 * Method For get App store version
 */
-(NSString*)getAppStoreVersion{
    
    NSString *appstoreUrl, *appstoreVersion;
        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appID = infoDictionary[@"CFBundleIdentifier"];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/in/lookup?bundleId=%@", appID]];
        NSData* data = [NSData dataWithContentsOfURL:url];
        
        NSDictionary* lookup;
        if (data) {
            lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        
        if ([lookup[@"resultCount"] integerValue] == 1){
            appstoreVersion = lookup[@"results"][0][@"version"]; // version
            appstoreUrl = lookup[@"results"][0][@"artistViewUrl"]; // iTunesStore link
        }
    return appstoreVersion;
}

-(void)checkAppCriticalUpdateNotification:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:APPCRITICAL_UPDATE_NOTIFICATION_FLAG];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [CustomAlertView showAlertWithTitle1:APP_UPDATE_TITLE message:APP_UPDATE_MESSAGE OkButton:@"Update" delegate:self];
}

-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    if((buttonIndex == 1 && tag == 1) || (buttonIndex == 2 && tag == 100)){
        NSURL *url =  [NSURL URLWithString:@"https://itunes.apple.com/in/app/workruit/id1189752813?mt=8"];
        [[UIApplication sharedApplication] openURL:url];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APPCRITICAL_UPDATE_NOTIFICATION_FLAG];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)receiveLogutNotification:(NSNotification *)notification
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.unreadConversationCount = 0;
    
    NSMutableArray *arrayObjects = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select channel_name from conversation_list order by last_update_date DESC"]];

    for (NSMutableDictionary *dictionary in arrayObjects){
        [[FIRMessaging messaging] unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@", [dictionary valueForKey:@"channel_name"]]];
    }
    
    //Remove session from defaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SESSION_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:COMPANY_OBJECT_PARAMS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPLICANT_OBJECT_PARAMS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FIRSTTIMECALLCONVERSATIONS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERJOBSFORAPPLICANTARRAY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PROFILEFORJOBARRAY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:INTRESTEDLISTARRAY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCOUNTS_JSON_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ISLOGEDIN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:JOBSLISTARRAY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isFirstMessageDissplayed"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"jobMatchIds"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@""];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FirstTimeSynced"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber=1;
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //Delete all table data
    [[FMDBDataAccess sharedInstance] dropTheDataBaseAndReplaceDatabase];
    tabBarController = nil;
    [LoadDataManager sharedInstance].tabBarController = nil;
    
    [CompanyHelper sharedInstance].prefrences_object = nil;
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void)createMeTabBarController
{
    if(![[NSUserDefaults standardUserDefaults] valueForKey:ISLOGEDIN])
        return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *company_object_params = [[defaults valueForKey:COMPANY_OBJECT_PARAMS] mutableCopy];
    NSMutableDictionary *applicant_object_params = [[defaults valueForKey:APPLICANT_OBJECT_PARAMS] mutableCopy];
    
    if(company_object_params){
        [Utility setIsCompany:YES];
        [CompanyHelper sharedInstance].params = company_object_params;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPLICANT_OBJECT_PARAMS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else if(applicant_object_params){
        [Utility setIsCompany:NO];
        [ApplicantHelper sharedInstance].paramsDictionary = applicant_object_params;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:COMPANY_OBJECT_PARAMS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else
        return;
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRCandidateProfileController *jobsController =   [mystoryboard instantiateViewControllerWithIdentifier:WRCANDIDATE_PROFILE_CONTROLLER_IDENTIFIER];
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:jobsController];
    navController1.navigationBarHidden = YES;
    
    if([Utility isComapany])
        jobsController.title = @"Applicants";
    else
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
    
    tabBarController=[[UITabBarController alloc] init];
    tabBarController.delegate = self;
    tabBarController.tabBar.tintColor  = UIColorFromRGB(0x337ab7);
    tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    tabBarController.tabBar.barTintColor = [UIColor whiteColor];
    tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2,navController3,nil];
    [self.navigationController pushViewController:tabBarController animated:NO];
    
    [LoadDataManager sharedInstance].tabBarController = tabBarController;
    [[LoadDataManager sharedInstance] getApplicationData];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(IBAction)buttonClicked:(id)sender
{
    if([sender tag] == 2){
        
        NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"screen"];
        
        if ([savedValue length] > 0 && ![Utility isComapany]) {
            
            
            
            UIAlertController * alert_controller=   [UIAlertController
                                                     alertControllerWithTitle:@"Please Login"
                                                     message:@"You're in the middle of signup"
                                                     preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
                                     [self.navigationController pushViewController:[mystoryboard instantiateViewControllerWithIdentifier:WRLOGIN_VIEWCONTROLLER_IDENTIFIER] animated:YES];
                                     
                                 }];
            [alert_controller addAction:ok];
            [self presentViewController:alert_controller animated:YES completion:nil];
            
        }else{
            if ([Utility isComapany])
                    [FireBaseAPICalls captureMixpannelEvent:COMPANY_SIGNUP_SCREEN];
            else
                [FireBaseAPICalls captureMixpannelEvent:APPLICANT_SIGNUP_SCREEN];
         
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
            [self.navigationController pushViewController:[mystoryboard instantiateViewControllerWithIdentifier:WRCREATE_CREATE_COMPANY_ACCOUNT_IDENTIFIER] animated:YES];
        }
    }
    else{
			NSLog(@"login click");
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        [self.navigationController pushViewController:[mystoryboard instantiateViewControllerWithIdentifier:WRLOGIN_VIEWCONTROLLER_IDENTIFIER] animated:YES];
    }
}

-(void)MoveTOtheVerificationPage:(NSNotification *)notify
{
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
    [self.navigationController pushViewController:[mystoryboard instantiateViewControllerWithIdentifier:WRVERIFY_MOBILE_VIEW_CONTROLLER_IDENTIFIER] animated:YES];
}

//TODO need to remove Temp perpose
-(void)getMasterData
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,MASTER_DATA_API] WithParams:nil forRequest:-121212 controller:self httpMethod:HTTP_GET];
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"MasterData"];
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}

#pragma WalkThrough
-(void)ShowWalkThrough
{
    TDBWalkthrough *walkthrough = [TDBWalkthrough sharedInstance];
    
    NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"walkthrough_1"],
                       [UIImage imageNamed:@"walkthrough_2"],
                       [UIImage imageNamed:@"walkthrough_3"],
                       [UIImage imageNamed:@"walkthrough_4"], nil];
    
    NSArray *descriptions = [NSArray arrayWithObjects:
                             @"",
                             @"",
                             @"",
                             @"",
                             nil];
    walkthrough.descriptions = descriptions;
    walkthrough.images = images;
    walkthrough.className = @"TDBSimpleWhite";
    walkthrough.nibName = @"TDBSimpleWhite";
    walkthrough.delegate = self;
    
    //page control
    UIPageControl *pc = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 60, self.view.frame.size.height-150, 120, 30)];
    pc.userInteractionEnabled = NO;
    pc.numberOfPages = 4;
    pc.currentPage = 0;
    pc.pageIndicatorTintColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5];
    pc.currentPageIndicatorTintColor = [UIColor whiteColor];
    
    walkthrough.walkthroughViewController.pageControl = pc;
    [walkthrough.walkthroughViewController.view addSubview:walkthrough.walkthroughViewController.pageControl];
    
    [walkthrough show];
}

- (void)didPressButtonWithTag:(NSInteger)tag
{
    [[TDBWalkthrough sharedInstance] dismiss];
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
