//
//  WREditCompanyProfile.m
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WREditCompanyProfile.h"
#import "Photos/Photos.h"
#import "LoadDataManager.h"

@interface WREditCompanyProfile ()<UITextFieldDelegate,UITextViewDelegate,selectedDate,POPOVER_Delegate,WYPopoverControllerDelegate>
{
    NSArray *second_section_array;
    NSArray *second_section_placeholder_array;
    
    NSArray *third_section_array;
    NSArray *third_section_placeholder_array;
    
    CustomTextField *selected_text_field;
    
    BOOL isPickerShowns;
    
    CustomPickerView *picker_object;
    CustomDatePicker *date_picker_object;
    
    PopOverListController *popListController;
    WYPopoverController *autocompleteTableView;
    
    NSString *search_string;
    
    NSMutableDictionary *tempParamObject;
    IBOutlet UIView * myView;
    
}
@end

@implementation WREditCompanyProfile

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [FireBaseAPICalls captureScreenDetails:EDIT_COMPANY];
    
    [self.tabBarController.tabBar setHidden:NO];
    
    [self.table_view reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [FireBaseAPICalls captureScreenDetails:EDIT_COMPANY];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [picker_object hidePicker];
    picker_object = nil;
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height)+64, 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height)+44, 0.0);
    }
    
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.table_view.contentInset = contentInsets;
        self.table_view.scrollIndicatorInsets = contentInsets;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.table_view.contentInset = UIEdgeInsetsZero;
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[CompanyHelper sharedInstance] setParamsValue:@"" forKey:COMPANY_FOUNDED_YEAR_KEY];
    [[CompanyHelper sharedInstance] setParamsValue:@"" forKey:COMPANY_DESCRIPTION];
    
    NSString *firstname = [[NSUserDefaults standardUserDefaults]
                           valueForKey:FIRST_NAME_KEY];
    NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                valueForKey:RECRUITER_REGISTRATION_ID];
    
    
    NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
    
    
    [Utility getMixpanelData:COMPANY_PROFILE_VIEW setProperties:userName];
    
    NSLog(@"params final %@",[CompanyHelper sharedInstance].params);
    
    self.back_button.hidden = self.isSignUpProcess;
    
    
    // Do any additional setup after loading the view.
    second_section_array = [[NSArray alloc] initWithObjects:@"Company Name",@"Website",@"Location",@"Size",@"Founded",@"Company Description", nil];
    second_section_placeholder_array = [[NSArray alloc] initWithObjects:@"Select Company",@"http://",@"Select Location",@"Select Size",@"Mon-Year",@"Add some company info....", nil];
    
    third_section_array = [[NSArray alloc] initWithObjects:@"Facebook",@"Linkedin",@"Twitter", nil];
    third_section_placeholder_array = [[NSArray alloc] initWithObjects:@"http://facebook.com",@"http://linkedin.com",@"http://twitter.com", nil];
    
    if(self.isCommingFromFlag == 100){
        self.save_button. hidden = YES;
        
        NSString *strinName = [[[CompanyHelper sharedInstance].params valueForKey:@"size"]  valueForKey:@"csId"];
        strinName  = [CompanyHelper getJobRoleNameWithId:strinName parantKey:@"companySizes" childKey:@"csId" valueKey:@"csTitle"];
        [[CompanyHelper sharedInstance].params setObject:strinName forKey:COMAPANY_SIZE_KEY];
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *array_objects = [[CompanyHelper sharedInstance].params valueForKey:@"companyIndustriesSet"];
        for (NSMutableDictionary *dictionary in array_objects) {
            NSMutableDictionary *dic = [dictionary valueForKey:@"industry"];
            if(dic == nil)
                [array addObject:dictionary];
            else
                [array addObject:[dictionary valueForKey:@"industry"]];
        }
        [[CompanyHelper sharedInstance].params setObject:array forKey:@"companyIndustriesSet"];
    }
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    if(!self.isSignUpProcess){
        //if(app_delegate.isNetAvailable)
        // self.table_view.hidden = YES;
        [[CompanyHelper sharedInstance] getCompanyProfile:self requestType:-200];
    }
    
    tempParamObject = [[CompanyHelper sharedInstance].params mutableCopy];
    
    [Utility setThescreensforiPhonex:myView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 100.0f;
    else if(indexPath.section == 1){
        if(indexPath.row == [second_section_placeholder_array count]-1)
            return 150.0f;
        else
            return CELL_HEIGHT;
    }else
        return CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 60.0f;
    else
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
        lbl.text = @"Enter the information regarding your company here, so applicants get to know your company better.";
        lbl.font = [UIFont fontWithName:GlobalFontRegular size:14];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 40);
    }else if(section == 1){
        lbl.text = @"GENERAL PROFILE";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 2){
        lbl.text = @"INDUSTRY";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }else if(section == 3){
        lbl.text = @"SOCIAL MEDIA";
        lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        lbl.frame = CGRectMake(15, 10, self.view.frame.size.width-30, 30);
    }
    [bgView addSubview:lbl];
    
    return bgView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else if(section == 1)
        return [second_section_array count];
    else if(section == 2)
        return 1;
    else
        return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        static NSString *cellIdentifier = PROFILE_PHOTO_CUSTOM_CELL_IDENTIFIER;
        ProfilePhotoCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:PROFILE_PHOTO_CUSTOM_CELL owner:self options:nil];
            cell = (ProfilePhotoCustomCell *)[topLevelObjects objectAtIndex:0];
            [cell.buttonAction addTarget:self action:@selector(showPickerOption:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if([[[CompanyHelper sharedInstance].params valueForKey:@"pic"] length] > 0) {
            [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[CompanyHelper sharedInstance].params valueForKey:@"pic"]]]
                                  placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                           options:SDWebImageRefreshCached];
        } else {
            [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[CompanyHelper sharedInstance].params valueForKey:@"picture"]]]
                                  placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                           options:SDWebImageRefreshCached];
        }
        
        // if([CompanyHelper sharedInstance].profile_image)
        //   cell.profile_image.placeholderImage = [CompanyHelper sharedInstance].profile_image;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 1) {
        if(indexPath.row == [second_section_array count]-1) {
            static NSString *cellIdentifier = CUSTOM_COMPANY_TEXT_VIEW_CELL_IDENTIFIER;
            EditCompanyTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: CUSTOM_COMPANY_TEXT_VIEW_CELL owner:self options:nil];
                cell = (EditCompanyTextViewCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            //cell.wordCount.hidden = YES;
            cell.text_view.delegate = self;
            cell.titleLbl.text = [second_section_array objectAtIndex:indexPath.row];
            if([[Utility trim:[[CompanyHelper sharedInstance].params valueForKey:COMPANY_DESCRIPTION]] length] <= 0)
                cell.text_view.text = COMPANY_DISCRIPTION_PLACE_HOLDER;
            else {
                cell.text_view.text = [[CompanyHelper sharedInstance].params valueForKey:COMPANY_DESCRIPTION];
                //cell.wordCount.text =[NSString stringWithFormat:@"%d",(int)(150 - [cell.text_view.text length])];
                [cell.text_view setTextColor: MainTextColor];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
            CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
                cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.ValueTF.section = indexPath.section;
            cell.ValueTF.row = indexPath.row;
            NSLog(@"%@",[second_section_array objectAtIndex:indexPath.row]);
            if(indexPath.row == 1){
                cell.ValueTF.keyboardType = UIKeyboardTypeURL;
                cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
            } else
            cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
            cell.ValueTF.tag = indexPath.row + 1;
            cell.ValueTF.delegate = self;
            cell.titleLbl.text = [second_section_array objectAtIndex:indexPath.row];
            cell.ValueTF.placeholder = [second_section_placeholder_array objectAtIndex:indexPath.row];
            cell.ValueTF.text = [[CompanyHelper sharedInstance] getEditCompanyValueWithindex:(int)indexPath.section row:(int)indexPath.row];
            cell.ValueTF.returnKeyType = UIReturnKeyDone;
            cell.ValueTF.enabled = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    } else if(indexPath.section == 2) {
        static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
        CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
            cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.ValueTF.section = indexPath.section;
        cell.ValueTF.row = indexPath.row;
        
        cell.titleLbl.text = @"List of Industries";
        cell.ValueTF.tag = indexPath.row + 1;
        cell.ValueTF.delegate = self;
        cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
        cell.ValueTF.placeholder = @"";
        cell.ValueTF.returnKeyType = UIReturnKeyDone;
        
        NSArray *array = [[[CompanyHelper sharedInstance] getParamsObject] valueForKey:@"companyIndustriesSet"];
        NSMutableString *industry = [[NSMutableString alloc] initWithCapacity:0];
        
        for(NSMutableDictionary *dictionary in array) {
            if(![dictionary isEqual:[array lastObject]]) {
                [industry appendString:[NSString stringWithFormat:@"%@, ",[dictionary valueForKey:@"industryName"]]];
            } else
                [industry appendString:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"industryName"]]];
        }
        cell.ValueTF.text = industry;
        
        cell.ValueTF.enabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
        CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
            cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.ValueTF.section = indexPath.section;
        cell.ValueTF.row = indexPath.row;
        
        cell.titleLbl.text = [third_section_array objectAtIndex:indexPath.row];
        cell.ValueTF.placeholder = [third_section_placeholder_array objectAtIndex:indexPath.row];
        cell.ValueTF.tag = indexPath.row + 1;
        cell.ValueTF.delegate = self;
        cell.ValueTF.returnKeyType = UIReturnKeyDone;
        
        if([[[CompanyHelper sharedInstance].params valueForKeyPath:@"companySocialMediaLinks"] count] > 0){
            cell.ValueTF.text = [self getValueForIndex:(int)indexPath.row];
        }else
            cell.ValueTF.text = @"";
        
        cell.ValueTF.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.ValueTF.keyboardType = UIKeyboardTypeURL;
        cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        cell.ValueTF.enabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(NSString *)getValueForIndex:(int)index {
    NSString *value = @"";
    NSMutableArray *arrayObjects = [[CompanyHelper sharedInstance].params valueForKeyPath:@"companySocialMediaLinks"];
    for(NSMutableDictionary *dic in arrayObjects) {
        if(index == 0 && [[dic valueForKey:@"socialMediaName"] isEqualToString:@"Facebook"]) {
            value = [dic valueForKey:@"socialMediaValue"];
            if(value.length > 0)
                [[CompanyHelper sharedInstance].params setObject:value forKey:FACEBOOK_URL];
            break;
        } else if(index == 1 && [[dic valueForKey:@"socialMediaName"] isEqualToString:@"LinkedIn"]) {
            value = [dic valueForKey:@"socialMediaValue"];
            if(value.length > 0)
                [[CompanyHelper sharedInstance].params setObject:value forKey:LINKEDIN_URL];
            break;
        } else if(index == 2 && [[dic valueForKey:@"socialMediaName"] isEqualToString:@"Twitter"]) {
            value = [dic valueForKey:@"socialMediaValue"];
            if(value.length > 0)
                [[CompanyHelper sharedInstance].params setObject:value forKey:TWITTER_URL];
            break;
        }
    }
    return value;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    if([textView.text isEqualToString:COMPANY_DISCRIPTION_PLACE_HOLDER]) {
        [textView setTextColor:placeHolderColor];
        [textView setText:@""];
    }
    
    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0 || [textView.text isEqualToString:COMPANY_DISCRIPTION_PLACE_HOLDER]) {
        [textView setTextColor: MainTextColor];//2f2f2f
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.save_button.hidden = NO;
    [textView setTextColor: MainTextColor];//2f2f2f
   
    if (textView.text.length == 0 ) {
            [[CompanyHelper sharedInstance] setParamsValue:@"" forKey:@"about"];
        } else {
            NSString * completeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
            [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:@"about"];
        }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 2) {
        
        [self.table_view reloadData];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        WRChooseCompanyIndustry *industry = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
        industry.isNextButtonHide = YES;
        [self.navigationController pushViewController:industry animated:YES];
        
        self.save_button. hidden = NO;
    }
}

