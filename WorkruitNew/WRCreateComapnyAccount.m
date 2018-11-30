//
//  WRCreateComapnyAccount.m
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRCreateComapnyAccount.h"
#import "WRVerifyMobileController.h"
#import "Mixpanel/Mixpanel.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface WRCreateComapnyAccount ()<UITextFieldDelegate,HTTPHelper_Delegate,CustomPickerViewDelegate,POPOVER_Delegate,WYPopoverControllerDelegate>
{
    NSArray *titleArray;
    CustomTextField *selected_text_field;
    CustomPickerView *picker_object;

    PopOverListController *popListController;
    WYPopoverController *autocompleteTableView;
    
    NSString *search_string;
    BOOL isPickerShown;
    
    UITextField *passwordSecureTF;
    IBOutlet UIView * myView;

}
@end

@implementation WRCreateComapnyAccount

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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


-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        titleArray = [[NSArray alloc] initWithObjects:@"First Name",@"Last Name",@"Email",@"Password",@"Phone Number",@"Company Name",@"Your Role", nil];
    [Mixpanel sharedInstanceWithToken:MIX_PANEL];

    //Setting the table view footer view to zeero
    self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];

    [self.table_view setSeparatorColor:DividerLineColor];
    
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc]initWithString:self.terms_condtion_lable.text];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0f green:122/255.0f blue:183/255.0f alpha:1.0f] range:NSMakeRange(68, 21)];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0f green:122/255.0f blue:183/255.0f alpha:1.0f] range:NSMakeRange(93, 15)];
    self.terms_condtion_lable.attributedText = string;
    
    [Utility setThescreensforiPhonex:myView];
    
}

-(IBAction)openURLWithAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == 10){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.workruit.com/terms"]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.workruit.com/privacy"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated{
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0f;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([Utility isComapany])
        return titleArray.count;
    else
        return titleArray.count-2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
    CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
        cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
    }
    cell.titleLbl.text = [titleArray objectAtIndex:indexPath.row];
    cell.ValueTF.tag = indexPath.row + 1;
    cell.ValueTF.delegate = self;
    cell.ValueTF.row = indexPath.row;
    cell.ValueTF.section = indexPath.section;
    
    if(indexPath.row == [titleArray count] -1)
    {
        cell.ValueTF.placeholder = [NSString stringWithFormat:@"Select %@",[titleArray objectAtIndex:indexPath.row]];
        cell.ValueTF.secureTextEntry = NO;
    }else if(indexPath.row == 3){
        cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
        cell.ValueTF.secureTextEntry = YES;
        cell.ValueTF.placeholder = [NSString stringWithFormat:@"Enter %@",[titleArray objectAtIndex:indexPath.row]];
        passwordSecureTF = cell.ValueTF;
    }else{
        if(indexPath.row == 2){
            cell.ValueTF.keyboardType = UIKeyboardTypeEmailAddress;
            cell.ValueTF.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        }else if(indexPath.row == 4){
            cell.ValueTF.keyboardType = UIKeyboardTypePhonePad;
            cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        }else{
            cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
        }
        cell.ValueTF.placeholder = [NSString stringWithFormat:@"Enter %@",[titleArray objectAtIndex:indexPath.row]];
        cell.ValueTF.secureTextEntry = NO;
    }
    cell.ValueTF.text = [self getValueFromParamsDictionary:(int)indexPath.row];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(KeyboardStarted:) withObject:nil afterDelay:0.1];
}
-(void)KeyboardStarted:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger i = [sender tag];
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CreateCompanyCustomCell * nextCell = [self.table_view cellForRowAtIndexPath:nextIndexPath];
        if ([[titleArray objectAtIndex:i] isEqualToString:@"First Name"])
        {
            [nextCell.ValueTF becomeFirstResponder];
        }
    });
}

