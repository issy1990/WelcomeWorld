//
//  WRAccountsViewController.m
//  workruit
//
//  Created by Admin on 10/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRAccountsViewController.h"
#import "WRVerifyMobileController.h"
#import "HomeWorkRuitController.h"
#import "AppDelegate.h"

@interface WRAccountsViewController ()<UITextFieldDelegate,HTTPHelper_Delegate    ,CHDropDownTextFieldDelegate,POPOVER_Delegate,WYPopoverControllerDelegate,MOBILE_NUMBER_CHANGE_DELEGATE,CustomPickerViewDelegate>
{
    PopOverListController *popListController;
    WYPopoverController *autocompleteTableView;
    
    NSArray *first_section_array;
    NSMutableDictionary *json_data;
    
    NSString *phone_number;
    
    CustomTextField *selected_text_field;
    CustomPickerView *picker_object;
    BOOL isPickerShown;
    
    NSMutableDictionary *tempCopyObject;
    IBOutlet UIView * myView;

}
@end

@implementation WRAccountsViewController
-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    if(tag == 100 && buttonIndex == 2){
        if ([Utility isComapany]) {
            [CompanyHelper sharedInstance].params = tempCopyObject;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else if(tag == 1001 && buttonIndex == 2) { //Logout Applicant
        [[ApplicantHelper sharedInstance] logOutApplicant:self requestType:104];
        [CompanyHelper sharedInstance].params = nil;
        [ApplicantHelper sharedInstance].paramsDictionary = nil;
    }
    else if(tag == 1002 && buttonIndex == 2) { //Logout compnay
        [[CompanyHelper sharedInstance] logOutCompany:self requestType:104];
        [CompanyHelper sharedInstance].params = nil;
        [ApplicantHelper sharedInstance].paramsDictionary = nil;
    }
    
}

- (void)dropDownTextField:(CHDropDownTextField *)dropDownTextField didChooseDropDownOptionAtIndex:(NSUInteger)index
{}

-(IBAction)backButtonAction:(id)sender
{
    if(!_save_button.isHidden){
        [CustomAlertView showAlertWithTitle:@"Message" message:@"Do you want discard this changes?" OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:100];
    }else{
        [CompanyHelper sharedInstance].params = tempCopyObject;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.table_view reloadData];
    
    if([Utility isComapany])
        [FireBaseAPICalls captureScreenDetails:COMPANY_ACCOUNT];
    else
        [FireBaseAPICalls captureScreenDetails:APPLICANT_ACCOUNT];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [picker_object hidePicker];
    picker_object = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.save_button.hidden = YES;
    self.table_view.hidden = YES;
    
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    //self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    if([Utility isComapany]){
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:COMPANY_PROFILE_RECRUITERVIEW setProperties:userName];
        
        
        
        first_section_array = [[NSArray alloc] initWithObjects:@"First Name",@"Last Name",@"Email",@"Phone Number",@"Company Name", nil];
        
        //if(!app_delegate.isNetAvailable)
            json_data = [[[NSUserDefaults standardUserDefaults] valueForKey:ACCOUNTS_JSON_DATA] mutableCopy];
        
        [[CompanyHelper sharedInstance] getRecruterProfile:self requestType:json_data?-100:100];
    }else{
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:APPLICANT_ACCOUNT_VIEW setProperties:userName];
        
        
        first_section_array = [[NSArray alloc] initWithObjects:@"First Name",@"Last Name",@"Email",@"Phone Number", nil];
        
        //if(!app_delegate.isNetAvailable)
            json_data = [[[NSUserDefaults standardUserDefaults] valueForKey:ACCOUNTS_JSON_DATA] mutableCopy];
        
        [[ApplicantHelper sharedInstance] getApplicantProfile:self requestType:json_data?-102:102];
    }
    
    if(json_data)
    {
        self.table_view.hidden = NO;
        [self.table_view reloadData];
    }
    
    tempCopyObject = [[CompanyHelper sharedInstance].params mutableCopy];
    
    [Utility setThescreensforiPhonex:myView];
}

