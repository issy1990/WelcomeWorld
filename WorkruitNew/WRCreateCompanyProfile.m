//
//  WRCreateCompanyProfile.m
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRCreateCompanyProfile.h"

@interface WRCreateCompanyProfile ()<UITextFieldDelegate,WYPopoverControllerDelegate,POPOVER_Delegate,CustomPickerViewDelegate>
{
        NSArray *titleArray;
        WYPopoverController *autocompleteTableView;
        PopOverListController *popListController;
    
        CustomTextField *selected_text_field;
    
    CustomPickerView *picker_object;
    
    BOOL isPickerShowns;
    IBOutlet UIView * myView;

}
@end

@implementation WRCreateCompanyProfile

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
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)allocPopOver
{
    popListController  = [[PopOverListController alloc] initWithNibName:@"PopOverListController" bundle:nil];
    popListController.delegate = self;
    autocompleteTableView = [[WYPopoverController alloc] initWithContentViewController:popListController];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dismissOnTap = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    [[CompanyHelper sharedInstance] setParamsValue:[[CompanyHelper sharedInstance].params valueForKey:JOB_ROLE_ID_KEY] forKey:USER_JOB_ROLE_KEY];
    [[CompanyHelper sharedInstance] setParamsValue:[[CompanyHelper sharedInstance].params valueForKey:RECRUITER_COMPANY_NAME_KEY] forKey:COMPANY_NAME_KEY];
    
    
    titleArray = [[NSArray alloc] initWithObjects:@"Comapny Name",@"Company Website",@"Company Size",@"Company Location", nil];
    
    //Setting the table view footer view to zeero
    self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    [Utility setThescreensforiPhonex:myView];

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
    return titleArray.count;
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

    cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    if(indexPath.row == 0){
        cell.ValueTF.placeholder = [NSString stringWithFormat:@"Enter %@",[titleArray objectAtIndex:indexPath.row]];
        cell.ValueTF.autocorrectionType = UITextAutocorrectionTypeDefault;
    }else if(indexPath.row == 1){
        cell.ValueTF.placeholder = [NSString stringWithFormat:HTTPS_STRING];
        cell.ValueTF.autocorrectionType = UITextAutocorrectionTypeNo;
    }else{
        cell.ValueTF.autocorrectionType = UITextAutocorrectionTypeDefault;
        cell.ValueTF.placeholder = [NSString stringWithFormat:@"Select %@",[titleArray objectAtIndex:indexPath.row]];
    }
    cell.ValueTF.textColor = MainTextColor;
    switch (indexPath.row) {
        case -1:
            cell.ValueTF.text = [[[CompanyHelper sharedInstance] getParamsObject] valueForKey:JOB_ROLE_KEY];
            cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
            cell.ValueTF.userInteractionEnabled = YES;
            break;
        case 0:{
            cell.ValueTF.text = [[[CompanyHelper sharedInstance] getParamsObject] valueForKey:RECRUITER_COMPANY_NAME_KEY];
            cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
            cell.ValueTF.userInteractionEnabled = NO;
            cell.ValueTF.textColor = [UIColor lightGrayColor];
        }break;
        case 1:
            cell.ValueTF.text = [[[CompanyHelper sharedInstance] getParamsObject] valueForKey:COMPANY_WEBSITE_KEY];
            
            cell.ValueTF.keyboardType = UIKeyboardTypeURL;
            cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.ValueTF.userInteractionEnabled = YES;
            break;
        case 2:{
            cell.ValueTF.userInteractionEnabled = YES;
            if([[[CompanyHelper sharedInstance] getParamsObject] valueForKeyPath:@"size.csTitle"])
                cell.ValueTF.text = [[[CompanyHelper sharedInstance] getParamsObject] valueForKeyPath:@"size.csTitle"];
            else
                cell.ValueTF.text = [[[CompanyHelper sharedInstance] getParamsObject] valueForKey:COMAPANY_SIZE_KEY];
            cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
        }break;
        case 3:{
            cell.ValueTF.userInteractionEnabled = YES;
            if([[[CompanyHelper sharedInstance] getParamsObject] valueForKeyPath:@"location.title"])
                cell.ValueTF.text = [[[CompanyHelper sharedInstance] getParamsObject] valueForKeyPath:@"location.title"];
            else
                cell.ValueTF.text = [[[CompanyHelper sharedInstance] getParamsObject] valueForKey:LOCATION_KEY];
                
            cell.ValueTF.keyboardType = UIKeyboardTypeDefault;
        }break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag ==  [titleArray count]-1){
        [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }else if(textField.tag ==  [titleArray count]){
        [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }else if(textField.tag == 2)
    {
        if([textField.text isEqualToString:@""])
            textField.text = HTTPS_STRING;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];

    if(textField.tag == 2){
        if ([completeString rangeOfString:@"."].location == NSNotFound)
        {
            [[CompanyHelper sharedInstance] setParamsValue:@"" forKey:[CompanyHelper getParamsStringWithIndex:(int)textField.tag screenId:2]];
            
        }else{
            
            [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:[CompanyHelper getParamsStringWithIndex:(int)textField.tag screenId:2]];
        }
    }
    
    else{
        if(textField.tag ==  [titleArray count]){
            [self shwoAutoCompleteLocations:textField];
        }
        [popListController filterTheArray:completeString];
        
        [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:[CompanyHelper getParamsStringWithIndex:(int)textField.tag screenId:2]];
    }
    return YES;
    
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
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

-(IBAction)nextButtonForProcess:(id)sender
{
    //Validate the parameters
    NSString *validation_message =  [[CompanyHelper sharedInstance] validateCompanyProfileParams];
    if([validation_message isEqualToString:SUCESS_STRING]){
        [[CompanyHelper sharedInstance] saveComapnyServiceCallWithDelegate:self requestType:100];
    }else{
        [CustomAlertView showAlertWithTitle:@"Error" message:validation_message OkButton:@"OK" delegate:self];
    }
}

-(void)shwoAutoCompleteLocations:(UITextField *)textField
{
    if(!autocompleteTableView.isPopoverVisible){
        [self allocPopOver];
        [autocompleteTableView presentPopoverFromRect:textField.bounds inView:textField permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    }
}

-(void)showPickerViewController:(id)sender
{
    if(isPickerShowns) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
        
    selected_text_field = (CustomTextField *)sender;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
    }];
    
    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];


    NSMutableArray *array;
    int idx = 0;
    if(!picker_object){
        picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
        if(self.tabBarController)
            [self.tabBarController.view addSubview:picker_object];
        else
            [self.view addSubview:picker_object];
    }
    
    if(selected_text_field.tag == 3)
    {
        array = [CompanyHelper getDropDownArrayWithTittleKey:@"csTitle" parantKey:@"companySizes"];
        idx = [CompanyHelper getJobRoleIdWithValue:[[CompanyHelper sharedInstance].params valueForKey:COMAPANY_SIZE_KEY] parantKey:@"companySizes" childKey:@"csTitle"];

        [picker_object.done_button setTitle:@"Next" forState:UIControlStateNormal];
    }else if(selected_text_field.tag == 4){
        
        array = [CompanyHelper getDropDownArrayWithTittleKey:@"title" parantKey:@"locations"];
        idx = [CompanyHelper getJobRoleIdWithValue:[[CompanyHelper sharedInstance].params valueForKey:LOCATION_NAME_KEY] parantKey:@"locations" childKey:@"title"];
        
        [picker_object.done_button setTitle:@"Done" forState:UIControlStateNormal];
    }

    
        picker_object.view_height = self.view.frame.size.height;
        picker_object.delegate = self;
        picker_object.objectsArray = array;
        [picker_object.picker_view reloadAllComponents];
        [picker_object.picker_view selectRow:idx inComponent:0 animated:YES];
        picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
        [picker_object showPicker];
  
    isPickerShowns = YES;
}

-(void)didSelectPickerWithDoneClicked:(NSString *)value forTag:(int)tag
{
    isPickerShowns = NO;
    
        [UIView animateWithDuration:0.25 animations:^{
            self.table_view.contentInset = UIEdgeInsetsZero;
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
        }];

    if(tag == -1) //For cancel
        return;
    
        if(selected_text_field.tag == 3){
            selected_text_field.text = value;
            [[CompanyHelper sharedInstance] setParamsValue:value forKey:COMAPANY_SIZE_KEY];

            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            [dictionary setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"companySizes" childKey:@"csId"] forKey:CSID_KEY];
            [[CompanyHelper sharedInstance].params setObject:dictionary forKey:SIZE_KEY];
            
            
            NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:selected_text_field.row + 1 inSection:0];
            CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
            [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [nextCell.ValueTF becomeFirstResponder];

            
            
        }else if(selected_text_field.tag == 4){
            
            [[CompanyHelper sharedInstance] setParamsValue:value forKey:LOCATION_NAME_KEY];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            [dictionary setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"locations" childKey:@"locationId"] forKey:LOCATION_ID_KEY];
            [[CompanyHelper sharedInstance].params setObject:dictionary forKey:LOCATION_KEY];
            selected_text_field.text = value;
        }
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 100){
        [Utility saveToDefaultsWithKey:SAVE_COMPANY_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:@"data"]]];
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:COMPANY_CREATE_COMPANY setProperties:userName];
        
    }

    if(tag == 101 || ([CompanyHelper sharedInstance].isPartialLogin && [[[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID] length] > 0)){
        
        if(tag == 101)
            [Utility saveToDefaultsWithKey:SESSION_ID value:[NSString stringWithFormat:@"%@",[data valueForKey:SESSION_ID]]];
        
        /*UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        WRUploadAPicture *profilePicute =   [mystoryboard instantiateViewControllerWithIdentifier:WRUPLOAD_A_PICTURE_IDENTIFIER];
        [self.navigationController pushViewController:profilePicute animated:YES];*/
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        WRChooseCompanyIndustry *industryController = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
        industryController.isBackButtonHide = YES;
        [self.navigationController pushViewController:industryController animated:YES];
        
    }else{

        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:[[CompanyHelper sharedInstance].params valueForKey:@"email"] forKey:@"username"];
        [params setObject:[[CompanyHelper sharedInstance].params valueForKey:@"password"] forKey:@"password"];
        [params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID] forKey:@"regdId"];
        [params setObject:DEVICE_TYPE_STRING forKey:@"deviceType"];
        [params setObject:@"recruiter" forKey:@"role"];
        [[CompanyHelper sharedInstance] loginComapny:self requestType:101 params:params];
    }
}

-(IBAction)previousButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    autocompleteTableView.delegate = nil;
    autocompleteTableView = nil;
}

@end
