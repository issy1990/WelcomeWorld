//
//  WRProfileViewController.m
//  workruit
//
//  Created by Admin on 10/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRProfileViewController.h"
#import <MessageUI/MessageUI.h>
#import "WRAddExperianceController.h"
#import "WRSkillsViewController.h"

@interface WRProfileViewController ()<MFMailComposeViewControllerDelegate>
{
    ProfilePictureHeader *header_view;
    IBOutlet UIView * myView;

}
@end

@implementation WRProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [FireBaseAPICalls captureMixpannelEvent:[Utility isComapany]?COMPANY_MORE_TAB:APPLICANT_MORE];

        header_view.profile_image.layer.cornerRadius = header_view.profile_image.frame.size.width/2;
        header_view.profile_image.layer.masksToBounds = YES;

    if([Utility isComapany]){
        header_view.nameLbl.text = [NSString stringWithFormat:@"%@ %@",[[CompanyHelper sharedInstance].params valueForKey:@"firstname"],[[CompanyHelper sharedInstance].params valueForKey:@"lastname"]];
    
        if(![Utility isNullValueCheck:[[CompanyHelper sharedInstance].params valueForKey:@"pic"]] && [[[CompanyHelper sharedInstance].params valueForKey:@"pic"] length] > 0){
            
            [header_view.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[CompanyHelper sharedInstance].params valueForKey:@"pic"]]]
                                         placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                                  options:SDWebImageRefreshCached];
        
        }else if([[[CompanyHelper sharedInstance].params valueForKey:@"picture"] length] > 0){
            
            [header_view.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[CompanyHelper sharedInstance].params valueForKey:@"picture"]]]
                         placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                  options:SDWebImageRefreshCached];
        }

        [header_view.editButtonAction setTitle:@"Edit Company Profile" forState:UIControlStateNormal];
        //if([CompanyHelper sharedInstance].profile_image)
            //header_view.profile_image.placeholderImage = [CompanyHelper sharedInstance].profile_image;
    }else{
        header_view.nameLbl.text = [NSString stringWithFormat:@"%@ %@",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"firstname"],[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"lastname"]];
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"pic"] length]  > 0){
            [header_view.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"pic"]]]
                                 placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                          options:SDWebImageRefreshCached];

            
        }else if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"picture"] length]  > 0){
            
            [header_view.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"picture"]]]
                                         placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                                  options:SDWebImageRefreshCached];

        }
        [header_view.editButtonAction setTitle:@"Edit Profile" forState:UIControlStateNormal];

        //if([ApplicantHelper sharedInstance].profile_image)
          //  header_view.profile_image.placeholderImage = [ApplicantHelper sharedInstance].profile_image;
        
    }

    if([Utility isComapany])
        [FireBaseAPICalls captureScreenDetails:COMPANY_MORE];
    else
        [FireBaseAPICalls captureScreenDetails:APPLICANT_MORE];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //Setting the table view footer view to zeero
    UIView *borderLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [borderLine1 setBackgroundColor:UIColorFromRGB(0xEFEFF4)];
    self.table_view.tableFooterView = borderLine1;
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProfilePictureHeader" owner:self options:nil];
    header_view = (ProfilePictureHeader *)[topLevelObjects objectAtIndex:0];
    header_view.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    [header_view.editButtonAction addTarget:self action:@selector(editButtonActionOnClick:) forControlEvents:UIControlEventTouchUpInside];

    UIView *borderLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        [borderLine2 addSubview:header_view];
        self.table_view.tableHeaderView = borderLine2;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.table_view setSeparatorColor:DividerLineColor];
    
    [Utility setThescreensforiPhonex:myView];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([Utility isComapany])
        return 3.0f;
    else return 2.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([Utility isComapany]){
        if(section == 0)
            return 1;
        else if(section == 1)
            return 2;
        else return 1;
    }else{
        if(section == 0)
            return 2;
        else return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = MULTIPLE_SELECTION_CELL_IDENTIFIER;
    MultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MULTIPLE_SELECTION_CELL owner:self options:nil];
        cell = (MultipleSelectionCell *)[topLevelObjects objectAtIndex:0];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if(indexPath.section == 0 && [Utility isComapany]){
        cell.titleLbl.text = @"Jobs";
    }else if((indexPath.section == 1 && [Utility isComapany]) || (![Utility isComapany] && indexPath.section == 0))
    {
        switch (indexPath.row) {
            case 0:
                cell.titleLbl.text = @"Account";
                break;
            
               
            case 1:
                cell.titleLbl.text = @"Settings";
                break;
        }
    }else{
        cell.titleLbl.text = @"Contact us";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.table_view reloadData];
    
    if(indexPath.section == 0 && indexPath.row == 0 &&  [Utility isComapany]){        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRJobsViewController *job_controller = [mystoryboard instantiateViewControllerWithIdentifier:WRJOBS_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:job_controller  animated:YES];
        
    }else if(((indexPath.section == 1 &&  [Utility isComapany]) || (indexPath.section == 0 &&  ![Utility isComapany])) && indexPath.row == 0)
    {
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRAccountsViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRACCOUNTS_VIEWCONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if((indexPath.section == 1 || indexPath.section == 0) && indexPath.row == 1){
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRSettingsViewController *settings_controller = (WRSettingsViewController *)[mystoryboard instantiateViewControllerWithIdentifier:WRSETTINGS_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:settings_controller animated:YES];
        
    }else if((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0)){
        [self showMessageComposer];
    }
}