-(IBAction)saveButtonAction:(id)sender
{
    NSString  *validation_message = @"";
    if(![Utility isComapany] && ![Utility mobileNumberValidation:[json_data valueForKey:@"telephone"]])
        validation_message = @"Invalid mobile number.";
    else if(([[json_data valueForKey:@"phoneNumber"] length]  < 8 ||  [[json_data valueForKey:@"phoneNumber"] length] > 11) && [Utility isComapany])
        validation_message = @"Invalid mobile number.";
    else if( ![CompanyHelper IsValidEmail:[json_data valueForKey:EMAIL_KEY]])
        validation_message = @"Invalid email address.";
    else if (([[Utility trim:[json_data valueForKey:@"firstname"]] length] == 0 && [[Utility trim:[json_data valueForKey:@"firstName"]] length] == 0) ){
        
        validation_message = @"Please enter firstName.";
        
    }
    else if (([[Utility trim:[json_data valueForKey:@"lastname"]] length] == 0 && [[Utility trim:[json_data valueForKey:@"lastName"]] length] == 0) ){
        
        validation_message = @"Please enter lastName.";
        
    }
    
    
    if([validation_message length] > 0){
        [CustomAlertView showAlertWithTitle:@"Error" message:validation_message OkButton:@"OK" delegate:self];
        return;
    }
    
    
    if([Utility isComapany]){
        NSString *jobRole = [json_data valueForKey:@"jobRole"];
        
        if([jobRole length] <= 0)
            jobRole = [CompanyHelper getJobRoleNameWithId:[json_data valueForKey:@"recruiterRole"] parantKey:@"jobRoles" childKey:@"jobRoleId"  valueKey:@"jobRoleName"];
        
        [[CompanyHelper sharedInstance] setParamsValue:jobRole forKey:@"jobRole"];
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"recruiterRole"] forKey:JOB_ROLE_ID_KEY];
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"firstName"] forKey:@"firstname"];
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"lastName"] forKey:@"lastname"];
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"phoneNumber"] forKey:@"telephone"];

        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictionary setObject:[json_data valueForKey:@"firstName"] forKey:@"firstname"];
        [dictionary setObject:[json_data valueForKey:@"lastName"] forKey:@"lastname"];
        [dictionary setObject:[json_data valueForKey:@"email"] forKey:@"email"];
        [dictionary setObject:[json_data valueForKey:@"phoneNumber"] forKey:@"telephone"];
        [dictionary setObject:[json_data valueForKey:@"companyName"] forKey:@"recruiterCompanyName"];
        [dictionary setObject:[json_data valueForKey:@"recruiterRole"] forKey:@"jobRoleId"];
        [dictionary setObject:@"iOS" forKey:@"deviceType"];
        [dictionary setObject:[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID]  forKey:@"regdId"];
        [[CompanyHelper sharedInstance] updateRecruiterProfilesWithDelegate:self requestType:101 param:dictionary];
    }else{
        if(![phone_number isEqualToString:[json_data valueForKey:@"telephone"]]){
            NSMutableDictionary *params_dic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [params_dic setObject:[json_data valueForKey:@"telephone"] forKey:TELE_PHONE_KEY];
            [[ApplicantHelper sharedInstance] otpServiceCallWithDelegete:self requestType:103 withParams:params_dic withServiceName:@"sendOTP"];
            return;
        }
        
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"firstname"] forKey:@"firstname"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"lastname"] forKey:@"lastname"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"email"] forKey:@"email"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"telephone"] forKey:@"telephone"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"location"] forKey:@"location"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"coverLetter"] forKey:@"coverLetter"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"status"] forKey:@"status"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"title"] forKey:@"title"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"experience"] forKey:@"experience"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"academic"] forKey:@"academic"];
        [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"education"] forKey:@"education"];
        
        NSLog(@"==== %@ =====",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"coverLetter"]);
        [[ApplicantHelper sharedInstance] updateApplicantServiceCallWithDelegate:self requestType:101];
    }
}