-(IBAction)previousButtonAction:(id)sender
{
    if(!_save_button.isHidden && self.isCommingFromFlag == 100){
        [CustomAlertView showAlertWithTitle:@"Message" message:@"Do you want discard this changes?" OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:100];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        [CompanyHelper sharedInstance].params = tempParamObject;
    }
}

-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    if(tag == 100 && buttonIndex == 2){
        [self.navigationController popViewControllerAnimated:YES];
        [CompanyHelper sharedInstance].params = tempParamObject;
    }else   if(buttonIndex == 2 && tag == 200){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTheSocialMediaLinks
{
    NSMutableArray *arrayObjects = [[CompanyHelper sharedInstance].params valueForKey:COMAPNY_SOCIAL_MEDIA_LINKS_KEY];
    
    for(NSMutableDictionary *dictionary in arrayObjects){
        if([[dictionary valueForKey:@"socialMediaName"] isEqualToString:@"Facebook"]){
            [[CompanyHelper sharedInstance].params setObject:[dictionary valueForKey:@"socialMediaValue"] forKey:FACEBOOK_URL];
        }else if([[dictionary valueForKey:@"socialMediaName"] isEqualToString:@"LinkedIn"]){
            [[CompanyHelper sharedInstance].params setObject:[dictionary valueForKey:@"socialMediaValue"] forKey:LINKEDIN_URL];
        }else if([[dictionary valueForKey:@"socialMediaName"] isEqualToString:@"Twitter"]){
            [[CompanyHelper sharedInstance].params setObject:[dictionary valueForKey:@"socialMediaValue"] forKey:TWITTER_URL];
        }
    }
}

- (void)congigureSocialMediaContent {
    [self setTheSocialMediaLinks];
    
    NSMutableArray *socialMediaArray = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < 3; i++){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        if(i == 0){
            [dictionary setObject:@"Facebook" forKey:@"socialMediaName"];
            if([[[CompanyHelper sharedInstance].params valueForKey:FACEBOOK_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:FACEBOOK_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://facebook.com/" forKey:@"socialMediaValue"];
        }else if(i == 1){
            [dictionary setObject:@"LinkedIn" forKey:@"socialMediaName"];
            if([[[CompanyHelper sharedInstance].params valueForKey:LINKEDIN_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:LINKEDIN_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://linkedin.com/" forKey:@"socialMediaValue"];
        }else if(i == 2){
            [dictionary setObject:@"Twitter" forKey:@"socialMediaName"];
            if([[[CompanyHelper sharedInstance].params valueForKey:TWITTER_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:TWITTER_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://twitter.com/" forKey:@"socialMediaValue"];
        }
        [socialMediaArray addObject:dictionary];
    }
    [[CompanyHelper sharedInstance].params setObject:socialMediaArray forKey:COMAPNY_SOCIAL_MEDIA_LINKS_KEY];
}

- (void)callupdateEmployerDetails {
    [[CompanyHelper sharedInstance] updateComapnyServiceCallWithDelegate:self requestType:100];
    NSString *firstname = [[NSUserDefaults standardUserDefaults]
                           valueForKey:FIRST_NAME_KEY];
    NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                valueForKey:RECRUITER_REGISTRATION_ID];
    NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
    [Utility getMixpanelData:COMPANY_PROFILE_EDIT setProperties:userName];
}

- (void)performValidationsForEmployerDetails {
    NSString *validation_message =  [[CompanyHelper sharedInstance] validateEditCompanyProfileParams];
    if([validation_message isEqualToString:SUCESS_STRING]) {

        //*************** VALIDATION SUCCESS ***************//
        [self callupdateEmployerDetails];

    } else {

        //*************** VALIDATION FAILURE ***************//
        [CustomAlertView showAlertWithTitle:@"Error" message:validation_message OkButton:@"Ok" delegate:self];

    }
}

-(IBAction)saveButtonAction:(id)sender {
    [self congigureSocialMediaContent];
    [self performValidationsForEmployerDetails];
}

-(void)createMeTabBarController
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISLOGEDIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRJobsViewController *jobsController =   [mystoryboard instantiateViewControllerWithIdentifier:WRCANDIDATE_PROFILE_CONTROLLER_IDENTIFIER];
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:jobsController];
    navController1.navigationBarHidden = YES;
    
    jobsController.title = @"Applicants";
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CustomTextField *text_field = (CustomTextField *)textField;
    if((text_field.row == 2 || text_field.row == 3 )&& text_field.section == 1 ) {
        //Location //Size
        [self showPickerViewController:textField];
        return NO;
    } else if(text_field.row == 4 && text_field.section == 1 ) {
        //Founded year
        [self showMonthYearPickerViewController:textField];
        return NO;
    } else if(text_field.row == 1 && text_field.section == 1 && [textField.text isEqualToString:@""])
        text_field.text  = @"http://";
    else  if(text_field.section == 3 && text_field.row == 0 && [textField.text isEqualToString:@""])
        textField.text = @"https://facebook.com/";
    else if(text_field.section == 3 && text_field.row == 1  && [textField.text isEqualToString:@""])
        textField.text = @"https://linkedin.com/";
    else if(text_field.section == 3 && text_field.row == 2  && [textField.text isEqualToString:@""])
        textField.text = @"https://twitter.com/";
    return  YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.save_button. hidden = NO;
    CustomTextField *text_field = (CustomTextField *)textField;
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];

    if(text_field.row == 1 && text_field.section == 1){
        if ([completeString rangeOfString:@"."].location == NSNotFound){
            [[CompanyHelper sharedInstance] setParamsValue:@"" forKey:[CompanyHelper getParamsStringWithIndex:(int)textField.tag screenId:2]];
        }else{
            [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:[CompanyHelper getParamsStringWithIndex:(int)text_field.row screenId:3]];
        }
    } else {
        if(text_field.section == 3 && text_field.row == 0){
            [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:FACEBOOK_URL];
            [self update_facebook_links_inObjects];
        }else if(text_field.section == 3 && text_field.row == 1){
            [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:LINKEDIN_URL];
            [self update_facebook_links_inObjects];
        }else if(text_field.section == 3 && text_field.row == 2 ){
            [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:TWITTER_URL];
            [self update_facebook_links_inObjects];
        }else if(text_field.section == 1 && text_field.row == 0){
            selected_text_field = (CustomTextField *)textField;
            [self shwoAutoCompleteLocations:textField];
            [popListController filterTheArrayWithBegen:completeString];
            search_string = completeString;
            [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:[CompanyHelper getParamsStringWithIndex:(int)text_field.row screenId:3]];
        }else{
            if (textField.text.length == 0) {
                [[CompanyHelper sharedInstance] setParamsValue:@"" forKey:COMPANY_FOUNDED_YEAR_KEY];
            } else {
                [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:[CompanyHelper getParamsStringWithIndex:(int)text_field.row screenId:3]];
            }
        }
    }
    return YES;
}




-(void)allocPopOver
{
    popListController  = [[PopOverListController alloc] initWithNibName:@"PopOverListController" bundle:nil];
    popListController.filterdCountriesArray = [CompanyHelper getDropDownArrayWithTittleKey:@"masterCompanyName" parantKey:@"companyNameId"];
    popListController.allCountriesArray = popListController.filterdCountriesArray;
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

-(void)didSelectValue:(NSString *)value forIndex:(int)index
{
    if([value isEqualToString:[NSString stringWithFormat:@"Add ‘%@’ as a Company",search_string]]){
        [[CompanyHelper sharedInstance] setParamsValue:search_string forKey:RECRUITER_COMPANY_NAME_KEY];
        [[CompanyHelper sharedInstance] setParamsValue:search_string forKey:COMPANY_NAME_KEY];
        
        selected_text_field.text = search_string;
    }else{
        [[CompanyHelper sharedInstance] setParamsValue:value forKey:RECRUITER_COMPANY_NAME_KEY];
        [[CompanyHelper sharedInstance] setParamsValue:value forKey:COMPANY_NAME_KEY];
        selected_text_field.text = value;
    }
    [self.table_view reloadData];
}

-(void)update_facebook_links_inObjects
{
    NSMutableArray *socialMediaArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i = 0; i < 3; i++){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        if(i == 0){
            [dictionary setObject:@"Facebook" forKey:@"socialMediaName"];
            if([[[CompanyHelper sharedInstance].params valueForKey:FACEBOOK_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:FACEBOOK_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://facebook.com/" forKey:@"socialMediaValue"];
        }else if(i == 1){
            [dictionary setObject:@"LinkedIn" forKey:@"socialMediaName"];
            if([[[CompanyHelper sharedInstance].params valueForKey:LINKEDIN_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:LINKEDIN_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://linkedin.com/" forKey:@"socialMediaValue"];
            
        }else if(i == 2){
            [dictionary setObject:@"Twitter" forKey:@"socialMediaName"];
            
            if([[[CompanyHelper sharedInstance].params valueForKey:TWITTER_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:TWITTER_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://twitter.com/" forKey:@"socialMediaValue"];
        }
        [socialMediaArray addObject:dictionary];
    }
    
    [[CompanyHelper sharedInstance].params setObject:socialMediaArray forKey:COMAPNY_SOCIAL_MEDIA_LINKS_KEY];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 150) {
        [textView setText:[textView.text substringToIndex:textView.text.length-1]];
    }
}

-(void)showPickerViewController:(id)sender
{
    
    if(isPickerShowns)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    selected_text_field  = (CustomTextField *)sender;
    
    NSString *titleStr = @"";
    NSMutableArray *array;
    int idx = 0;
    if(selected_text_field.row == 3 && selected_text_field.section == 1)
    {
        titleStr = @"Company Size";
        array = [CompanyHelper getDropDownArrayWithTittleKey:@"csTitle" parantKey:@"companySizes"];
        
        idx = [CompanyHelper getJobRoleIdWithValue:[[CompanyHelper sharedInstance].params valueForKey:COMAPANY_SIZE_KEY] parantKey:@"companySizes" childKey:@"csTitle"];
        
    } else  if(selected_text_field.row == 2 && selected_text_field.section == 1){
        titleStr = @"Company Location";
        array = [CompanyHelper getDropDownArrayWithTittleKey:@"title" parantKey:@"locations"];
        idx = [CompanyHelper getJobRoleIdWithValue:[[CompanyHelper sharedInstance].params valueForKey:LOCATION_NAME_KEY] parantKey:@"locations" childKey:@"title"];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
    }];
    
    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    selected_text_field = (CustomTextField *)sender;
    if(!picker_object){
        picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
        if(self.tabBarController)
            [self.tabBarController.view addSubview:picker_object];
        else
            [self.view addSubview:picker_object];
    }
    
    picker_object.view_height = self.view.frame.size.height;
    picker_object.delegate = self;
    picker_object.objectsArray = array;
    [picker_object.picker_view reloadAllComponents];
    [picker_object.picker_view selectRow:idx inComponent:0 animated:YES];
    picker_object.selected_index = idx;
    picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
    [picker_object showPicker];
    
    isPickerShowns = YES;
}

-(void)didSelectPickerWithDoneClicked:(NSString *)value forTag:(int)tag
{
    isPickerShowns = NO;
    
    self.save_button. hidden = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.table_view.contentInset = UIEdgeInsetsZero;
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
    
    if(tag == -1)
        return;
    
    if(selected_text_field.row == 3 && selected_text_field.section == 1){
        
        self.save_button. hidden = NO;
        [[CompanyHelper sharedInstance] setParamsValue:value forKey:COMAPANY_SIZE_KEY];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictionary setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"companySizes" childKey:@"csId"] forKey:CSID_KEY];
        [[CompanyHelper sharedInstance].params setObject:dictionary forKey:SIZE_KEY];
        
    }else  if(selected_text_field.row == 2 && selected_text_field.section == 1){
        
        [[CompanyHelper sharedInstance] setParamsValue:value forKey:LOCATION_NAME_KEY];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictionary setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"locations" childKey:@"locationId"] forKey:LOCATION_ID_KEY];
        [[CompanyHelper sharedInstance].params setObject:dictionary forKey:LOCATION_KEY];
    }
    selected_text_field.text = value;
}

-(void)showMonthYearPickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
    if(isPickerShowns)
        return;
    
    selected_text_field  = (CustomTextField *)sender;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
    }];
    
    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    NSString *dateStr = [[CompanyHelper sharedInstance].params valueForKey:COMPANY_FOUNDED_YEAR_KEY];
    NSDate *selected_date = [Utility getDateWithStringDate:dateStr withFormat:@"MMM yyyy"];
    if(selected_date == nil)
        selected_date = [NSDate date];
    
    if(!date_picker_object){
        date_picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomDatePicker" owner:self options:nil] objectAtIndex:0];
        if(self.tabBarController)
            [self.tabBarController.view addSubview:date_picker_object];
        else
            [self.view addSubview:date_picker_object];
        
    }
    
    date_picker_object.view_height = self.view.frame.size.height;
    date_picker_object.delegate = self;
    [date_picker_object.date_picker setDate:selected_date];
    date_picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
    [date_picker_object showPicker];
    
    isPickerShowns = YES;
}

-(void)didSelectDateWithDoneClicked:(NSString *)value forTag:(NSDate *)date
{
    isPickerShowns = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.table_view.contentInset = UIEdgeInsetsZero;
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
    
    if(date == nil)
        return;
    self.save_button. hidden = NO;
    
    [[CompanyHelper sharedInstance] setParamsValue:[Utility getStringWithDate:date withFormat:@"MMM yyyy"]  forKey:COMPANY_FOUNDED_YEAR_KEY];
    selected_text_field.text = [Utility getStringWithDate:date withFormat:@"MMM yyyy"];
    
    
}

//Cancel button action on picker
-(void)clickToCancel:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
}

-(void)DateDoneButtonClicked:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    ;
    [self.table_view reloadData];
}
-(void)selectedDate:(NSString*)str withView:(UIPickerView*)picker
{
    [[CompanyHelper sharedInstance] setParamsValue:str  forKey:COMPANY_FOUNDED_YEAR_KEY];
}


-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    
    if(tag == 200 || tag == -200){
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:COMPANY_COMPANYFULL setProperties:userName];
        
        
        [[CompanyHelper sharedInstance].params setObject:[data valueForKeyPath:@"data.about"] forKey:@"about"];
        
        NSMutableArray *arrayObjects = [[data valueForKeyPath:@"data.companyIndustriesSet"] mutableCopy];
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSMutableDictionary *dictionary in arrayObjects){
            [tempArray addObject:[dictionary valueForKey:@"industry"]];
        }
        [[CompanyHelper sharedInstance].params setObject:[tempArray mutableCopy] forKey:@"companyIndustriesSet"];
        [[CompanyHelper sharedInstance].params setObject:[data valueForKeyPath:@"data.companyName"] forKey:@"companyName"];
        [[CompanyHelper sharedInstance].params setObject:[[data valueForKeyPath:@"data.companySocialMediaLinks"] mutableCopy] forKey:@"companySocialMediaLinks"];
        
        [[CompanyHelper sharedInstance].params setObject:[data valueForKeyPath:@"data.size.csTitle"] forKey:@"company_size"];
        [[CompanyHelper sharedInstance].params setObject:[data valueForKeyPath:@"data.size.csTitle"] forKey:@"company_size"];
        [[CompanyHelper sharedInstance].params setObject:[data valueForKeyPath:@"data.establishedDate"] forKey:@"establishedDate"];
        [[CompanyHelper sharedInstance].params setObject:[data valueForKeyPath:@"data.picture"] forKey:@"picture"];
        [[CompanyHelper sharedInstance].params setObject:[[data valueForKeyPath:@"data.location"] mutableCopy] forKey:@"location"];
        [[CompanyHelper sharedInstance].params setObject:[[data valueForKeyPath:@"data.location.title"] mutableCopy] forKey:LOCATION_NAME_KEY];
        
        [[CompanyHelper sharedInstance].params setObject:[[data valueForKeyPath:@"data.size"] mutableCopy] forKey:@"size"];
        [[CompanyHelper sharedInstance].params setObject:[data valueForKeyPath:@"data.website"] forKey:@"website"];
        [self.table_view reloadData];
        //self.table_view.hidden = NO;
        return;
    }
    
    
    if(self.isCommingFromFlag == 100){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [Utility saveCompanyObject:[CompanyHelper sharedInstance]];
        [self createMeTabBarController];
        
        [FireBaseAPICalls captureScreenDetails:COMPANY_FULLPROFILE_DONE];
    }
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag{
}



-(void)showPickerOption:(id)sender
{
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Choose Image" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *finish = [UIAlertAction actionWithTitle:@"Take New Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                                 if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                     [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
                             }];
    
    UIAlertAction *playAgain = [UIAlertAction actionWithTitle:@"Select from library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                             {
                                 [actionSheetController dismissViewControllerAnimated:YES completion:nil];
                             }];
    [actionSheetController addAction:finish];
    [actionSheetController addAction:playAgain];
    [actionSheetController addAction:cancel];
    [self.navigationController presentViewController:actionSheetController animated:YES completion:nil];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    [self.tabBarController.tabBar setHidden:YES];
    
    if(sourceType == UIImagePickerControllerSourceTypePhotoLibrary || sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum){
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized) {
            // Access has been granted.
            [self popCamera:sourceType];
        }else if (status == PHAuthorizationStatusDenied) {
            // Access has been denied.
            [CustomAlertView showAlertWithTitle:nil message:@"Workruit does not have access to your photos. To enable access, tap Settings and turn on Photos." OkButton:@"Cancel" cancelButton:@"Settings" delegate:self withTag:100];
        }else if (status == PHAuthorizationStatusNotDetermined) {
            // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                    [self popCamera:sourceType];
                }else {
                    // Access has been denied.
                    [self camDenied];
                }
            }];
        } else if (status == PHAuthorizationStatusRestricted) {
            // Restricted access - normally won't happen.
            [CustomAlertView showAlertWithTitle:nil message:@"Workruit does not have access to your photos. To enable access, tap Settings and turn on Photos." OkButton:@"Cancel" cancelButton:@"Settings" delegate:self withTag:100];
        }
    }else{
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized)
        {
            [self popCamera:sourceType];
        }
        else if(authStatus == AVAuthorizationStatusNotDetermined)
        {
            NSLog(@"%@", @"Camera access not determined. Ask for permission.");
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 if(granted)
                 {
                     NSLog(@"Granted access to %@", AVMediaTypeVideo);
                     [self popCamera:sourceType];
                 }
                 else
                 {
                     NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                     [self camDenied];
                 }
             }];
        }
        else if (authStatus == AVAuthorizationStatusRestricted)
        {
            // My own Helper class is used here to pop a dialog in one simple line.
            [CustomAlertView showAlertWithTitle:nil message:@"Workruit does not have access to your photos. To enable access, tap Settings and turn on Photos." OkButton:@"Cancel" cancelButton:@"Settings" delegate:self withTag:200];
        }
        else
        {
            [CustomAlertView showAlertWithTitle:nil message:@"Workruit does not have access to your photos. To enable access, tap Settings and turn on Photos." OkButton:@"Cancel" cancelButton:@"Settings" delegate:self withTag:200];
        }
    }
}

