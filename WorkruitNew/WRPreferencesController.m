//
//  WRPreferencesController.m
//  workruit
//
//  Created by Admin on 11/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRPreferencesController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface WRPreferencesController ()<TTRangeSliderDelegate,UITextFieldDelegate>
{
    UILabel *experianceLbl;
    NSMutableDictionary *selected_job_dictionary;
    CustomTextField *selected_text_field;
    CustomPickerView *picker_object;
    CustomDatePicker *date_picker_object;
    BOOL isPickerShown;
    NSMutableArray * minExpArray;
    NSMutableArray * maxExpArray;
    IBOutlet UIView * myView;
    BOOL checkFirst;
    BOOL firstLoad;
    
    
}
@end

@implementation WRPreferencesController


-(IBAction)backButtonAction:(id)sender
{
    selected_job_dictionary = [CompanyHelper sharedInstance].prefrences_object;
    [CompanyHelper sharedInstance].loadJobCardsWithPrefreceSettings = NO;
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"Preferences"]==YES)
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Preferences"];
        self.tabBarController.selectedIndex = 0;
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)saveButtonAction:(id)sender
{
    [CompanyHelper sharedInstance].prefrences_object = nil;
    [CompanyHelper sharedInstance].prefrences_object = selected_job_dictionary;
    
    if([Utility isComapany])
    {
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:COMPANY_PREFERENCE_UPDATE setProperties:userName];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTheJobsFromServer:)
                                                     name:RELOADJOBSLIST
                                                   object:nil];
        [ self reloadTheJobsFromServer:nil];
        
    }else{
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        [Utility getMixpanelData:APPLICANT_PREFERENCE_UPDATE setProperties:userName];
    }
    
    if([Utility isComapany] && selected_job_dictionary)
    {
        [[CompanyHelper sharedInstance] setPrefrancesParams:[NSNumber numberWithInt:[[selected_job_dictionary valueForKeyPath:@"experienceMax"] floatValue]]    forKey:@"experienceMax"];
        
        [[CompanyHelper sharedInstance] setPrefrancesParams:[NSNumber numberWithInt:[[selected_job_dictionary valueForKeyPath:@"experienceMin"] floatValue]] forKey:@"experienceMin"];
        [[CompanyHelper sharedInstance] setPrefrancesParams:[NSNumber numberWithInt:[[selected_job_dictionary valueForKeyPath:@"jobPostId"] intValue]] forKey:@"jobPostId"];
        
        if([selected_job_dictionary valueForKeyPath:@"customLocations"] == nil || [[selected_job_dictionary valueForKeyPath:@"customLocations"] isEqualToString:@""]){
            [[CompanyHelper sharedInstance] setPrefrancesParams:@"" forKey:@"location"];
            //[[CompanyHelper sharedInstance].companyPrefrencesParams removeObjectForKey:@"location"];
        }else{
            [[CompanyHelper sharedInstance] setPrefrancesParams:[[selected_job_dictionary valueForKeyPath:@"customLocations"] mutableCopy] forKey:@"location"];
            
            [[CompanyHelper sharedInstance] setPrefrancesParams:[[selected_job_dictionary valueForKeyPath:@"customLocations"] mutableCopy] forKey:@"customLocations"];
        }
        
        [[CompanyHelper sharedInstance] setPrefrancesParams:[[selected_job_dictionary valueForKeyPath:@"jobType"] mutableCopy] forKey:@"jobType"];
        
        
        //        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        //            [[CompanyHelper sharedInstance] updatePrefrences:self requestType:100 params:[CompanyHelper sharedInstance].companyPrefrencesParams];
        //        }];
        
        [[CompanyHelper sharedInstance] updatePrefrences:self requestType:106 params:[CompanyHelper sharedInstance].companyPrefrencesParams];
        
        
        //_save_button.hidden = YES;
        //[self.navigationController popViewControllerAnimated:YES];
    }
    else{
        
        ApplicantHelper *selectedRows = [[ApplicantHelper alloc]init];
        
        NSMutableArray * tempArray;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        // [jobLocations_values_array addObjectsFromArray:[selectedRows getLocationTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobLocations"] ]];
        // [jobTypes_values_array addObjectsFromArray:[selectedRows getJobTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobTypeId"] ]];
        
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
        tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobTypes"] mutableCopy];
        else
        tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobTypes"] mutableCopy];
        
        NSMutableArray  *tempArray1 = [[[ApplicantHelper sharedInstance].paramsDictionary  valueForKey:@"SelectedRows"]mutableCopy] ;
        if (tempArray.count == 0) {
            [params setObject:[selectedRows getJobTypesIdFromArray:tempArray1] forKey:@"jobTypeId"];
        }
        else{
            [params setObject:[selectedRows getJobTypesIdFromArray:tempArray] forKey:@"jobTypeId"];
        }
        
        [params setObject:[selectedRows getLocationTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobLocations"]] forKey:@"locationId"];
        [params setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"savedExternalJobsValue"] forKey:@"hide_ext"];
        // [[NSUserDefaults standardUserDefaults]removeObjectForKey:USERJOBSFORAPPLICANTARRAY];
        // [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CheckDay_ExtJobs"];
        
        if ([[NSUserDefaults standardUserDefaults]integerForKey:@"savedExternalJobsValue"]==0) {
            // Check for the external Jobs count
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"external_jobs contains[cd] %@", @"1"];
            
            NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:USERJOBSFORAPPLICANTARRAY];
            NSMutableArray *arrayList = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
            
            NSMutableArray *results1 = [[arrayList filteredArrayUsingPredicate:predicate] mutableCopy];
            
            NSData *dataArray1 = [NSKeyedArchiver archivedDataWithRootObject:results1];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray1 forKey:@"toggleSavedAray"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERJOBSFORAPPLICANTARRAY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{
            NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"toggleSavedAray"];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:USERJOBSFORAPPLICANTARRAY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"toggleSavedAray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[ApplicantHelper sharedInstance] updateApplicantPreferences:self requestType:500 params:params];
        }];
        
        _save_button.hidden = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)clickSwitchAction:(UISwitch *)switchCases
{
    _save_button.hidden = NO;
    if (switchCases.isOn) {
        [[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"savedExternalJobsValue"];
    }
    else{
        [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"savedExternalJobsValue"];
    }
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 106)
    {
        [CompanyHelper sharedInstance].companyProfiles = [[data valueForKey:@"data"] mutableCopy];
        [CompanyHelper sharedInstance].loadJobCardsWithPrefreceSettings = YES;
        self.tabBarController.selectedIndex = 0;
        
        if([CompanyHelper sharedInstance].companyProfiles.count == 0){
            [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"title"] forKey:@"profile_screen_title"];
            [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"msg"] forKey:@"profile_screen_msg"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[[data valueForKey:@"limit"] boolValue]] forKey:@"limit"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(tag == 200 || tag == -200)
    {
        NSMutableArray *tempArray  = (NSMutableArray *)[data valueForKey:@"data"];
        BOOL isSelected = NO;
        for(NSMutableDictionary *dictionary in tempArray)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if([[dictionary valueForKey:@"jobPostId"] intValue] == [[defaults valueForKey:@"lastCreatedJobId"] intValue])
            {
                [dictionary setObject:@"1" forKey:@"selected"];
                isSelected = YES;
                
            }
            [self.jobsArray addObject:[dictionary mutableCopy]];
        }
        
        NSData *jobs = [NSKeyedArchiver archivedDataWithRootObject:self.jobsArray];
        [[NSUserDefaults standardUserDefaults]setObject:jobs forKey:@"saveCheckPref"];
        
        
        if([self.jobsArray count] > 0)
        {
            if(!isSelected)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSString stringWithFormat:@"%@",[[self.jobsArray firstObject] valueForKey:@"jobPostId"]] forKey:@"lastCreatedJobId"];
                [defaults setObject:[[self.jobsArray firstObject] valueForKey:@"title"] forKey:@"lastCreatedJobName"];
                
                NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:[self.jobsArray firstObject]];
                [defaults setObject:dataArray forKey:@"lastCreatedJobObject"];
                
                [defaults synchronize];
            }
        }
        
        // Save the load indicator firstload
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLoad"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"createdDate"
                                                                    ascending: NO];
        self.jobsArray =[[self.jobsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject: sortOrder]]mutableCopy];
        
        NSData *activeJobs = [NSKeyedArchiver archivedDataWithRootObject:self.jobsArray];
        [[NSUserDefaults standardUserDefaults] setObject:activeJobs  forKey:@"ActiveJobs"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.table_view reloadData];
    }
    else if(tag == 500)
    {
        // _save_button.hidden = YES;
        // [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    checkFirst = NO;
    
    if([Utility isComapany])
    [FireBaseAPICalls captureScreenDetails:COMPANY_PREFERENCES];
    else
    [FireBaseAPICalls captureScreenDetails:APPLICANT_PREFERENCES];
    
    if(![CompanyHelper sharedInstance].prefrences_object) {
        
        NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastCreatedJobObject"];
        [CompanyHelper sharedInstance].prefrences_object = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
    }
    selected_job_dictionary = [[CompanyHelper sharedInstance].prefrences_object mutableCopy];
    
    [self.table_view reloadData];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"firstLoad"]==NO)
    {
        if([Utility isComapany]){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [picker_object hidePicker];
    picker_object = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.jobsArray = [[NSMutableArray alloc] initWithCapacity:0];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    if([Utility isComapany]){
        [FireBaseAPICalls captureMixpannelEvent:COMPANY_PREFERENCE_VIEW];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTheJobsFromServer:)
                                                     name:RELOADJOBSLIST
                                                   object:nil];
        //[ self reloadTheJobsFromServer:nil];
        [[CompanyHelper sharedInstance] getPostedJobsOtherThanClosingWithDelegate:self requestType:-200];
    }else{
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_PREFERENCE_VIEW];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.save_button.hidden = YES;
    
    minExpArray =[[NSMutableArray alloc]initWithObjects:@"--",@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19", nil];
    
    maxExpArray =[[NSMutableArray alloc]initWithObjects:@"--",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20", nil];
    
    [Utility setThescreensforiPhonex:myView];
}

-(void)reloadTheJobsFromServer:(NSNotification *)notification
{
    [[CompanyHelper sharedInstance] getPostedJobsOtherThanClosingWithDelegate:self requestType:200];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width-30, 30)];
    lbl.textColor = UIColorFromRGB(0x6A6A6A);
    bgView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    lbl.numberOfLines = 2;
    if(section == 0)
    if([Utility isComapany]){
        lbl.text = @"JOB TITLE";
    }
    else{
        lbl.text = @"TYPE";
    }
    else if(section == 0 && self.flag == 100)
    lbl.text = @"SELECT TYPE";
    else if(section == 1)
    lbl.text = @"WHERE";
    else if(section == 2)
    if([Utility isComapany]){
        lbl.text = @"TYPE";
    }
    else{
        lbl.text = @"EXTERNAL JOBS";
    }
    else if(section == 3)
    lbl.text = @"EXPERIENCE";
    
    lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
    [bgView addSubview:lbl];
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 3 && indexPath.row == 0)
    return CELL_HEIGHT;
    else
    if([Utility isComapany]){
        return CELL_HEIGHT;
    }
    else{
        if (indexPath.section ==2)
        {
            if (indexPath.row ==0)
            {
                return CELL_HEIGHT;
            }
            else{
                return 100;
            }
        }else{
            return CELL_HEIGHT;
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([Utility isComapany]){
        if([[selected_job_dictionary valueForKeyPath:@"jobType.jobTypeTitle"] isEqualToString:@"Internship"])
        return 3.0f;
        else
        return 4.0f;
    }else
    return 2.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 3)
    return 1;//return 2;
    else
    if(section == 2)
    if([Utility isComapany]){
        return 1;
    }
    else{
        return 2;
    }
    else
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 3){
        if(indexPath.row  == 0)
        {
            static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
            CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
                cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
            }
            
            cell.ValueTF.delegate = self;
            cell.ValueTF.row = indexPath.row;
            cell.ValueTF.section = indexPath.section;
            cell.ValueTF.textColor = MainTextColor;
            cell.backgroundColor = [UIColor whiteColor];
            cell.userInteractionEnabled = YES;
            cell.titleLbl.text = @"Years";
            cell.ValueTF.placeholder = @"Add your experience";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([[selected_job_dictionary valueForKey:@"experienceMin"]intValue] == 0&&[[selected_job_dictionary valueForKey:@"experienceMax"]intValue]==0) {
            }
            else{
                cell.ValueTF.text = [NSString stringWithFormat:@"%d  - %d",[[selected_job_dictionary valueForKey:@"experienceMin"]intValue],[[selected_job_dictionary valueForKey:@"experienceMax"]intValue]];
            }
            
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
            cell.titleLbl.text = @"Enable Salary Range";
            [cell.valueSwitch addTarget:self action:@selector(hideSalaryStatusUpdate:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    else
    {
        static NSString *cellIdentifier = CUSTOM_PREFERENCES_CELL_IDNETIFIER;
        CustomPreferencesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_PREFERENCES_CELL owner:self options:nil];
            cell = (CustomPreferencesCell *)[topLevelObjects objectAtIndex:0];
        }
        NSUserDefaults *defalts = [NSUserDefaults standardUserDefaults];
        
        cell.backgroundColor = [UIColor whiteColor];
        cell.userInteractionEnabled = YES;
        
        NSMutableArray  *tempArray = nil;
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
        tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobTypes"] mutableCopy];
        else
        tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobTypes"] mutableCopy];
        
        NSMutableArray  *tempArray1 = [[[ApplicantHelper sharedInstance].paramsDictionary  valueForKey:@"SelectedRows"]mutableCopy] ;
        switch (indexPath.section) {
                case 0:
                if([Utility isComapany])
            {
                cell.titleLbl.text= @"Job";
                if([[defalts valueForKey:@"lastCreatedJobName"] length] > 0)
                cell.detailLbl.text = [NSString stringWithFormat:@"%@",[defalts valueForKey:@"lastCreatedJobName"]];
                else
                cell.detailLbl.text =  @"";
            }else{
                cell.titleLbl.text= @"Job Type";
                if (tempArray.count == 0) {
                    cell.detailLbl.text = [ApplicantHelper getJobTypesFromArray:tempArray1];
                }
                else{
                    cell.detailLbl.text = [ApplicantHelper getJobTypesFromArray:tempArray];
                }
            }
                cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
                
                break;
                case 1:
                if([Utility isComapany]){
                    cell.titleLbl.text= @"Location";
                    if([selected_job_dictionary valueForKeyPath:@"customLocations"] == nil || [[selected_job_dictionary valueForKeyPath:@"customLocations"] isEqualToString:@""])
                    cell.detailLbl.text = @"All Cities";
                    else{
                        NSString *customLocations = [selected_job_dictionary valueForKeyPath:@"customLocations"];
                        cell.detailLbl.text = [customLocations stringByReplacingOccurrencesOfString:@"," withString:@", "];
                    }
                }
                else
            {
                cell.titleLbl.text= @"Location";
                cell.detailLbl.text = [self applicantGetJobTypes:2];
                [[ApplicantHelper sharedInstance].paramsDictionary setObject:cell.detailLbl.text forKey:@"firstTimeLocation"];
            }
                cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
                
                break;
                case 2:
                if([Utility isComapany])
            {
                cell.titleLbl.text= @"Job Type";
                cell.detailLbl.text =  [selected_job_dictionary valueForKeyPath:@"jobType.jobTypeTitle"];
                cell.backgroundColor = DividerLineColor;
                cell.userInteractionEnabled = NO;
                cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
            }
                else
            {
                if (indexPath.row ==0) {
                    [cell.switchStat addTarget:self action:@selector(clickSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.switchStat.hidden = NO;
                    
                    if ([selected_job_dictionary valueForKeyPath:@"userPreferences.hide_ext"]) {
                        [[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"savedExternalJobsValue"];
                        cell.switchStat.on = YES;
                    }
                    else{
                        if ([[NSUserDefaults standardUserDefaults]integerForKey:@"savedExternalJobsValue"]== 1)
                        {
                            cell.switchStat.on = YES;
                        }
                        else{
                            [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"savedExternalJobsValue"];
                            cell.switchStat.on = NO;
                        }
                    }
                    
                    cell.titleLbl.text= @"Show External Jobs";
                    cell.backgroundColor = [UIColor whiteColor];
                    cell.userInteractionEnabled = YES;
                }
                else{
                    cell.bottomConst.constant = 120;
                    cell.titleLbl.text= @"Include jobs identified as recommendations for you from companies who have posted jobs elsewhere. Applying to these jobs will require an extra step. We'll let you know how to apply!";
                    // cell.backgroundColor = DividerLineColor;
                    cell.userInteractionEnabled = NO;
                    cell.titleLbl.textColor = UIColorFromRGB(0x6A6A6A);
                    cell.backgroundColor = UIColorFromRGB(0xEFEFF4);
                    self.table_view.separatorStyle = UITableViewCellSeparatorStyleNone;
                }
            }
                break;
            default:
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum
{
    NSString *experienceMin = [NSString stringWithFormat:@"%d.0",[[NSNumber numberWithFloat:selectedMinimum] intValue]];
    NSString *experienceMax = [NSString stringWithFormat:@"%d.0",[[NSNumber numberWithFloat:selectedMaximum] intValue]];
    experianceLbl.text = [NSString stringWithFormat:@"%@ -%@", experienceMin,experienceMax];
    
    [selected_job_dictionary setObject:experienceMin  forKey:@"experienceMin"];
    [selected_job_dictionary setObject:experienceMax forKey:@"experienceMax"];
    
    self.save_button.hidden = NO;
}

-(void)hideSalaryStatusUpdate:(id)sender
{
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CustomTextField *text_field = (CustomTextField *)textField;
    if(text_field.section == 3 && text_field.row == 0)
    {
        [self performSelector:@selector(showExperincePickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }
    return NO;
}
-(void)showExperincePickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
    if(isPickerShown)
    return;
    
    selected_text_field = (CustomTextField *)sender;
    NSString *fname;
    NSString *lname;
    
    if (selected_text_field.text.length != 0)
    {
        NSRange range = [selected_text_field.text rangeOfString:@"-"];
        fname = [selected_text_field.text substringToIndex:range.location];
        lname = [selected_text_field.text substringFromIndex:range.location+1];
    }
    
    
    NSString *titleString = @"";
    
    int numberOfComponents = 0;
    //int idx = 0;
    
    numberOfComponents = 2;
    
    titleString = @"Select experience";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        }];
        
        [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
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
        picker_object.objectsArray = minExpArray;
        picker_object.subObjectsArray = maxExpArray;
        picker_object.numberOfComponents = numberOfComponents;
        [picker_object.picker_view reloadAllComponents];
        picker_object.center = self.view.center;
        
        if (selected_text_field.text.length == 0) {
            [picker_object.picker_view selectRow:[fname integerValue] inComponent:0 animated:YES];
            [picker_object.picker_view selectRow:[lname integerValue] inComponent:1 animated:YES];
        }
        else{
            [picker_object.picker_view selectRow:[fname integerValue]+1 inComponent:0 animated:YES];
            [picker_object.picker_view selectRow:[lname integerValue] inComponent:1 animated:YES];
        }
        
        picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
        [picker_object showPicker];
    });
    isPickerShown = YES;
}
-(void)didSelectPickerWithDoneClicked:(NSString *)value withSubRow:(NSString *)subValue forTag:(int)tag
{
    self.save_button.hidden = NO;
    
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
    selected_text_field.text = [NSString stringWithFormat:@"%@ - %@",years,months];
    else
    selected_text_field.text = [NSString stringWithFormat:@"%@ - %@" ,years,months];
    
    
    NSString *experienceMin = [NSString stringWithFormat:@"%@.0",years];
    NSString *experienceMax = [NSString stringWithFormat:@"%@.0",months];
    
    int a = [experienceMin intValue];
    int b = [experienceMax intValue];
    
    if(a>b||a==b)
    {
        selected_text_field.text =@"";
        [CustomAlertView showAlertWithTitle:@"" message:@"Minimum experience cannot be greater than or equal to the Maximum experience" OkButton:@"Ok" delegate:self];
        return;
    }
    else
    {
        [selected_job_dictionary setObject:experienceMin  forKey:@"experienceMin"];
        [selected_job_dictionary setObject:experienceMax forKey:@"experienceMax"];
    }
    
    [self.table_view reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if([Utility isComapany])
    { // Company
        if(indexPath.section == 0  || indexPath.section == 2)
        {
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRPrefrenceListController *prefrence_controller = [mystoryboard instantiateViewControllerWithIdentifier:WRPREFERECES_LIST_CONTROLER_IDENTIFIER];
            if(indexPath.section == 0){
                prefrence_controller.flag = 1002;
                _save_button.hidden = YES;
            }
            else{
                _save_button.hidden = NO;
                prefrence_controller.flag = indexPath.section == 1?1001: 1000;
            }
            [self.navigationController pushViewController:prefrence_controller animated:YES];
        }
        else if(indexPath.section == 1)
        {
            _save_button.hidden = NO;
            
            //Add locations manually
            WRAddLocationManually  *addLocationManually = [[WRAddLocationManually alloc] initWithNibName:@"WRAddLocationManually" bundle:nil];
            [self.navigationController pushViewController:addLocationManually animated:YES];
        }
    }
    else
    {
        if (indexPath.section ==2) {
        }
        else{
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRPrefrenceListController *prefrence_controller = (WRPrefrenceListController *)[mystoryboard instantiateViewControllerWithIdentifier:WRPREFERECES_LIST_CONTROLER_IDENTIFIER];
            prefrence_controller.flag = 1000 + (int)indexPath.section;
            NSLog(@"%d", prefrence_controller.flag);
            [self.navigationController pushViewController:prefrence_controller animated:YES];
        }
    }
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
            else {
                [self updateForAllLocation];
                return @"All";
            }
            
        }
        else{
            for(NSMutableDictionary *dictionary in jobsArray)
            for(NSMutableDictionary *dic in tempArray)
            if([[dictionary valueForKey:@"locationId"] intValue] == [[dic valueForKey:@"locationId"] intValue])
            value =  [ApplicantHelper getJobLocationFromArray:tempArray];
            
            if([value length] > 0 && [jobsArray count] != [tempArray count])
            return value;
            else {
                [self updateForAllLocation];
                return @"All";
            }
            
        }
        
    }
}

-(void)updateForAllLocation {
    NSArray *currentPreferenceLocation = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobLocations"] mutableCopy];
    NSMutableArray *locations = [CompanyHelper getArrayWithParentKey:@"locations"];
    if (currentPreferenceLocation.count == locations.count) {
        return;
    }
    NSMutableArray *allLocations = [[NSMutableArray alloc]init];
    
    for(NSMutableDictionary *location in locations) {
        [location setValue:@"1" forKey:@"isSelected"];
        [allLocations addObject:[location copy]];
    }
    [[ApplicantHelper sharedInstance].paramsDictionary setObject:allLocations forKey:@"userPreferences.jobLocations"];
    [[ApplicantHelper sharedInstance].paramsDictionary setObject:allLocations  forKey:@"jobLocations"];
    [[ApplicantHelper sharedInstance].paramsDictionary setObject:allLocations forKey:@"SelectedRows"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
