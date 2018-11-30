//
//  WRSettingsViewController.m
//  workruit
//
//  Created by Admin on 10/9/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRSettingsViewController.h"
#import "HeaderFiles.h"

@interface WRSettingsViewController ()<HTTPHelper_Delegate>
{
    NSArray *first_section_array;
    IBOutlet UIView * myView;

    
}
@end

@implementation WRSettingsViewController

-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([Utility isComapany])
        [FireBaseAPICalls captureScreenDetails:COMPANY_SETTINGS];
    else
        [FireBaseAPICalls captureScreenDetails:APPLICANT_SETTINGS];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if(![[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userSettings"]){
        [[ApplicantHelper sharedInstance] updateTheDefaultUserSettingsParams];
    }
    if ([Utility isComapany]) {
        [FireBaseAPICalls captureMixpannelEvent:COMPANY_SETTINGS_VIEW];
    }else{
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_SETTINGS_VIEW];
    }
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIView *borderLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [borderLine1 setBackgroundColor:UIColorFromRGB(0xEFEFF4)];
    self.table_view.tableFooterView = borderLine1;
    
    
    UIView *borderLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    self.table_view.tableHeaderView = borderLine2;

    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    first_section_array  =  [[NSArray alloc] initWithObjects:@"Title",@"Job Function",@"Location", nil];
    
    [Utility setThescreensforiPhonex:myView];

}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 50.0f;
        else
            return 40.0f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width-30, 30)];
    if(section == 0){
        bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
        lbl.frame = CGRectMake(15, 20, self.view.frame.size.width-30, 30);
    }
    else{
        bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }

    lbl.textColor = UIColorFromRGB(0x6A6A6A);
    bgView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    if(section == 0)lbl.text = @"NOTIFICATIONS";
    else if(section == 1) lbl.text = @"MORE";
    else if(section == 2) lbl.text = @"LEGAL";
    else  lbl.text = @"";
        
    lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
    [bgView addSubview:lbl];
    return bgView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else if(section == 1 || section == 2)
        return 2;
    else return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        static NSString *cellIdentifier = SETTINGS_CUSTOM_CELL_IDENTIFIER;
        SettingCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:SETTINGS_CUSTOM_CELL owner:self options:nil];
            cell = (SettingCustomCell *)[topLevelObjects objectAtIndex:0];
            
            [cell.mail_button addTarget:self action:@selector(mailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.mobile_button  addTarget:self action:@selector(mobileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSMutableDictionary *dictionary = [Utility isComapany]?[[CompanyHelper sharedInstance].params valueForKey:@"userSettings"]:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userSettings"];
    
        cell.mail_button.selected = [[dictionary valueForKeyPath:[Utility isComapany]?@"newCandidates.email":@"newJobs.email"] boolValue];
        cell.mobile_button.selected = [[dictionary valueForKeyPath:[Utility isComapany]?@"newCandidates.mobile":@"newJobs.mobile"] boolValue];
        
        if([[dictionary valueForKeyPath:[Utility isComapany]?@"newCandidates.email":@"newJobs.email"] boolValue])
            [cell.mail_button setImage:[UIImage imageNamed:@"mail_notification_on"] forState:UIControlStateNormal];
        else
                [cell.mail_button setImage:[UIImage imageNamed:@"mail_notification_off"] forState:UIControlStateNormal];
        
        if([[dictionary valueForKeyPath:[Utility isComapany]?@"newCandidates.mobile":@"newJobs.mobile"] boolValue])
            [cell.mobile_button setImage:[UIImage imageNamed:@"mobile_notification_on"] forState:UIControlStateNormal];
        else
            [cell.mobile_button setImage:[UIImage imageNamed:@"mobile_notification_off"] forState:UIControlStateNormal];

        cell.mail_button.tag = indexPath.row;
        cell.mobile_button.tag = indexPath.row;

        cell.titleLbl.text = @"Daily Notifications";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    }else if(indexPath.section == 1){
        static NSString *cellIdentifier = MULTIPLE_SELECTION_CELL_IDENTIFIER;
        MultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MULTIPLE_SELECTION_CELL owner:self options:nil];
            cell = (MultipleSelectionCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row) {
            case 0:
                    cell.titleLbl.text = @"Invite Your Friends";
                break;
            case 1:
                    cell.titleLbl.text = @"Frequently Asked Questions";
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    }else if(indexPath.section == 2){
        static NSString *cellIdentifier = MULTIPLE_SELECTION_CELL_IDENTIFIER;
        MultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MULTIPLE_SELECTION_CELL owner:self options:nil];
            cell = (MultipleSelectionCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row) {
            case 0:
                cell.titleLbl.text = @"Privacy Policy";
                break;
            case 1:
                cell.titleLbl.text = @"Terms and Conditions";
                break;
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
        cell.accessoryType = UITableViewCellAccessoryNone;
        switch (indexPath.row) {
            case 0:
                cell.titleLbl.text = [NSString stringWithFormat:@"Version  %@",[Utility getAppVersionNumber]];
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
 }
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 0)
        [self.table_view reloadData];

        if(indexPath.section == 1 && indexPath.row == 0){
            
            NSString *shareText;
            if([Utility isComapany])
                shareText = [NSString stringWithFormat:@"Update your recruitment process with new-age technology. It’s fast, accurate and effective. Get Workruit now!\nhttps://workruit.com/download"];
            else
                shareText = [NSString stringWithFormat:@"Simple, effective and no-nonsense. That's how finding a job should be. Get the Workruit app now, https://workruit.com/download"];
            
            NSArray *itemsToShare = @[shareText];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeMail, UIActivityTypePostToTencentWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard];
            [self presentViewController:activityVC animated:YES completion:nil];
            return;
        }else  if(indexPath.section == 1 && indexPath.row == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.workruit.com/faq"]];
        }else  if(indexPath.section == 2 && indexPath.row == 0){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.workruit.com/privacy"]];
        }else  if(indexPath.section == 2 && indexPath.row == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.workruit.com/terms"]];
        }
}

