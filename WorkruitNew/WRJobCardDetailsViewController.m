//
//  WRJobCardDetailsViewController.m
//  workruit
//
//  Created by Admin on 11/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRJobCardDetailsViewController.h"
#import "UILabel+ContentSize.h"

@interface WRJobCardDetailsViewController ()
{
    NSMutableArray *sectionArray;
    BOOL checkForMatchPayloadForTutorialFlag;
    IBOutlet UIView * myView;
}
@end

@implementation WRJobCardDetailsViewController

-(IBAction)backButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FireBaseAPICalls captureScreenDetails:JOB_CARD_DETAILS];
}

- (void)setDefaultHeightForTableView {
    self.table_view.estimatedRowHeight = 44.0;
    [self.table_view setRowHeight:UITableViewAutomaticDimension];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDefaultHeightForTableView];
    
    if(self.hideButtomBar){
        self.buttom_constrant.constant = -50;
        [self.table_view updateConstraints];
    }
    if ([Utility isComapany]) {
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:COMPANY_HOME_VIEWDETAIL setProperties:userName];
        
    }
    else{
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:APPLICANT_JOBS_VIEWDETAILS setProperties:userName];
        
        if([ApplicantHelper sharedInstance].halfProfile)
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETE_JOBSVIEW];
        
        
        
    }
    sectionArray = [[NSMutableArray alloc] initWithObjects:@"SKILLS",@"JOB DESCRIPTION",@"COMPANY", nil];
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [Utility setThescreensforiPhonex:myView];
    
    [self.table_view setSeparatorColor:UIColorFromRGB(0xe4e4e4)];
    
}

-(IBAction)detailButtonAction:(id)sender
{
    if ([Utility isComapany]) {
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:COMPANY_HOME_URLCLICK setProperties:userName];
        
    }
    else{
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:APPLICANT_JOBS_CLICKURLS setProperties:userName];
        
        
    }
    NSMutableArray *social_array =  [self.profile_dictionary valueForKeyPath:@"company.companySocialMediaLinks"];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"More" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [actionSheet dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Website" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self.profile_dictionary valueForKeyPath:@"company.website"]]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.profile_dictionary valueForKeyPath:@"company.website"]]];
        [actionSheet dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    
    NSString *facebook_url = @"";
    for(NSMutableDictionary *dictionary in social_array){
        if([[dictionary valueForKey:@"socialMediaName"] isEqualToString:@"Facebook"]){
            facebook_url = [dictionary valueForKey:@"socialMediaValue"];
            break;
        }
    }
    
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH 'facebook.com/'"];
    if(![fltr evaluateWithObject:facebook_url] && ![facebook_url isEqualToString:@""]){
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:facebook_url]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebook_url]];
            [actionSheet dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    
    NSString *twitter_url = @"";
    for(NSMutableDictionary *dictionary in social_array){
        if([[dictionary valueForKey:@"socialMediaName"] isEqualToString:@"Twitter"]){
            twitter_url = [dictionary valueForKey:@"socialMediaValue"];
            break;
        }
    }
    
    NSPredicate *fltr1 = [NSPredicate predicateWithFormat:@"self ENDSWITH 'twitter.com/'"];
    if(![fltr1 evaluateWithObject:twitter_url] && ![twitter_url isEqualToString:@""]){
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:twitter_url]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitter_url]];
            [actionSheet dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    
    NSString *linkedIn_url = @"";
    for(NSMutableDictionary *dictionary in social_array){
        if([[dictionary valueForKey:@"socialMediaName"] isEqualToString:@"LinkedIn"]){
            linkedIn_url = [dictionary valueForKey:@"socialMediaValue"];
            break;
        }
    }
    
    NSPredicate *fltr2 = [NSPredicate predicateWithFormat:@"self ENDSWITH 'linkedin.com/'"];
    
    if(![fltr2 evaluateWithObject:linkedIn_url] && ![linkedIn_url isEqualToString:@""]){
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"LinkedIn" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:linkedIn_url]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkedIn_url]];
            [actionSheet dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
            case 0:
            return 250.0f;
            break;
            case 1://Source Sans Pro 14.0
            return UITableViewAutomaticDimension;
            break;
            case 2:
            return UITableViewAutomaticDimension;
            break;
            case 3:{
                return UITableViewAutomaticDimension;
            } break;
    }
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    return 0;
    else
    return 43.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, self.view.frame.size.width-30, 30)];
    lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
    lbl.textColor = UIColorFromRGB(0x6A6A6A);
    bgView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    if(section == 0)
    lbl.text = @"";
    else
    lbl.text = [sectionArray objectAtIndex:section-1];
    [bgView addSubview:lbl];
    return bgView;
}