-(void)moveToPrefrencesScreen:(int )index
{
    if([[self.navigationController topViewController] isKindOfClass:[WRPreferencesController class]])
        return;
    
    [self.navigationController popToRootViewControllerAnimated:NO];

    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
    WRPreferencesController *prefrence_controller = [mystoryboard instantiateViewControllerWithIdentifier:WRPREFERECES_CONTROLER_IDENTIFIER];
    prefrence_controller.flag = 100 + index;
    [self.navigationController pushViewController:prefrence_controller animated:NO];

}
-(void)moveToScreenByScreenId:(int)screen_id
{
    if(screen_id == 100 || screen_id == 107){
        
        if([[self.navigationController topViewController] isKindOfClass:[WRAccountsViewController class]])
            return;
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRAccountsViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRACCOUNTS_VIEWCONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:NO];
    
    }else if(screen_id  >= 101 && screen_id <= 106){
        if([Utility isComapany]){
            
            if([[self.navigationController topViewController] isKindOfClass:[WREditCompanyProfile class]])
                return;
                        

            [self.navigationController popToRootViewControllerAnimated:NO];
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
            WREditCompanyProfile *edit_profile_controller = [mystoryboard instantiateViewControllerWithIdentifier:WREDIT_COMPANY_PROFILE_IDENTIFIER];
            edit_profile_controller.isCommingFromFlag = 100;
            [self.navigationController pushViewController:edit_profile_controller animated:NO];
        }else{
            
            if([[self.navigationController topViewController] isKindOfClass:[WRApplicantEditProfile class]])
                return;

            [self.navigationController popToRootViewControllerAnimated:NO];
            
            NSMutableArray *arrayNavigationArray = [[self.navigationController viewControllers] mutableCopy];
            NSLog(@"%@",arrayNavigationArray);
            
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRApplicantEditProfile *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRAPPLICANT_EDIT_PROFILE_IDENTIFIER];
            controller.isCommingFromWhere = 100;
            
            [arrayNavigationArray addObject:controller];
            NSLog(@"%@",arrayNavigationArray);
            self.navigationController.viewControllers = arrayNavigationArray;
            
            if(screen_id == 102 || screen_id == 103 || screen_id == 104){
                //Add Experiace screen
                UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
                WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
                
                if(screen_id == 102)
                    controller.Flag = 0;
                else if(screen_id == 103)
                    controller.Flag = 1;
                else if(screen_id == 104)
                    controller.Flag = 2;
                
                controller.isFirstTime = YES;
                [self.navigationController pushViewController:controller animated:NO];
            }else  if(screen_id == 105){
                
                UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
                WRChooseCompanyIndustry *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
                controller.isCommingFromEditApplicant = YES;
                [self.navigationController pushViewController:controller animated:NO];
                
            }else  if(screen_id == 106){
                
                UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
                WRSkillsViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRSKILLS_VIEWCONTROLLER_IDENTIFIER];
                controller.isCommingFromEditContact = YES;
                [self.navigationController pushViewController:controller animated:NO];
            }
        }
    }else if(screen_id == 108){
        
        [self moveToPrefrencesScreen:1];
        
    }else if(screen_id == 109){
        
        if([[self.navigationController topViewController] isKindOfClass:[WRSettingsViewController class]])
            return;

        [self.navigationController popToRootViewControllerAnimated:NO];
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRSettingsViewController *settings_controller = (WRSettingsViewController *)[mystoryboard instantiateViewControllerWithIdentifier:WRSETTINGS_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:settings_controller animated:NO];

    }else if(screen_id == 112 || screen_id  == 113){

        if([[self.navigationController topViewController] isKindOfClass:[WRJobsViewController class]])
            return;
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRJobsViewController *job_controller = [mystoryboard instantiateViewControllerWithIdentifier:WRJOBS_VIEW_CONTROLLER_IDENTIFIER];
        job_controller.navigateToCreateJobScreen  = screen_id;
        [self.navigationController pushViewController:job_controller  animated:NO];
    }

}

-(void)editButtonActionOnClick:(id)sender
{
    if([Utility isComapany]){
        if([[self.navigationController topViewController] isKindOfClass:[WREditCompanyProfile class]])
            return;
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        WREditCompanyProfile *edit_profile_controller = [mystoryboard instantiateViewControllerWithIdentifier:WREDIT_COMPANY_PROFILE_IDENTIFIER];
        edit_profile_controller.isCommingFromFlag = 100;
        [self.navigationController pushViewController:edit_profile_controller animated:YES];
    }else{
        
        if([[self.navigationController topViewController] isKindOfClass:[WRApplicantEditProfile class]])
            return;
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRApplicantEditProfile *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRAPPLICANT_EDIT_PROFILE_IDENTIFIER];
        controller.isCommingFromWhere = 100;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    
}

-(void)showMessageComposer{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"iOS App"];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[@"support@workuit.com"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:mail animated:YES completion:NULL];
        });
    }else{
        [CustomAlertView showAlertWithTitle:@"Message" message:@"Please configure your email id in device." OkButton:@"Ok" delegate:self];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
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
