//
//  CardDetailsViewController.m
//  Workruit
//
//  Created by Admin on 9/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRCardDetailsViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface WRCardDetailsViewController ()
{
    NSMutableArray *sectionArray;
    IBOutlet UIView * myView;
    
}
@end

@implementation WRCardDetailsViewController
@synthesize comingFromChat;
@synthesize chatObjectDataComing;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FireBaseAPICalls captureScreenDetails:APPLICANT_CARD_DETAILS];
    
    [FBSDKAppEvents logEvent:FBSDKAppEventNameViewedContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttomView.hidden = self.hideButtomBar;
    if(self.hideButtomBar){
        self.buttom_constrant.constant = -50;
        [self.table_view updateConstraints];
    }
    
    // Do any additional setup after loading the view from its nib.
    sectionArray = [[NSMutableArray alloc] initWithObjects:@"ABOUT ME",@"EXPERIENCE",@"EDUCATION",@"ACADEMIC PROJECTS",@"SKILLS", nil];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    NSLog(@"%@",self.profile_dictionary);
    
    [Utility setThescreensforiPhonex:myView];
    
    [self.table_view setSeparatorColor:UIColorFromRGB(0xe4e4e4)];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellText,* cellText1;
//    if ([[self.profile_dictionary valueForKey:@"userExperienceSet"]count] !=0) {
//        cellText = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"company"];
//    }
//    
//    if ([[self.profile_dictionary valueForKey:@"userExperienceSet"]count]!=0) {
//        cellText1  = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"jobTitle"];
//    }
    
    
    switch (indexPath.section) {
        case 0:
            return 185.0f;
            break;
        case 1:
            return [Utility getHeightForText:[self.profile_dictionary valueForKey:@"coverLetter"] withFont:[UIFont fontWithName:GlobalFontRegular size:14.0f] andWidth:self.view.frame.size.width];
            break;
        case 2:
            if ([[self.profile_dictionary valueForKey:@"userExperienceSet"]count] !=0) {
                cellText = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"company"];
            }
            
            if ([[self.profile_dictionary valueForKey:@"userExperienceSet"]count]!=0) {
                cellText1  = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"jobTitle"];
            }
        case 3:
        case 4:
            if (cellText.length > 25 && cellText1.length > 25)
            {
                return 90.0f;
            }
            else{
                return 65.0f;
            }
            break;
        default:
            return [Utility getHeightForText:[self getStringObjectFromArray:[self.profile_dictionary valueForKey:@"userSkillsSet"]] withFont:[UIFont fontWithName:GlobalFontRegular size:14.0f] andWidth:self.view.frame.size.width];
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 2 && [[self.profile_dictionary valueForKey:@"userExperienceSet"] count] > 0)
        return [[self.profile_dictionary valueForKey:@"userExperienceSet"] count];
    else if(section == 3 && [[self.profile_dictionary valueForKey:@"userEducationSet"] count] > 0)
        return [[self.profile_dictionary valueForKey:@"userEducationSet"] count];
    else if(section == 4 && [[self.profile_dictionary valueForKey:@"userAcademic"] count] > 0)
        return [[self.profile_dictionary valueForKey:@"userAcademic"] count];
    else
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if ([self.comingFromChat isEqualToString:@"chatscreen"])
        {
            static NSString *cellIdentifier = JOBCARD_HEADER_CELL_IDENTIFIER;
            JobCardHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARD_HEADER_CELL owner:self options:nil];
                cell = (JobCardHeaderCell *)[topLevelObjects objectAtIndex:0];
            }
            
            // Suggested/Recommended/Macthed Tags

            [cell.intrestedBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:100/255.0 blue:168/255.0 alpha:1]];
            
            cell.intrestedBtn.hidden = NO;
            [cell.intrestedBtn setTitle:@"Matched" forState:UIControlStateNormal];
            
            NSNumber *suggested = [self.profile_dictionary valueForKeyPath:@"suggested.suggested"];
            NSNumber *recommended = [self.profile_dictionary valueForKeyPath:@"recommended.recommended"];
            if ([suggested isKindOfClass:[NSNumber class]] && [suggested boolValue])
            {
               // cell.recommededBtn.hidden = NO;
                //[cell.recommededBtn setTitle:@"Suggested" forState:UIControlStateNormal];
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
            
            cell.nameLbl.numberOfLines =0;
            cell.designationLbl.numberOfLines=0;
            
            cell.nameLbl.text = [NSString stringWithFormat:@"%@ %@ (%@)",[self.profile_dictionary valueForKey:@"firstname"],[self.profile_dictionary valueForKey:@"lastname"],[self.profile_dictionary valueForKey:@"userJobTitle"]];
            
            cell.designationLbl.text =[Utility getJobFunctions:[self.profile_dictionary valueForKey:@"jobFunctions"]];
            
            cell.yearLbl.text = [NSString stringWithFormat:@"%@",[self.profile_dictionary valueForKey:@"totalExperienceText"]];
            
            cell.locationLbl.text = [self.profile_dictionary valueForKey:@"location"];
            
            if([[self.profile_dictionary valueForKey:@"hideSalary"] boolValue])
                cell.packageLbl.text = @"- ₹ -";
            else
                cell.packageLbl.text = [NSString stringWithFormat:@"₹ %@L - %@L",[self.profile_dictionary valueForKey:@"minSalaryExp"],[self.profile_dictionary valueForKey:@"maxSalaryExp"]];
            if(self.hideButtomBar)
            {
                [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"pic"]]] placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                               options:SDWebImageRefreshCached];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            static NSString *cellIdentifier = JOBCARD_HEADER_CELL_IDENTIFIER;
            JobCardHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARD_HEADER_CELL owner:self options:nil];
                cell = (JobCardHeaderCell *)[topLevelObjects objectAtIndex:0];
            }
            
            //            if([[self.profile_dictionary valueForKey:@"isInterested"] boolValue])
            //                cell.intrestedBtn.hidden = NO;
            //            else
            //                cell.intrestedBtn.hidden = YES;
            
            
            // Suggested/Recommended/Intersetsed Tags
            if([[self.profile_dictionary valueForKey:@"isInterested"] boolValue] || [self viewingInterestedProfileDetail]) {
                cell.intrestedBtn.hidden = NO;
                [cell.intrestedBtn setTitle:@"Interested" forState:UIControlStateNormal];
                [cell.intrestedBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:100/255.0 blue:168/255.0 alpha:1]];
            
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
                    //[cell.recommededBtn setTitle:@"Recommended" forState:UIControlStateNormal];
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
//                    cell.intrestedBtn.hidden = NO;
//                    [cell.intrestedBtn setTitle:@"Recommended" forState:UIControlStateNormal];
                }
                else
                {
                    cell.intrestedBtn.hidden = YES;
                }
            }
            
            cell.nameLbl.numberOfLines = 0;
            cell.designationLbl.numberOfLines= 0;
            
            cell.nameLbl.text =[NSString stringWithFormat:@"%@ (%@)",[self.profile_dictionary valueForKey:@"firstname"],[self.profile_dictionary valueForKey:@"userJobTitle"]];
            cell.designationLbl.text =[Utility getJobFunctions:[self.profile_dictionary valueForKey:@"jobFunctions"]];
            
            //[[[self.profile_dictionary valueForKey:@"jobFunctions"] objectAtIndex:0] valueForKey:@"jobFunctionName"];
            //  cell.designationLbl.text  = [cell.designationLbl.text uppercaseString];
            
            //cell.yearLbl.text = [NSString stringWithFormat:@"%.1f years",[[self.profile_dictionary valueForKey:@"totalExperience"] floatValue]];
            
            [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"pic"]]] placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]];

            NSLog(@"%@",[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"pic"]]);

            if (![self viewingInterestedProfileDetail]) {
                if(self.hideButtomBar) {
                    [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"pic"]]] placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                                   options:SDWebImageRefreshCached];
                    NSLog(@"here");
                }
            } else {
                [cell.profile_image setImage:[UIImage imageNamed:@"aplicant_placeholder"]];
                NSLog(@"her2e");
            }
            

            cell.yearLbl.text = [NSString stringWithFormat:@"%@",[self.profile_dictionary valueForKey:@"totalExperienceText"]];
            
            cell.locationLbl.text = [self.profile_dictionary valueForKey:@"location"];
            
            if([[self.profile_dictionary valueForKey:@"hideSalary"] boolValue])
                cell.packageLbl.text = @"- ₹ -";
            else
                cell.packageLbl.text = [NSString stringWithFormat:@"₹ %@L - %@L",[self.profile_dictionary valueForKey:@"minSalaryExp"],[self.profile_dictionary valueForKey:@"maxSalaryExp"]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    else if(indexPath.section == 1)
    {
        JobCardTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JOBCARD_TEXTVIEW_CELL_IDENTIFIER];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARDTEXTVIEWCELL owner:self options:nil];
            cell = (JobCardTextViewCell *)[topLevelObjects objectAtIndex:0];
        }
        if([[self.profile_dictionary valueForKey:@"coverLetter"] length] > 1){
            cell.text_view.text = [self.profile_dictionary valueForKey:@"coverLetter"];
            cell.text_view.textAlignment= NSTextAlignmentLeft;
        }else{
            cell.text_view.text= @"no data found";
            cell.text_view.textAlignment= NSTextAlignmentCenter;
        }
        
        cell.text_view.editable = NO;
        cell.text_view.scrollEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4)
    {
        JobCardDetailExpCell *cell = [tableView dequeueReusableCellWithIdentifier:JOBCARD_DETAIL_EXPCELL_IDENTIFIER];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARDDETAILEXPCELL owner:self options:nil];
            cell = (JobCardDetailExpCell *)[topLevelObjects objectAtIndex:0];
        }
        if(indexPath.section == 2)
        {
            cell.place_holder_lable.hidden = YES;
            if([[self.profile_dictionary valueForKey:@"userExperienceSet"] count] > 0)
            {
                NSString * jobRole =[[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"company"];
                
                
                if (jobRole.length > 28)
                {
                    cell.label_y_constrant.constant =3;
                    cell.label_x_constrant.constant =3;
                    cell.leftOneLbl.numberOfLines =2;
                }

               NSString * jobTitle =[[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"jobTitle"];
                
                
                if (jobTitle.length  > 20 && jobRole.length > 28)
                {
                    cell.second_label_y_constant.constant =6;
                    cell.second_label_x_constant.constant = -13;
                }
                else if (jobTitle.length  > 20)
                {
                    cell.second_label_y_constant.constant =2;
                    cell.second_label_x_constant.constant = -11;
                }
                
                cell.leftTwoLbl.numberOfLines =2;
                cell.leftTwoLbl.text =jobTitle;
                cell.leftOneLbl.text = jobRole;
                
                
                NSString *startDate = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"startDate"];
                startDate = [Utility getStringWithDate:startDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                
                NSString *endDate = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"endDate"];
                endDate = [Utility getStringWithDate:endDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                
                if([[[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"isPresent"] boolValue])
                    cell.rightOneLbl.text = [NSString stringWithFormat:@"%@ - Present",startDate];
                else
                    cell.rightOneLbl.text = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];
                
                cell.rightTwoLbl.text = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:indexPath.row] valueForKey:@"location"];
                
                cell.place_holder_lable.hidden = YES;
                cell.leftOneLbl.hidden = NO;
                cell.leftTwoLbl.hidden = NO;
                cell.rightOneLbl.hidden = NO;
                cell.rightTwoLbl.hidden = NO;
            }
            else
            {
                cell.leftOneLbl.hidden = YES;
                cell.leftTwoLbl.hidden = YES;
                cell.rightOneLbl.hidden = YES;
                cell.rightTwoLbl.hidden = YES;
                
                cell.place_holder_lable.hidden = NO;
                cell.place_holder_lable.text = @"No work experience provided.";
            }
        }
        else if(indexPath.section == 3)
        {
            cell.place_holder_lable.hidden = YES;
            
            if([[self.profile_dictionary valueForKey:@"userEducationSet"] count] > 0){
                
                cell.leftOneLbl.text = [NSString stringWithFormat:@"%@",[[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:indexPath.row] valueForKey:@"institution"]];
                
                cell.leftTwoLbl.text = [NSString stringWithFormat:@"%@ - %@",[[[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:indexPath.row] valueForKey:@"degree"] valueForKey:@"shortTitle"], [[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:indexPath.row] valueForKey:@"fieldOfStudy"]];
                
                NSString *startDate = [[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:indexPath.row] valueForKey:@"startDate"];
                startDate = [Utility getStringWithDate:startDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                
                NSString *endDate = [[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:indexPath.row] valueForKey:@"endDate"];
                endDate = [Utility getStringWithDate:endDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                
                if([[[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:indexPath.row] valueForKey:@"isPresent"] boolValue])
                    cell.rightOneLbl.text = [NSString stringWithFormat:@"%@ - Present",startDate];
                else
                    cell.rightOneLbl.text = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];
                
                cell.rightTwoLbl.text = [[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:indexPath.row] valueForKey:@"location"];
                
                cell.place_holder_lable.hidden = YES;
                cell.leftOneLbl.hidden = NO;
                cell.leftTwoLbl.hidden = NO;
                cell.rightOneLbl.hidden = NO;
                cell.rightTwoLbl.hidden = NO;
            }
            else
            {
                cell.leftOneLbl.hidden = YES;
                cell.leftTwoLbl.hidden = YES;
                cell.rightOneLbl.hidden = YES;
                cell.rightTwoLbl.hidden = YES;
                cell.place_holder_lable.hidden = NO;
                cell.place_holder_lable.text = @"No education provided.";
            }
            
        }
        else if(indexPath.section == 4)
        {
            if([[self.profile_dictionary valueForKey:@"userAcademic"] count] > 0)
            {
                cell.leftOneLbl.text = [NSString stringWithFormat:@"%@",[[[self.profile_dictionary valueForKey:@"userAcademic"] objectAtIndex:indexPath.row] valueForKey:@"institution"]];
                
                cell.leftTwoLbl.text = [[[self.profile_dictionary valueForKey:@"userAcademic"] objectAtIndex:indexPath.row] valueForKey:@"role"];
                
                NSString *startDate = [[[self.profile_dictionary valueForKey:@"userAcademic"] objectAtIndex:indexPath.row] valueForKey:@"startDate"];
                startDate = [Utility getStringWithDate:startDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                
                NSString *endDate = [[[self.profile_dictionary valueForKey:@"userAcademic"] objectAtIndex:indexPath.row] valueForKey:@"endDate"];
                endDate = [Utility getStringWithDate:endDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                
                if([[[[self.profile_dictionary valueForKey:@"userAcademic"] objectAtIndex:indexPath.row] valueForKey:@"isPresent"] boolValue])
                    cell.rightOneLbl.text = [NSString stringWithFormat:@"%@ - Present",startDate];
                else
                    cell.rightOneLbl.text = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];
                
                cell.rightTwoLbl.text = [[[self.profile_dictionary valueForKey:@"userAcademic"] objectAtIndex:indexPath.row] valueForKey:@"location"];
                
                cell.place_holder_lable.hidden = YES;
                cell.leftOneLbl.hidden = NO;
                cell.leftTwoLbl.hidden = NO;
                cell.rightOneLbl.hidden = NO;
                cell.rightTwoLbl.hidden = NO;
            }
            else
            {
                cell.leftOneLbl.hidden = YES;
                cell.leftTwoLbl.hidden = YES;
                cell.rightOneLbl.hidden = YES;
                cell.rightTwoLbl.hidden = YES;
                cell.place_holder_lable.hidden = NO;
                cell.place_holder_lable.text = @"No academic projects provided.";
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        JobCardTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JOBCARD_TEXTVIEW_CELL_IDENTIFIER];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARDTEXTVIEWCELL owner:self options:nil];
            cell = (JobCardTextViewCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.text_view.text = [self getStringObjectFromArray:[self.profile_dictionary valueForKey:@"userSkillsSet"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}
-(IBAction)likeORpassAction:(id)sender
{
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
                                     [self callServiceForLikeOrPass:sender];
                                     [alertView dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alertView addAction:ok];
        [alertView addAction:cancel];
        [self presentViewController:alertView animated:YES completion:nil];
    }else{
        [self callServiceForLikeOrPass:sender];
    }
}

-(void)callServiceForLikeOrPass:(id)sender
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:[NSNumber numberWithInteger:1] forKey:@"recruiterProfileAction"];
    
    if ([self.profile_dictionary valueForKey:@"suggested"] !=nil)
    {
        [params setValue:[NSNumber numberWithInteger:[[self.profile_dictionary valueForKeyPath:@"suggested.suggested"]integerValue]] forKey:@"isSuggested"];
        
        [params setValue:[self.profile_dictionary valueForKeyPath:@"suggested.sort"] forKey:@"sort"];
    }
    else if ([self.profile_dictionary valueForKey:@"recommended"]!=nil)
    {
        [params setValue:[NSNumber numberWithInteger:0] forKey:@"isSuggested"];
        
        [params setValue:[self.profile_dictionary valueForKeyPath:@"recommended.sort"] forKey:@"sort"];
    }
    
    //NSString *url = [NSString stringWithFormat:@"/job/%@/user/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastCreatedJobId"],[self.profile_dictionary  valueForKey:@"userId"]];
    
    //if([[CompanyHelper sharedInstance].companyProfiles count] > 0)
      //  url = [NSString stringWithFormat:@"/likeProfileActionInPreferencesSort/job/%@/user/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastCreatedJobId"],[self.profile_dictionary valueForKey:@"userId"]];
    
    [[CompanyHelper sharedInstance] updateSwipeActionToServer:params delegate:self requestType:101 withURL:[NSString stringWithFormat:@"/likeProfileActionInPreferencesSort/job/%@/user/%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastCreatedJobId"],[self.profile_dictionary valueForKey:@"userId"]]];
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 101){
        if([[CompanyHelper sharedInstance].companyProfiles count] > 0)
            [[CompanyHelper sharedInstance].companyProfiles  removeObject:self.profile_dictionary];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{}

-(IBAction)backButtonAction:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *)getStringObjectFromArray:(NSArray *)array
{
    NSMutableString *skills = [[NSMutableString alloc] initWithCapacity:0];
    for (NSDictionary *value in array){
        if(![value isEqual:[array lastObject]])
            [skills appendFormat:@"%@ • ",[value valueForKey:@"title"]];
        else
            [skills appendFormat:@"%@",[value valueForKey:@"title"]];
    }
    return [NSString stringWithString:skills];;
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