-(void)mailButtonClicked:(id)sender
{
    
    NSMutableDictionary *dictionary1 = [Utility isComapany]?[[[CompanyHelper sharedInstance].params valueForKey:@"userSettings"] mutableCopy]:[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userSettings"] mutableCopy];
    
    if(dictionary1 == nil)
        dictionary1 = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary *params_dictionary = [[dictionary1 valueForKeyPath:[Utility isComapany]?@"newCandidates":@"newJobs"] mutableCopy];
    
    if(params_dictionary == nil)
        params_dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];

    
    UIButton *button = (UIButton *)sender;
    if(button.isSelected)
    {
        [params_dictionary setObject:@"0" forKey:@"email"];
        button.selected = NO;
        [button setImage:[UIImage imageNamed:@"mail_notification_off"] forState:UIControlStateNormal];
    }else{
        [params_dictionary setObject:@"1" forKey:@"email"];
        button.selected = YES;
        [button setImage:[UIImage imageNamed:@"mail_notification_on"] forState:UIControlStateNormal];
    }
    [dictionary1 setObject:params_dictionary forKey:[Utility isComapany]?@"newCandidates":@"newJobs"];
    
    if([Utility isComapany])
        [[CompanyHelper sharedInstance].params setObject:dictionary1 forKey:@"userSettings"];
   else
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:dictionary1 forKey:@"userSettings"];
    
    [Utility isComapany]?[self updateRecruiterSettings]:[self updateApplicantSettings];

}

-(void)mobileButtonClicked:(id)sender
{
    
    NSMutableDictionary *dictionary1 = [Utility isComapany]?[[[CompanyHelper sharedInstance].params valueForKey:@"userSettings"] mutableCopy]:[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userSettings"] mutableCopy];
    
    if(dictionary1 == nil)
        dictionary1 = [[NSMutableDictionary alloc] initWithCapacity:0];

    NSMutableDictionary *params_dictionary = [[dictionary1 valueForKeyPath:[Utility isComapany]?@"newCandidates":@"newJobs"] mutableCopy];
    
    if(params_dictionary == nil)
        params_dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];


    UIButton *button = (UIButton *)sender;
    if(button.isSelected)
    {
        [params_dictionary setObject:@"0" forKey:@"mobile"];
        button.selected = NO;
        [button setImage:[UIImage imageNamed:@"mobile_notification_off"] forState:UIControlStateNormal];
    }else{
        [params_dictionary setObject:@"1" forKey:@"mobile"];
        button.selected = YES;
        [button setImage:[UIImage imageNamed:@"mobile_notification_on"] forState:UIControlStateNormal];
    }
    [dictionary1 setObject:params_dictionary forKey:[Utility isComapany]?@"newCandidates":@"newJobs"];

    
    if([Utility isComapany])
        [[CompanyHelper sharedInstance].params setObject:dictionary1 forKey:@"userSettings"];
    else
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:dictionary1 forKey:@"userSettings"];
    
    [Utility isComapany]?[self updateRecruiterSettings]:[self updateApplicantSettings];

}

-(void)updateRecruiterSettings
{
    //user/278/updateRecruiterSettings
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/updateRecruiterSettings",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:[[CompanyHelper sharedInstance].params valueForKeyPath:@"userSettings"] forKey:@"recruiterSettings"];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager startRequestWithURL:url  WithParams:[CompanyHelper convertDictionaryToJSONString:params] forRequest:-1 controller:self httpMethod:HTTP_POST];

}


-(void)updateApplicantSettings
{
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/updateUserSettings",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userSettings"] forKey:@"userSettings"];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager startRequestWithURL:url  WithParams:[CompanyHelper convertDictionaryToJSONString:params] forRequest:-1 controller:self httpMethod:HTTP_POST];
    
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if ([Utility isComapany]) {
        [FireBaseAPICalls captureMixpannelEvent:COMPANY_SETTINGS_UPDATE];
    }else{
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_SETTINGS_UPDATE];
    }
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
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