-(NSString *)getValueFromParamsDictionary:(int)tag
{
    NSString *key  = @"";
        if(tag == 0)
            key = FIRST_NAME_KEY;
        else if(tag == 1)
            key = LAST_NAME_KEY;
        else if(tag == 2)
            key = EMAIL_KEY;
        else if(tag == 3)
            key = PASSWORD_KEY;
        else if(tag == 4)
            key = TELE_PHONE_KEY;
        else if(tag == 5)
            key = RECRUITER_COMPANY_NAME_KEY;
        else
            key = JOB_ROLE_KEY;
    
    return [[Utility isComapany]?[CompanyHelper sharedInstance].params:[ApplicantHelper sharedInstance].paramsDictionary valueForKey:key];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag ==  [titleArray count] && [Utility isComapany]){
            [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];
    CustomTextField *text_field = (CustomTextField *)textField;

    if([Utility isComapany]){
        if(textField.tag == 6){
            selected_text_field = (CustomTextField *)textField;
            search_string = completeString;
            [self shwoAutoCompleteLocations:textField];
            [popListController filterTheArrayWithBegen:completeString];
            
            if([string isEqualToString:@""] && [[[CompanyHelper sharedInstance].params valueForKey:@"recruiterCompanyName"] length] > 0)
                [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:[CompanyHelper getParamsStringWithIndex:(int)textField.tag screenId:1]];
        }else {
            if(textField.tag == 5 && [completeString length] > 11)
                return NO;

            [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:[CompanyHelper getParamsStringWithIndex:(int)textField.tag screenId:1]];
        }
    }else{
        
        if((text_field.section == 0 && text_field.row == 4)  &&  [completeString length] > 10)
            return NO;
        
        [[ApplicantHelper sharedInstance] setParamsValue:completeString forKey:[CompanyHelper getParamsStringWithIndex:(int)textField.tag screenId:1]];
    }

    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [autocompleteTableView dismissPopoverAnimated:YES];

    CreateCompanyCustomCell * currentCell = (CreateCompanyCustomCell *) textField.superview.superview;
    NSIndexPath * currentIndexPath = [self.table_view indexPathForCell:currentCell];
    
    if (currentIndexPath.row != [titleArray count] - 1) {
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:0];
        CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
        [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [nextCell.ValueTF becomeFirstResponder];
    }
    return YES;
}

-(void)didSelectValue:(NSString *)value forIndex:(int)index
{
    if([value isEqualToString:[NSString stringWithFormat:@"Add ‘%@’ as a Company",search_string]]){
        [[CompanyHelper sharedInstance] setParamsValue:search_string forKey:RECRUITER_COMPANY_NAME_KEY];
        selected_text_field.text = search_string;
    }else{
        [[CompanyHelper sharedInstance] setParamsValue:value forKey:RECRUITER_COMPANY_NAME_KEY];
        selected_text_field.text = value;
    }
    
    
    [self.table_view reloadData];
}

-(IBAction)nextButtonForProcess:(id)sender
{
    NSString *validation_message =  @"";
    if([Utility isComapany]){
        [[CompanyHelper sharedInstance] setParamsValue:passwordSecureTF.text forKey:[CompanyHelper getParamsStringWithIndex:4 screenId:1]];
        validation_message =  [[CompanyHelper sharedInstance] validateRequestParams];
    }else{
        [[ApplicantHelper sharedInstance] setParamsValue:passwordSecureTF.text forKey:[CompanyHelper getParamsStringWithIndex:4 screenId:1]];
        validation_message =  [[ApplicantHelper sharedInstance] validateRequestParams];
    }

    if([validation_message isEqualToString:SUCESS_STRING]){
        if([Utility isComapany])
            [[CompanyHelper sharedInstance] createAccountServiceCallWithDelegate:self requestType:121212];
        else //Need to call applicant service
            [[ApplicantHelper sharedInstance] createAccountServiceCallWithDelegate:self requestType:121212];
    }else{
        [CustomAlertView showAlertWithTitle:@"Error" message:validation_message OkButton:@"OK" delegate:self];
    }
}
-(void)showPickerViewController:(id)sender
{
    if(isPickerShown)
        return;
    
    selected_text_field = (CustomTextField *)sender;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        }];

        [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        int selectedIndex = [CompanyHelper getJobRoleIdWithValue:[[CompanyHelper sharedInstance].params valueForKey:JOB_ROLE_KEY] parantKey:@"jobRoles" childKey:@"jobRoleName"];
        
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
    });
    
    isPickerShown = YES;
    
    /*int idx = [CompanyHelper getJobRoleIdWithValue:[[CompanyHelper sharedInstance].params valueForKey:JOB_ROLE_KEY] parantKey:@"jobRoles" childKey:@"jobRoleName"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Job role"
                                            rows:[CompanyHelper getDropDownArrayWithTittleKey:@"jobRoleName" parantKey:@"jobRoles"]
                                initialSelection:idx
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                [[CompanyHelper sharedInstance] setParamsValue:selectedValue forKey:[CompanyHelper getParamsStringWithIndex:(int)[sender tag] screenId:1]];

                                           [[CompanyHelper sharedInstance] setParamsValue:[CompanyHelper getJobRoleIdWithIndex:(int)selectedIndex parantKey:@"jobRoles" childKey:@"jobRoleId"] forKey:JOB_ROLE_ID_KEY];
                                           UITextField *tf = (UITextField *)sender;
                                            tf.text = selectedValue;
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender]; */
}