-(void)mobileNumberDidChangeWithTag:(int)tag
{
    //phone_number = [json_data valueForKey:@"telephone"];
    
    [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"firstname"] forKey:@"firstname"];
    [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"lastname"] forKey:@"lastname"];
    [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"email"] forKey:@"email"];
    [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"telephone"] forKey:@"telephone"];
    [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"location"] forKey:@"location"];
    [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"status"] forKey:@"status"];
    [[ApplicantHelper sharedInstance] setParamsValue:[json_data valueForKey:@"title"] forKey:@"title"];
    [[ApplicantHelper sharedInstance] updateApplicantServiceCallWithDelegate:self requestType:101];
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if ([Utility isComapany])
        [FireBaseAPICalls captureMixpannelEvent:COMPANY_PROFILE_EDITEMPLOYEACCOUNT];
    else
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_ACCOUNT_UPDATE];
    
    
    if(tag == 101){
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"firstname"] forKey:@"firstname"];
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"lastname"] forKey:@"lastname"];
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"telephone"] forKey:@"telephone"];
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"companyName"] forKey:@"companyName"];
        [[CompanyHelper sharedInstance] setParamsValue:[json_data valueForKey:@"recruiterRole"] forKey:@"jobRoleId"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[json_data mutableCopy] forKey:ACCOUNTS_JSON_DATA];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if (tag == 102 || tag == -102){
        data = [data valueForKey:@"data"];
        NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithCapacity:0];
        [response setObject:[data valueForKey:@"coverLetter"] forKey:@"coverLetter"];
        [response setObject:[data valueForKey:@"coverLetter"] forKey:@"about"];
        [response setObject:[data valueForKey:@"deviceType"] forKey:@"deviceType"];
        [response setObject:[data valueForKey:@"email"] forKey:@"email"];
        [response setObject:[data valueForKey:@"firstname"] forKey:@"firstname"];
        [response setObject:[data valueForKey:@"jobFunctions"] forKey:@"jobfunctions"];
        [response setObject:[data valueForKey:@"lastname"] forKey:@"lastname"];
        [response setObject:[data valueForKey:@"location"] forKey:@"location"];
        [response setObject:[data valueForKey:@"status"] forKey:@"status"];
        [response setObject:[data valueForKey:@"telephone"] forKey:@"telephone"];
        [response setObject:[data valueForKey:@"userJobTitle"] forKey:@"title"];
        phone_number = [data valueForKey:@"telephone"];
        
        [response setObject:[NSString stringWithFormat:@"%.1f",[[data valueForKey:@"totalExperience"] floatValue]] forKey:@"totalexperience"];
        [response setObject:[NSString stringWithFormat:@"%@",[data valueForKey:@"totalExperienceText"]] forKey:@"totalExperienceText"];
        
        [response setObject:[data valueForKey:@"userAcademic"] forKey:@"academic"];
        
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
        [response setObject:educationArray forKey:@"education"];
        [response setObject:[data valueForKey:@"userExperienceSet"] forKey:@"experience"];
        
        NSMutableArray *array = [data valueForKey:@"userSkillsSet"];
        NSMutableArray *skills_array = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSMutableDictionary *dictionary in array){
            [skills_array addObject:[dictionary valueForKey:@"title"]];
        }
        [response setObject:skills_array forKey:@"skills"];
        json_data = [response mutableCopy];
        if(json_data)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[json_data mutableCopy] forKey:ACCOUNTS_JSON_DATA];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.table_view.hidden = NO;
            [self.table_view reloadData];
        }
    }else if(tag == 103){
        NSString *informationString = [NSString stringWithFormat:@"OTP for Dev:%@", [data valueForKey:@"data"]];
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRVerifyMobileController *controller =[mystoryboard instantiateViewControllerWithIdentifier:WRVERIFY_MOBILE_VIEW_CONTROLLER_IDENTIFIER];
        controller.json_data_dictionary = json_data;
        controller.old_phone_number = phone_number;
        controller.myInformationForDev = informationString;
        controller.isFromAccountScreen = 100;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }else if(tag == 104){
        
        if([Utility isComapany]){
            [FireBaseAPICalls captureScreenDetails:@"company_logout"];
            [FireBaseAPICalls captureMixpannelEvent:COMPANY_GENERAL_LOGOUT];
        }else{
            [FireBaseAPICalls captureScreenDetails:@"applicant_logout"];
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_USERLOGOUT];
        }
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPLICANT_OBJECT_PARAMS];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:COMPANY_OBJECT_PARAMS];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCOUNTS_JSON_DATA];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_LOGOUT_NOTIFICATION_NAME_KEY object:nil];
    } else {
        
        json_data = [[data valueForKey:@"data"] mutableCopy];
        
        if(json_data)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[json_data mutableCopy] forKey:ACCOUNTS_JSON_DATA];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.table_view.hidden = NO;
            [self.table_view reloadData];
        }
    }
    
    NSLog(@"%@",json_data);
    
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    NSLog(@"%@**** 1 tag",error);
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [self performSelector:@selector(KeyboardStarted:) withObject:nil afterDelay:0.1];
//}
//-(void)KeyboardStarted:(id)sender
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSInteger i = [sender tag];
//        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        CreateCompanyCustomCell * nextCell = [self.table_view cellForRowAtIndexPath:nextIndexPath];
//        if ([[first_section_array objectAtIndex:i] isEqualToString:@"First Name"])
//        {
//            [nextCell.ValueTF becomeFirstResponder];
//        }
//    });
//}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(((section == 0 || section == 1) && [Utility isComapany]) || ((section == 0 || section == 1 || section == 2) && ![Utility isComapany]))
        return 40.0f;
    else return 20.0f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width-30, 30)];
    lbl.textColor = UIColorFromRGB(0x6A6A6A);
    bgView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    lbl.numberOfLines = 2;
    if(section == 0){
        lbl.text = @"PERSONAL INFORMATION";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
    }else if(section == 1){
        if([Utility isComapany])
            lbl.text = @"YOUR TITLE";
        else
            lbl.text = @"WHERE";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
    }else if (section == 2){
        if([Utility isComapany])
            lbl.text = @"";
        else
            lbl.text = @"CURRENT STATUS";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
    }else {
        lbl.text = @"";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
    }
    [bgView addSubview:lbl];
    return bgView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([Utility isComapany])
        return 4.0f;
    else return 5.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return first_section_array.count;
    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(((indexPath.section == 0 || indexPath.section == 1) && [Utility isComapany]) || ((indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) && ![Utility isComapany])){
        
        static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
        CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
            cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        }
        
        cell.ValueTF.section = indexPath.section;
        cell.ValueTF.row = indexPath.row;
        
        cell.ValueTF.enabled = NO;
        cell.ValueTF.tag = indexPath.row;
        cell.ValueTF.delegate = self;
        cell.ValueTF.returnKeyType =  UIReturnKeyDone;
        cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
        cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeWords;
        if(indexPath.section == 0){
            cell.titleLbl.text = [first_section_array objectAtIndex:indexPath.row];
            cell.ValueTF.placeholder = [first_section_array objectAtIndex:indexPath.row];
            switch (indexPath.row) {
                case 0:{
                    NSString *value = [json_data valueForKey:@"firstName"];
                    if(value == nil)
                        value = [json_data valueForKey:@"firstname"];
                    
                    cell.ValueTF.text = value;
                    cell.ValueTF.enabled = YES;
                    
                }break;
                case 1:{
                    NSString *value = [json_data valueForKey:@"lastName"];
                    if(value == nil)
                        value = [json_data valueForKey:@"lastname"];
                    
                    cell.ValueTF.text = value;
                    cell.ValueTF.enabled = YES;
                }break;
                case 2:
                    cell.ValueTF.text = [json_data valueForKey:@"email"];
                    cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    if([Utility isComapany])
                        cell.ValueTF.enabled = NO;
                    else
                        cell.ValueTF.enabled = YES;
                    
                    cell.ValueTF.keyboardType = UIKeyboardTypeEmailAddress;
                    
                    break;
                case 3:{
                    NSString *value = [json_data valueForKey:@"phoneNumber"];
                    if(value == nil)
                        value = [json_data valueForKey:@"telephone"];
                    
                    cell.ValueTF.text = value;
                    cell.ValueTF.enabled = YES;
                    cell.ValueTF.keyboardType = UIKeyboardTypePhonePad;
                }break;
                case 4:{
                    cell.ValueTF.text = [json_data valueForKey:@"companyName"];
                    if([Utility isComapany]){
                        cell.ValueTF.enabled = NO;
                        cell.ValueTF.textColor = [UIColor lightGrayColor];
                    }else
                        cell.ValueTF.enabled = YES;
                }break;
            }
        }
        else if(indexPath.section == 1){
            if([Utility isComapany]){
                cell.titleLbl.text = @"Role";
                NSString *name_value = [CompanyHelper getJobRoleNameWithId:[json_data valueForKey:@"recruiterRole"] parantKey:@"jobRoles" childKey:@"jobRoleId"  valueKey:@"jobRoleName"];
                cell.ValueTF.text = name_value;
            }else{
                cell.titleLbl.text = @"Location";
                NSString *name_value = [json_data valueForKey:@"location"];
                cell.ValueTF.text = name_value;
            }
            cell.ValueTF.delegate = self;
            cell.ValueTF.tag = 10;
            
            cell.ValueTF.enabled = NO;
        }else if(indexPath.section == 2){
            cell.titleLbl.text = @"Job Status";
            NSMutableArray *statusArray = [CompanyHelper getDropDownArrayWithTittleKey:@"statusValue" parantKey:@"curentStatus"];
            
            if([json_data valueForKey:@"status"] !=nil)
            {
                cell.ValueTF.text = [statusArray objectAtIndex:[[json_data valueForKey:@"status"] intValue]-1];

            }
            
            
            
//            if(json_data)
//                cell.ValueTF.text = [statusArray objectAtIndex:[[json_data valueForKey:@"status"] intValue]-1];
//
            cell.ValueTF.delegate = self;
            cell.ValueTF.tag = 11;
            cell.ValueTF.enabled = NO;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *cellIdentifier = MULTIPLE_SELECTION_CELL_IDENTIFIER;
        MultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MULTIPLE_SELECTION_CELL owner:self options:nil];
            cell = (MultipleSelectionCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if([Utility isComapany]){
            switch (indexPath.section) {
                case 2:
                    cell.titleLbl.text = @"Change Password";
                    cell.titleLbl.textColor = UIColorFromRGB(0x337ab7);
                    break;
                case 3:
                    cell.titleLbl.text = @"Logout";
                    cell.titleLbl.textColor = UIColorFromRGB(0xF44E4B);
                    break;
            }
        }else{
            switch (indexPath.section) {
                case 3:
                    cell.titleLbl.text = @"Change Password";
                    cell.titleLbl.textColor = UIColorFromRGB(0x337ab7);
                    break;
                case 4:
                    cell.titleLbl.text = @"Logout";
                    cell.titleLbl.textColor = UIColorFromRGB(0xF44E4B);
                    break;
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}


-(void)didSelectValue:(NSString *)value forIndex:(int)index
{
    [json_data setObject:value forKey:@"location"];
    
    [self.table_view reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.table_view reloadData];
    
    if((indexPath.section == 2 && [Utility isComapany]) || (indexPath.section == 3 && ![Utility isComapany])){
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRChangePasswordController *change_password_controller = [mystoryboard instantiateViewControllerWithIdentifier:WRCHANGE_PASSWORD_CONTROLLER_IDENTIFIER];        
        [self.navigationController pushViewController:change_password_controller animated:YES];
        
    }else if((indexPath.section == 2 && indexPath.row == 0) && ![Utility isComapany]){ //Applicant change status
        [self showActionSheet:nil];
        
    }else if((indexPath.section == 1 && indexPath.row == 0) && ![Utility isComapany]){ //Applicant change status
        
        self.save_button.hidden = NO;
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRLocationViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_LOCATION_VIEW_CONTROLLER_IDENTIFIER];
        controller.flag = 0;
        controller.comingFromAccountPage = @"AccountPage";
        controller.json_data_from_profile = json_data;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if((indexPath.section == 3 && indexPath.row == 0) && [Utility isComapany]){
        NSString *valueToSave = @"Main2";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"ChatMessagesd"];
        [CustomAlertView showAlertWithTitle:@"Are you sure?" message:@"By clicking Yes you will be logged out of this session." OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:1002];
        
    }else if((indexPath.section == 4 && indexPath.row == 0) && ! [Utility isComapany]){
        NSString *valueToSave = @"Main1";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"ChatMessagesd"];
        [CustomAlertView showAlertWithTitle:@"Are you sure?" message:@"By clicking Yes you will be logged out of this session." OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:1001];
        
    }else if((indexPath.section == 1 && indexPath.row == 0) &&  [Utility isComapany]){
        //Company change role
        [self performSelector:@selector(showPickerViewController:) withObject:tableView afterDelay:0.1];
        
    }else if((indexPath.section == 0 && indexPath.row == 2) && [Utility isComapany]){
        [CustomAlertView showAlertWithTitle:@"Alert Message" message:@"Please contact admin at support@workruit.com to change your email address." OkButton:@"Ok" delegate:self];
    }
}