- (void)configureCompanySectionDetails:(JobCardTextViewCell *)cell {
    //*********** NAME,SIZE,FOUNDED,WEBSITE **************//
    
    cell.text_view.text = [NSString stringWithFormat:@" %@ \n\n Employee Size: %@ \n Established Date: %@ \n Website: %@",
                           [self.profile_dictionary valueForKeyPath:@"company.about"],
                           [self.profile_dictionary valueForKeyPath:@"company.size.csTitle"],
                           [self.profile_dictionary valueForKeyPath:@"company.establishedDate"],
                           [self.profile_dictionary valueForKeyPath:@"company.website"]
                           ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        static NSString *cellIdentifier = JOBCARD_HEADER_CELL_IDENTIFIER;
        JobCardHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARD_HEADER_CELL owner:self options:nil];
            cell = (JobCardHeaderCell *)[topLevelObjects objectAtIndex:0];
        }
        
        
        if ([self.comingFromChat isEqualToString:@"chatscreen"])
        {
            [cell.intrestedBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:100/255.0 blue:168/255.0 alpha:1]];
            
            cell.intrestedBtn.hidden = NO;
            [cell.intrestedBtn setTitle:@"Matched" forState:UIControlStateNormal];
            NSNumber *suggested = [self.profile_dictionary valueForKeyPath:@"suggested.suggested"];
            NSNumber *recommended = [self.profile_dictionary valueForKeyPath:@"recommended.recommended"];
            if ([suggested isKindOfClass:[NSNumber class]] && [suggested boolValue])
            {
                // cell.recommededBtn.hidden = NO;
                // [cell.recommededBtn setTitle:@"Suggested" forState:UIControlStateNormal];
            }
            else if ([recommended isKindOfClass:[NSNumber class]] && [recommended boolValue])
            {
                // cell.recommededBtn.hidden = NO;
                // [cell.recommededBtn setTitle:@"Recommended" forState:UIControlStateNormal];
            }
            else
            {
                cell.recommededBtn.hidden = YES;
            }
        } else {
            // Suggested/Recommended/Intersetsed Tags
            if([[self.profile_dictionary valueForKey:@"isInterested"] boolValue])
            {
                [cell.intrestedBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:100/255.0 blue:168/255.0 alpha:1]];
                
                cell.intrestedBtn.hidden = NO;
                [cell.intrestedBtn setTitle:@"Interested" forState:UIControlStateNormal];
                
                NSNumber *suggested = [self.profile_dictionary valueForKeyPath:@"suggested.suggested"];
                NSNumber *recommended = [self.profile_dictionary valueForKeyPath:@"recommended.recommended"];
                if ([suggested isKindOfClass:[NSNumber class]] && [suggested boolValue])
                {
                    // cell.recommededBtn.hidden = NO;
                    // [cell.recommededBtn setTitle:@"Suggested" forState:UIControlStateNormal];
                }
                else if ([recommended isKindOfClass:[NSNumber class]] && [recommended boolValue])
                {
                    // cell.recommededBtn.hidden = NO;
                    // [cell.recommededBtn setTitle:@"Recommended" forState:UIControlStateNormal];
                }
                else
                {
                    cell.recommededBtn.hidden = YES;
                }
            }
            else
            {
                cell.intrestedBtn.hidden = YES;
                [cell.intrestedBtn setBackgroundColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:182/255.0 alpha:1]];
                cell.recommededBtn.hidden = YES;
                
                NSNumber *suggested = [self.profile_dictionary valueForKeyPath:@"suggested.suggested"];
                NSNumber *recommended = [self.profile_dictionary valueForKeyPath:@"recommended.recommended"];
                if ([suggested isKindOfClass:[NSNumber class]] && [suggested boolValue])
                {
                    
                    // cell.intrestedBtn.hidden = NO;
                    // [cell.intrestedBtn setTitle:@"Suggested" forState:UIControlStateNormal];
                }
                else if ([recommended isKindOfClass:[NSNumber class]] && [recommended boolValue])
                {
                    //cell.intrestedBtn.hidden = NO;
                    //[cell.intrestedBtn setTitle:@"Recommended" forState:UIControlStateNormal];
                }
                else
                {
                    cell.intrestedBtn.hidden = YES;
                }
            }
        }
        
        
        NSDate *dateObject = [Utility getDateWithStringDate:[self.profile_dictionary valueForKey:@"createdDate"] withFormat:@"MMM yyyy dd hh:mm a"];
        NSString *dateWithDays = [Utility getAgoTimeIntervalInString:dateObject];
        
        if(dateObject == nil)
        cell.datePostedLbl.text = @"";
        else{
            NSString *compareString = [NSString stringWithFormat:@"%@ - %@ years", [self.profile_dictionary valueForKeyPath:@"experienceMin"],[self.profile_dictionary valueForKeyPath:@"experienceMax"]];
            
            if([compareString  isEqualToString:@"-1 - -1 years"])
            {
                cell.datePostedLbl.text  =[NSString stringWithFormat:@"%@ - (Posted Today)",[self.profile_dictionary valueForKeyPath:@"jobType.jobTypeTitle"]] ;
                cell.profile_image.image = [UIImage imageNamed:@"app_icon_image"];
            } else {
                cell.datePostedLbl.text = [NSString stringWithFormat:@"%@ - (Posted %@)",[self.profile_dictionary valueForKeyPath:@"jobType.jobTypeTitle"],dateWithDays];
                
                [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"company.picture"]]]
                                      placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                               options:SDWebImageRefreshCached];
            }
        }
        
        NSString * title =[self.profile_dictionary valueForKeyPath:@"title"];
        NSString * jrole =[self.profile_dictionary valueForKeyPath:@"company.companyName"];
        
        NSUInteger strLenght = [title length];
        NSUInteger strLenght1 = [jrole length];
        
        if (strLenght > 28&& strLenght1 > 28) {
            cell.view_constrant.constant = 80;
        } else {
            cell.view_constrant.constant = 60;
        }
        
        cell.dateLabel_constant.constant =5;
        // cell.view_contsrtant1.constant=25;
        
        cell.nameLbl.numberOfLines =0;
        cell.designationLbl.numberOfLines=0;
        cell.companyProfileLbl.numberOfLines=0;
        
        cell.nameLbl.text = [self.profile_dictionary valueForKeyPath:@"title"];
        
        NSString * industies = [self getCompanyStringArray:[self.profile_dictionary valueForKeyPath:@"company.companyIndustriesSet"]];
        
        if(industies.length > 60)
        {
            cell.company_contstant.constant = 40;
            cell.company_constant1.constant = 1;
            cell.companyProfileLbl.numberOfLines = 2;
        }
        
        cell.companyProfileLbl.text = industies;
        
        cell.designationLbl.text = [self.profile_dictionary valueForKeyPath:@"company.companyName"];
        
        //cell.nameLbl.text =@"first [self getCompanyStringArray:[self.profile_dictionary";
        //cell.companyProfileLbl.text=@" third [self getCompanyStringArray:[self.profile_dictionary";
        // cell.designationLbl.text=@"second [self getCompanyStringArray:[self.profile_dictionary";
        
        if([[self.profile_dictionary valueForKeyPath:@"jobType.jobTypeTitle"] isEqualToString:@"Internship"])
        {
            NSString *start_date =[Utility getStringWithDate:[self.profile_dictionary valueForKeyPath:@"startDate"] withOldFormat:@"MMM yyyy" newFormat:@"MMM"];
            
            NSString *end_date = [self.profile_dictionary valueForKeyPath:@"endDate"];
            end_date = [Utility getStringWithDate:[self.profile_dictionary valueForKeyPath:@"endDate"] withOldFormat:@"MMM yyyy" newFormat:@"MMM yy"];
            
            cell.yearLbl.text = [NSString stringWithFormat:@"%@ - %@", start_date,end_date];
        } else {
            NSString *compareString = [NSString stringWithFormat:@"%@ - %@ years", [self.profile_dictionary valueForKeyPath:@"experienceMin"],[self.profile_dictionary valueForKeyPath:@"experienceMax"]];
            
            if([compareString  isEqualToString:@"-1 - -1 years"])
            {
                
                cell.yearLbl.text = @"1 - 20 years";
                
                cell.profile_image.image = [UIImage imageNamed:@"app_icon_image"];
            }
            else
            cell.yearLbl.text = [NSString stringWithFormat:@"%.1f - %.1f years",[[self.profile_dictionary valueForKeyPath:@"experienceMin"] floatValue],[[self.profile_dictionary valueForKeyPath:@"experienceMax"] floatValue]];
            
            
            [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"company.picture"]]]
                                  placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                           options:SDWebImageRefreshCached];
        }
        
        [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"company.picture"]]]
                              placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                       options:SDWebImageRefreshCached];
        
        cell.locationLbl.text = [self.profile_dictionary valueForKeyPath:@"location.title"];
        
        if([[self.profile_dictionary valueForKeyPath:@"unpaid"] boolValue]){
            cell.packageLbl.text = @"Unpaid";
        } else if(![[self.profile_dictionary valueForKeyPath:@"unpaid"] boolValue] && [[self.profile_dictionary valueForKeyPath:@"hideSalary"] boolValue])
        cell.packageLbl.text = @"-- ₹ --";
        else
        cell.packageLbl.text = [NSString stringWithFormat:@"₹ %@L - %@L", [self.profile_dictionary valueForKeyPath:@"salaryMin"],[self.profile_dictionary valueForKeyPath:@"salaryMax"]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        JobCardTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JOBCARD_TEXTVIEW_CELL_IDENTIFIER];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARDTEXTVIEWCELL owner:self options:nil];
            cell = (JobCardTextViewCell *)[topLevelObjects objectAtIndex:0];
        }
        switch (indexPath.section) {
                case 1:
                cell.text_view.text = [self getSkillStringArray:[self.profile_dictionary valueForKey:@"skills"]];
                break;
                case 2:
                cell.text_view.text = [self.profile_dictionary valueForKey:@"description"];
                break;
            default:
                // TODO : CHECK THIS VALODATION
                if ([self.profile_dictionary valueForKeyPath:@"company.establishedDate"] == nil) {
                    
                    cell.text_view.text = [NSString stringWithFormat:@"%@ \n\n Website: %@ \n\n Employee Size: %@ \n\n",              [self.profile_dictionary valueForKeyPath:@"company.about"],
                                           [self.profile_dictionary valueForKeyPath:@"company.website"],
                                           [self.profile_dictionary valueForKeyPath:@"company.size.csTitle"]];
                    
                } else {
                    [self configureCompanySectionDetails:cell];
                }
                break;
        }
        return cell;
    }
}