-(void)popCamera:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.hidesBottomBarWhenPushed = YES;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.edgesForExtendedLayout = UIRectEdgeAll;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[[UIApplication sharedApplication].delegate window] rootViewController] presentViewController:imagePickerController animated:NO completion:nil];
    });
}

-(void)camDenied
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
    imageCropVC.delegate = self;
    imageCropVC.hidesBottomBarWhenPushed = YES;
    [imageCropVC setAvoidEmptySpaceAroundImage:YES];
    [self.navigationController pushViewController:imageCropVC animated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma IMAGE CROP DELEGATE AND DATASOURCES METHODS

// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    self.save_button.hidden = NO;
    UIImage *image = [Utility resizeImage:croppedImage];
    
    [CompanyHelper sharedInstance].profile_image = image;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    NSData *imageData = UIImageJPEGRepresentation(image,0.5);
    //  NSData *imageData = [Utility getMinDataForImage:croppedImage scale:1.0f];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"cached"]];
    
    if (![imageData writeToFile:imagePath atomically:NO])
    {
        NSLog((@"Failed to cache image data to disk"));
    }
    else
    {
        NSLog(@"the cachedImagedPath is %@",imagePath);
        [self uploadProfilePicWithURL:imagePath];
    }
    [self.table_view reloadData];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage
{
    // Use when `applyMaskToCroppedImage` set to YES.
}


// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGSize maskSize;
    if ([controller isPortraitInterfaceOrientation]) {
        maskSize = CGSizeMake(250, 250);
    } else {
        maskSize = CGSizeMake(220, 220);
    }
    
    CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
    CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
    
    CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                 (viewHeight - maskSize.height) * 0.5f,
                                 maskSize.width,
                                 maskSize.height);
    
    return maskRect;
}