-(void)didSelectPickerWithDoneClicked:(NSString *)value forTag:(int)tag
{
    isPickerShown = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
            self.table_view.contentInset = UIEdgeInsetsZero;
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
        }];
    
    if(tag == -1) //For cancel
        return;
    
    
    [[CompanyHelper sharedInstance] setParamsValue:value forKey:[CompanyHelper getParamsStringWithIndex:(int)[selected_text_field tag] screenId:1]];

    [[CompanyHelper sharedInstance] setParamsValue:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"jobRoles" childKey:@"jobRoleId"] forKey:JOB_ROLE_ID_KEY];
    selected_text_field.text = value;
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if([Utility isComapany] && tag == 121212 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
       
        
        [Utility getMixpanelData:COMPANY_GENERAL_SIGNUP setProperties:userName];
      
        
        
        [FireBaseAPICalls captureScreenDetails:COMPANY_SIGNUP];
  NSLog(@"%@",data);
        //recruiterSignup
        [Utility saveToDefaultsWithKey:RECRUITER_REGISTRATION_ID value:[NSString stringWithFormat:@"%@",[data valueForKeyPath:@"data.userId"]]];
        
        [Utility saveToDefaultsWithKey:SESSION_ID value:[NSString stringWithFormat:@"%@",[data valueForKeyPath:@"data.sessionId"]]];
       
      
        
        [[NSUserDefaults standardUserDefaults] setObject:[data valueForKeyPath:@"data.sessionId"] forKey:@"sessionName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
      
        

        WRCheckYourEmail *check_your_email = [[UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil] instantiateViewControllerWithIdentifier:WRCHECK_YOUR_EMAIL_IDENTIFIER];
        [self.navigationController pushViewController:check_your_email animated:YES];
        
        //Save company object
        [Utility saveCompanyObject:[CompanyHelper sharedInstance]];
        return;
    }else if(![Utility isComapany] && tag == 121212){

        [FireBaseAPICalls captureScreenDetails:APPLICANT_SIGNUP];

        
        [Utility saveToDefaultsWithKey:APPLICANT_REGISTRATION_ID value:[NSString stringWithFormat:@"%@",[data valueForKeyPath:@"data.userId"]]];

        [Utility saveToDefaultsWithKey:SESSION_ID value:[NSString stringWithFormat:@"%@",[data valueForKeyPath:@"data.sessionId"]]];
        
        [[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"savedExternalJobsValue"];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRVerifyMobileController *controller =[mystoryboard instantiateViewControllerWithIdentifier:WRVERIFY_MOBILE_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:YES];
        
        //Save applicant object
        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
        
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_SIGNUP_SCREEN];
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_SIGNUP_BASIC];
        [[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"savedExternalJobsValue"];

        return;
        
    }else if(![Utility isComapany] && tag == 101){

        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRVerifyMobileController *controller =[mystoryboard instantiateViewControllerWithIdentifier:WRVERIFY_MOBILE_VIEW_CONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller animated:YES];
        
        //Save applicant object
        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
        return;
    }
}


-(void)didFailedWithError:(NSError *)error forTag:(int)tag{}

//TODO need to make Model classes for this
-(void)showAlertMessage:(NSString *)message
{
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
