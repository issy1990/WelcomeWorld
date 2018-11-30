//
//  WRNotesViewController.m
//  workruit
//
//  Created by Admin on 7/9/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "WRNotesViewController.h"
#import "LoadDataManager.h"
@interface WRNotesViewController ()
{
    
 CustomTextViewCell *local_text_view_cell;
    
    NSString *textfieldString;
    IBOutlet UIView * myView;

}
@end

@implementation WRNotesViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    /*
    self.notesTextView.layer.borderColor = placeHolderColor.CGColor;
    self.notesTextView.layer.borderWidth = 1.0f;
    
 
    self.notesTextView.textColor =  MainTextColor;
        
   self.wordCount.text = [NSString stringWithFormat:@"%d",(int)(150 - [self.notesTextView.text length])];
    
    
   
    */
    NSString *jobRoles =   [ApplicantHelper getJobRolesFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobfunctions"]];
    
    NSLog(@"%@",jobRoles);
    
    NSString *completeString = [NSString stringWithFormat:@"Looking for a job in %@ ",jobRoles];
    textfieldString = completeString;
    [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"about"];
    [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"coverLetter"];
    self.view.backgroundColor = UIColorFromRGB(0xEFEFF4);
     [self.table_view setSeparatorColor:DividerLineColor];
  [self.table_view reloadData];
    
    [Utility setThescreensforiPhonex:myView];

    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 150.0f;
  
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
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
        lbl.text = @"ABOUT ME";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
 
     }
     [bgView addSubview:lbl];
    return bgView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
        return 1;
    
    
    }



-(IBAction)nextButtonForProcess:(id)sender
{
    
    NSLog(@"%@",textfieldString);
    textfieldString = [Utility trim:textfieldString];

    if(textfieldString.length <= 0){
         [CustomAlertView showAlertWithTitle:@"Error" message:@"Please fill all the fields." OkButton:@"OK" delegate:self];
    }
    else{
        [[ApplicantHelper sharedInstance] updateAboutToServer:self requestType:100];
    }
    
    
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = CUSTOM_TEXT_VIEW_CELL_IDENTIFIER;
    CustomTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: CUSTOM_TEXT_VIEW_CELL owner:self options:nil];
        cell = (CustomTextViewCell *)[topLevelObjects objectAtIndex:0];
        local_text_view_cell = cell;
    }
    
    
    NSString *jobRoles =   [ApplicantHelper getJobRolesFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobfunctions"]];
  
            cell.text_view.text = [NSString stringWithFormat:@"Looking for a job in %@ ",jobRoles];
    
    
        cell.wordCount.text =[NSString stringWithFormat:@"%d",(int)(150 - [cell.text_view.text length])];
        
        cell.text_view.textColor = MainTextColor;
 
    cell.text_view.delegate = self;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    





}



-(void)textViewDidBeginEditing:(UITextView *)textView
{
    
    
    if([textView.text isEqualToString:@"Enter  Summary"])
    {
        [textView setTextColor:placeHolderColor];
        [textView setText:@""];
    }
    
    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0 || [textView.text isEqualToString:@"Enter  Summary"]) {
        textView.text = @"Enter  Summary";
        
       textfieldString  = @"" ;
        [textView setTextColor: placeHolderColor];//2f2f2f
    }
    
    
    
    
    
    
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *completeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if([text isEqualToString:@""]){
        [textView setTextColor: MainTextColor];//2f2f2f
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"about"];
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"coverLetter"];
        
        local_text_view_cell.wordCount.text = [NSString stringWithFormat:@"%d",(int)(150 - [completeString length])];
         textfieldString  = completeString ;
        return YES;
    }
    
    
    if([completeString length] <=150){
        [textView setTextColor: MainTextColor];//2f2f2f
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"about"];
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:@"coverLetter"];
        
        local_text_view_cell.wordCount.text = [NSString stringWithFormat:@"%d",(int)(150 - [completeString length])];
         textfieldString = completeString ;
        return YES;
    }else{
        local_text_view_cell.wordCount.text = @"0";
        textfieldString = @"";
        return NO;}
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 100){
       
        
       
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:APPLICANT_SIGNUP_ABOUT setProperties:userName];
        
        
        
        if([[data valueForKey:@"percentage"] floatValue] > 0)
            NSLog(@"my data: %@",data);
            [ApplicantHelper sharedInstance].profilePercentage = [[data valueForKey:@"percentage"] floatValue];
        
        [ApplicantHelper sharedInstance].halfProfile = [[data valueForKey:@"halfProfile"] boolValue];

        
        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
        [self createMeTabBarController];
    }
}

-(IBAction)previousButtonProcess:(id)sender
{
    exit(0);
}

-(void)createMeTabBarController
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISLOGEDIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *userName = [NSString stringWithFormat:@"%@_%@",FIRST_NAME_KEY,APPLICANT_REGISTRATION_ID];
    
    [Utility getMixpanelData:APPLICANT_SIGNUP_PROFILE_SUCESS setProperties:userName];
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

-(IBAction)skipButton:(id)sender
{
    
    NSString *firstname = [[NSUserDefaults standardUserDefaults]
                           valueForKey:FIRST_NAME_KEY];
    NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                valueForKey:APPLICANT_REGISTRATION_ID];
    
    
    NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
    
    
    [Utility getMixpanelData:APPLICANT_SIGNUP_ABOUTSKIP setProperties:userName];
    
     [Utility getMixpanelData:APPLICANT_SIGNUP_PROFILE_SUCESS setProperties:userName];
    
    [self createMeTabBarController];
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