-(IBAction)likeORpassAction:(id)sender {
    if ([Utility isComapany]) {
        if([sender tag] == 1) {
            NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID];
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            [Utility getMixpanelData:COMPANY_HOME_LEFTPASS setProperties:userName];
        } else {
            NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID];
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            [Utility getMixpanelData:COMPANY_HOME_RIGHTPASS setProperties:userName];
        }
    } else {
        if ([sender tag]==1) {
            NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            [Utility getMixpanelData:APPLICANT_JOBS_LEFTPASS setProperties:userName];
        } else {
            NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            [Utility getMixpanelData:APPLICANT_JOBS_RIGHTPASS setProperties:userName];
        }
    }
    
    NSLog(@"sender %@",sender);
    NSString *compareString = [NSString stringWithFormat:@"%@ - %@ years", [self.profile_dictionary valueForKeyPath:@"experienceMin"],[self.profile_dictionary valueForKeyPath:@"experienceMax"]];
    if([compareString isEqualToString:@"-1 - -1 years"]){
        
        if([sender tag] == 2){
            return;
        } else {
            if([sender tag] == 1)
            checkForMatchPayloadForTutorialFlag = YES;
            
            [FireBaseAPICalls captureMixpannelEvent:[sender tag]==0?APPLICANT_HOME_INCOMPLETEJOBS_NOCLICK:APPLICANT_HOME_INCOMPLETEJOBS_YESCLICK];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
            [params setObject:[NSNumber numberWithInteger:[sender tag]] forKey:@"userJobAction"];
            
            [[ApplicantHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:101 withURL:[NSString stringWithFormat:@"/user/%@/job/%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],[self.profile_dictionary valueForKey:@"jobPostId"]]];
        }
    } else {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:[NSNumber numberWithInteger:[sender tag]] forKey:@"userJobAction"];
        
        [FireBaseAPICalls captureMixpannelEvent:[sender tag]==0?APPLICANT_HOME_INCOMPLETEJOBS_NOCLICK:APPLICANT_HOME_INCOMPLETEJOBS_YESCLICK];
        
        
        //As per requirement need to show only first time when user swipe the card
        if(![[[NSUserDefaults standardUserDefaults] valueForKey:[sender tag] == 1?@"isFristTimeAlertDoneForLike":@"isFristTimeAlertDoneForPass"] isEqualToString:@"YES"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[sender tag] == 1?@"isFristTimeAlertDoneForLike":@"isFristTimeAlertDoneForPass"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *title = @"";
            NSString *message = @"";
            if([sender tag] == 1)
            {
                title = [Utility isComapany]?@"Like?":@"Apply?";
                message = [Utility isComapany]?@"Swiping right indicates that you have liked this profile.":@"Swiping right indicates that you have applied to this job.";
            }
            else
            {
                title = @"Not Interested?";
                message = [Utility isComapany]?@"Swiping left indicates that you are not interested in this profile.":@"Swiping left indicates that you are not interested in this job.";
            }
            
            UIAlertController *alertView =  [UIAlertController
                                             alertControllerWithTitle:title
                                             message:message
                                             preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertView dismissViewControllerAnimated:YES completion:nil];
                                 }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:[sender tag] == 1?@"Like":@"Pass"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [[ApplicantHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:101 withURL:[NSString stringWithFormat:@"/user/%@/job/%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],[self.profile_dictionary valueForKey:@"jobPostId"]]];
                                         [alertView dismissViewControllerAnimated:YES completion:nil];
                                     }];
            
            [alertView addAction:ok];
            [alertView addAction:cancel];
            [self presentViewController:alertView animated:YES completion:nil];
        }else{
            [[ApplicantHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:101 withURL:[NSString stringWithFormat:@"/user/%@/job/%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],[self.profile_dictionary valueForKey:@"jobPostId"]]];
        }
    }
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 101) {
        if([[self.profile_dictionary valueForKeyPath:@"experienceMin"] intValue]== -1 && [[self.profile_dictionary valueForKeyPath:@"experienceMax"] intValue] == -1 && checkForMatchPayloadForTutorialFlag){
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate getLoginStatusFromServer];
        }
        checkForMatchPayloadForTutorialFlag = NO;
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(NSString *)getCompanyStringArray:(NSMutableArray *)array
{
    NSMutableString *skill = [[NSMutableString alloc] init];
    
    for(int i = 0; i < [array count]; i++){
        NSMutableDictionary *dictionary = [array objectAtIndex:i];
        if([[array lastObject] isEqual:dictionary])
        [skill appendFormat:@"%@",[dictionary valueForKeyPath:@"industry.industryName"]];
        else
        [skill appendFormat:@"%@, ",[dictionary valueForKeyPath:@"industry.industryName"]];
    }
    return skill;
}

-(NSString *)getSkillStringArray:(NSMutableArray *)array
{
    NSMutableString *skill = [[NSMutableString alloc] init];
    for(NSString *string in array){
        if([[array lastObject] isEqualToString:string]){
            [skill appendFormat:@"%@",string];
        }else{
            [skill appendFormat:@"%@ • ",string];
        }
    }
    return skill;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