- (void)showActionSheet:(id)sender {
    
    NSMutableArray *statusArray = [CompanyHelper getDropDownArrayWithTittleKey:@"statusValue" parantKey:@"curentStatus"];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    if([statusArray count]  > 0){
        [actionSheet addAction:[UIAlertAction actionWithTitle:[statusArray objectAtIndex:0] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
            // OK button tapped.
            [json_data setObject:@"1" forKey:@"status"];
            [self.table_view reloadData];
            self.save_button.hidden = NO;
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    
    if([statusArray count]  > 1){
        [actionSheet addAction:[UIAlertAction actionWithTitle:[statusArray objectAtIndex:1] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // OK button tapped.
            [json_data setObject:@"2" forKey:@"status"];
            [self.table_view reloadData];
            self.save_button.hidden = NO;
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    
    if([statusArray count]  > 2){
        [actionSheet addAction:[UIAlertAction actionWithTitle:[statusArray objectAtIndex:2] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            self.save_button.hidden = NO;
            // OK button tapped.
            [json_data setObject:@"3" forKey:@"status"];
            [self.table_view reloadData];
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Present action sheet.
        [self presentViewController:actionSheet animated:YES completion:nil];
    });
    
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag ==  10 && [Utility isComapany]) {
        [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    CustomTextField *text_field = (CustomTextField *)textField;
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];
    self.save_button.hidden = NO;
    if([Utility isComapany]){
        
        if((text_field.section == 0 && text_field.row == 3)  &&  [completeString length] > 11)
            return NO;
        
        [json_data setObject:completeString forKey:[self getKeyForIndex:(int)textField.tag]];
        
    }else{
        
        if((text_field.section == 0 && text_field.row == 3)  &&  [completeString length] > 10)
            return NO;
        
        
        if(textField.tag == 10){
            [self shwoAutoCompleteLocations:textField];
            [popListController filterTheArray:completeString];
            return YES;
        }else{
            [json_data setObject:completeString forKey:[self getKeyForIndex1:(int)textField.tag]];
        }
    }
    return YES;
}


-(void)allocPopOver
{
    popListController  = [[PopOverListController alloc] initWithNibName:@"PopOverListController" bundle:nil];
    popListController.filterdCountriesArray = [CompanyHelper getAllCities];
    popListController.allCountriesArray = [CompanyHelper getAllCities];
    popListController.delegate = self;
    
    autocompleteTableView = [[WYPopoverController alloc] initWithContentViewController:popListController];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dismissOnTap = YES;
}

-(void)shwoAutoCompleteLocations:(UITextField *)textField
{
    if(!autocompleteTableView.isPopoverVisible){
        [self allocPopOver];
        [autocompleteTableView presentPopoverFromRect:textField.bounds inView:textField permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [autocompleteTableView dismissPopoverAnimated:YES];
    [textField resignFirstResponder];
    return YES;
}

-(void)showPickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
    if(isPickerShown)
        return;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
    }];
    
    int selectedIndex = [CompanyHelper getJobRoleIdWithValue:[json_data valueForKey:@"recruiterRole"] parantKey:@"jobRoles" childKey:JOB_ROLE_ID_KEY];
    if(!picker_object){
        picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
        if(self.tabBarController)
            [self.tabBarController.view addSubview:picker_object];
        else
            [self.view addSubview:picker_object];
    }
    
    picker_object.view_height = self.view.frame.size.height;
    picker_object.delegate = self;
    picker_object.objectsArray = [CompanyHelper getDropDownArrayWithTittleKey:@"jobRoleName" parantKey:@"jobRoles"];
    [picker_object.picker_view reloadAllComponents];
    [picker_object.picker_view selectRow:selectedIndex inComponent:0 animated:YES];
    picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
    [picker_object showPicker];
    
    isPickerShown = YES;
}
-(void)didSelectPickerWithDoneClicked:(NSString *)value forTag:(int)tag
{
    isPickerShown = NO;
    if(tag == -1){
        [UIView animateWithDuration:0.25 animations:^{
            self.table_view.contentInset = UIEdgeInsetsZero;
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
        }];
        return;
    }
    
    
    self.save_button.hidden = NO;
    [json_data setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"jobRoles" childKey:@"jobRoleId"] forKey:@"recruiterRole"];
    [json_data setObject:value forKey:@"jobRole"];
    
    //        [[CompanyHelper sharedInstance] setParamsValue:value forKey:@"jobRole"];
    //     [[CompanyHelper sharedInstance] setParamsValue:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"jobRoles" childKey:@"jobRoleId"] forKey:JOB_ROLE_ID_KEY];
    
    [self.table_view reloadData];
    
}


-(NSString *)getKeyForIndex:(int)row
{
    NSString *key = @"";
    switch (row) {
        case 0:
            key = @"firstName";
            break;
        case 1:
            key = @"lastName";
            break;
        case 2:
            key = @"email";
            break;
        case 3:
            key = @"phoneNumber";
            break;
        case 4:
            key = @"companyName";
            break;
    }
    return  key;
}

-(NSString *)getKeyForIndex1:(int)row
{
    NSString *key = @"";
    switch (row) {
        case 0:
            key = @"firstname";
            break;
        case 1:
            key = @"lastname";
            break;
        case 2:
            key = @"email";
            break;
        case 3:
            key = @"telephone";
            break;
    }
    return  key;
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