-(void)uploadProfilePicWithURL:(NSString *)imagePath
{
    
    
    NSString *firstname = [[NSUserDefaults standardUserDefaults]
                           valueForKey:FIRST_NAME_KEY];
    NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                valueForKey:RECRUITER_REGISTRATION_ID];
    
    
    NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
    
    
    [Utility getMixpanelData:COMPANY_PROFILE_ADDPIC setProperties:userName];
    
    
    NSMutableDictionary *parmas = [[NSMutableDictionary alloc] initWithCapacity:0];
    if([Utility isComapany])
        [parmas setObject:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:SAVE_COMPANY_ID]] forKey:@"companyId"];
    else
        [parmas setObject:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]] forKey:@"userId"];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", API_BASE_URL,UPLOAD_COMPANY_LOGO_API] parameters:parmas constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:imagePath] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
    } error:nil];
    
    NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    if([session_id length] > 10){
        [request setValue:session_id forHTTPHeaderField:@"Token"];
    }
    else{
        NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"sessionName"];
        [request setValue:savedValue forHTTPHeaderField:@"Token"];
        
    }
    
    NSString *authorization = [NSString stringWithFormat:@"%@:%@",USERNAME,PASSWORD];
    authorization = [Utility encodeStringTo64:authorization] ;
    [request setValue:[NSString stringWithFormat:@"Basic %@",authorization] forHTTPHeaderField:@"Authorization"];
    
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          // [progressView setProgress:uploadProgress.fractionCompleted];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                          if([[responseObject valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
                          {
                              [[CompanyHelper sharedInstance] setParamsValue:[[responseObject valueForKey:@"data"] valueForKey:@"filePath"] forKey:@"pic"];
                              [[CompanyHelper sharedInstance] setParamsValue:[[responseObject valueForKey:@"data"] valueForKey:@"filePath"] forKey:@"picture"];
                              [self.table_view reloadData];
                          }
                          
                      }
                  }];
    
    [uploadTask resume];
}
@end

