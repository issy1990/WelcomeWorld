//
//  WRAddExperianceController.m
//  workruit
//
//  Created by Admin on 10/13/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRAddExperianceController.h"
#import "WRSkillsViewController.h"
#import "ConnectionManager.h"
#import "WRNotesViewController.h"
#import "LoadDataManager.h"

@interface WRAddExperianceController ()<UITextFieldDelegate,CHDropDownTextFieldDelegate,POPOVER_Delegate,WYPopoverControllerDelegate,CustomDateViewDelegate,HTTPHelper_Delegate>
{
    
    NSMutableDictionary *paramsArray;
    
    PopOverListController *popListController;
    WYPopoverController *autocompleteTableView;
    
    NSString *title_str;
    
    CustomTextField *selected_text_field;
    
    BOOL isPickerShown;
    CustomPickerView *picker_object;
    CustomDatePicker *date_picker_object;
    ConnectionManager *connection_manager;
    
    BOOL isAddDontHaveExperianceCell;
    NSString * str;
    IBOutlet UIView * myView;

}
@end

@implementation WRAddExperianceController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.titleArray removeAllObjects];
    self.titleArray = nil;
    NSString *delete_button_title = @"";
    
    if(self.Flag == 0){
        self.headerLbl.text = @"Add Experience";
        
        if(self.selectedDictionary == nil && !self.isFirstTime){
            
            
                self.titleArray = [[NSMutableArray alloc] initWithObjects:@"Job Title",@"Company",@"Location",@"Start Date",@"End Date",@"Still Working ?", nil];
            
            isAddDontHaveExperianceCell = NO;
            
            
        }else
                self.titleArray = [[NSMutableArray alloc] initWithObjects:@"Job Title",@"Company",@"Location",@"Start Date",@"End Date",@"Still Working ?", nil];
        
        delete_button_title = @"Delete Experience";
        
        
    }else if(_Flag  == 1){
        self.headerLbl.text = @"Add Education";
        
            self.titleArray = [[NSMutableArray alloc] initWithObjects:@"School Name",@"Degree",@"Field of Study",@"Location",@"Start Date",@"End Date",@"Still Studying ? ", nil];
        
        delete_button_title = @"Delete Education";
     
        isAddDontHaveExperianceCell = NO;
    }
    else if(_Flag == 2){
        
        self.headerLbl.text = @"Add Academic Project";
        self.titleArray = [[NSMutableArray alloc] initWithObjects:@"Role",@"Project Title",@"Institution",@"Location",@"Start Date",@"End Date",@"Still working ? ", nil];
        delete_button_title = @"Delete Academic";
    }
   
    if(self.selectedDictionary == nil ){
        if(self.Flag == 0 && !self.isFirstTime){
            [self.delete_button setTitle:@"Don’t have experience? Click here" forState:UIControlStateNormal];
            self.delete_button.hidden = YES;
        }
        else{
               [self.delete_button setTitle:@"" forState:UIControlStateNormal];
                self.delete_button.hidden = YES;
        }
    }else{
        [self.delete_button setTitle:delete_button_title forState:UIControlStateNormal];
    }
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
    
    
    popListController = nil;
    autocompleteTableView = nil;
    
    [picker_object hidePicker];
    picker_object = nil;
    
    [date_picker_object hidePicker];
    date_picker_object = nil;
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

-(IBAction)skipButton:(id)sender
{
    if(self.commingfromeditprofile == 100)
    { // if user comming from edit applicant
        if(self.Flag == 0){

            if(self.selectedDictionary == nil)
            {
                [self performSelector:@selector(KeyboardStarted:) withObject:nil afterDelay:0.2];
            }
            
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_SIGNUP_EXPERIENCE];
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_ADD_YOEOVERALL];
            paramsArray = [[NSMutableDictionary alloc] initWithCapacity:0];
            self.Flag += 1;
            self.headerLbl.text = @"Add Education";
            [self.titleArray removeAllObjects];
            self.titleArray = nil;
            self.titleArray = [[NSMutableArray alloc] initWithObjects:@"School Name",@"Degree",@"Field of Study",@"Location",@"Start Date",@"End Date",@"Still Studying ? ", nil];
            
            if(self.selectedDictionary == nil ){
                [self.delete_button setTitle:@"" forState:UIControlStateNormal];
                self.delete_button.hidden = YES;
                isAddDontHaveExperianceCell = NO;
            }
            [self.table_view reloadData];
        }else
            [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }
    
    if (self.Flag == 0) {
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:APPLICANT_SIGNUP_EXPSKIP setProperties:userName];
       
        
        
        [Utility getMixpanelData:APPLICANT_SIGNUP_PROFILE_INCOMPLETE setProperties:userName];
        
    }else{
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        [Utility getMixpanelData:APPLICANT_SIGNUP_EDUSKIP setProperties:userName];
        [Utility getMixpanelData:APPLICANT_SIGNUP_PROFILE_INCOMPLETE setProperties:userName];
    }
   
    
    [self createMeTabBarController];
}


-(IBAction)backButtonAction:(id)sender
{
    
    if(self.isFirstTime){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    self.Flag -= 1;
    
    if(self.Flag ==1){

        self.headerLbl.text = @"Add Academic Project";
        [self.titleArray removeAllObjects];
        self.titleArray = nil;
        self.titleArray = [[NSMutableArray alloc] initWithObjects:@"Role",@"Project Title",@"Institution",@"Location",@"Start Date",@"End Date",@"Still working ? ", nil];
        isAddDontHaveExperianceCell = NO;
        [self.table_view reloadData];
        
    }else if(self.Flag == 0){

          exit(0);
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISLOGEDIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(self.selectedDictionary == nil && !self.isFirstTime)
    {
       self.skipButton.hidden = NO;
        isAddDontHaveExperianceCell = YES;
   }
    
    connection_manager = [[ConnectionManager alloc] init];
    connection_manager.delegate = self;
    
    if(self.isFirstTime && self.screen_id != 1000)
    {
         self.skipButton.hidden = YES;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save" forState:UIControlStateNormal];
    }

    if(self.selectedDictionary == nil)
    {
        paramsArray = [[NSMutableDictionary alloc] initWithCapacity:0];
        [paramsArray setObject:[NSNumber numberWithBool:0] forKey:@"isPresent"];
        
        self.delete_button.hidden = NO;
        [self.delete_button setBackgroundImage:nil forState:UIControlStateNormal];
        [self.delete_button.titleLabel setFont:[UIFont fontWithName:GlobalFontRegular size:16.0]];
        [self.delete_button setTitleColor:UIColorFromRGB(0x337ab7) forState:UIControlStateNormal];
        
    }
    else
    {
        paramsArray = [self.selectedDictionary mutableCopy];
        self.delete_button.hidden = NO;
    }
    
    //Setting the table view footer view to zeero
    self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    title_str = @"";
    
    
    [Utility setThescreensforiPhonex:myView];

}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.selectedDictionary == nil)
    {
        [self performSelector:@selector(KeyboardStarted:) withObject:nil afterDelay:0.1];
    }
}
-(void)KeyboardStarted:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger i = [sender tag];
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CreateCompanyCustomCell * nextCell = [self.table_view cellForRowAtIndexPath:nextIndexPath];
        if ([[_titleArray objectAtIndex:i] isEqualToString:@"Job Title"]||[[_titleArray objectAtIndex:i] isEqualToString:@"School Name"]||[[_titleArray objectAtIndex:i] isEqualToString:@"Role"])
        {
            [nextCell.ValueTF becomeFirstResponder];
        }
    });
}

-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    if(tag == 1000 && buttonIndex == 2)
    {
        if(self.isFirstTime){
            if(self.Flag == 0)
            {
                NSMutableArray *arrayExperiace = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"];
                if(arrayExperiace == nil)
                    arrayExperiace = [[NSMutableArray alloc] initWithCapacity:0];
                else
                    [arrayExperiace removeObjectAtIndex:self.index];
                [[ApplicantHelper sharedInstance].paramsDictionary setObject:arrayExperiace forKey:@"experience"];
                 str =@"Experience field deleted";
            }else  if(self.Flag == 1)
            {
                NSMutableArray *arrayExperiace = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"];
                if(arrayExperiace == nil)
                    arrayExperiace = [[NSMutableArray alloc] initWithCapacity:0];
                else
                    [arrayExperiace removeObjectAtIndex:self.index];
                
                [[ApplicantHelper sharedInstance].paramsDictionary setObject:arrayExperiace forKey:@"education"];
                 str =@"Education field deleted";
            }
            else if(self.Flag == 2){
                NSMutableArray *arrayExperiace = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"];
                if(arrayExperiace == nil)
                    arrayExperiace = [[NSMutableArray alloc] initWithCapacity:0];
                else
                    [arrayExperiace removeObjectAtIndex:self.index];
                [[ApplicantHelper sharedInstance].paramsDictionary setObject:arrayExperiace forKey:@"academic"];
                str =@"Academic field deleted";
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DataUpdationALert" object:str];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
}


-(IBAction)deleteButtonAction:(id)sender
{
    if(self.selectedDictionary == nil){

        [[ApplicantHelper sharedInstance] setParamsValue:@"0" forKey:@"totalexperience"];
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            controller.Flag = 1;
            controller.isFirstTime = YES;
            controller.screen_id = 1000;
        
            [self.navigationController pushViewController:controller animated:YES];
    }else{
           [[ApplicantHelper sharedInstance].paramsDictionary setObject:@"saveddata" forKey:@"experience1"];
        [CustomAlertView showAlertWithTitle:@"Are you sure?" message:@"Are you sure you want to delete this information?" OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:1000];
    }
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
        return self.titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(isAddDontHaveExperianceCell){
        if(indexPath.row == [self.titleArray count] -1){
            static NSString *cellIdentifier = MULTIPLE_SELECTION_CELL_IDENTIFIER;
            MultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MULTIPLE_SELECTION_CELL owner:self options:nil];
                cell = (MultipleSelectionCell *)[topLevelObjects objectAtIndex:0];
            }
            /*
            cell.titleLbl.text  = @"Don’t have experience? Click here";
            cell.titleLbl.textAlignment = NSTextAlignmentCenter;
            cell.titleLbl.font = [UIFont fontWithName:GlobalFontRegular size:16.0];
            cell.titleLbl.textColor = UIColorFromRGB(0x337ab7);
*/
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }else if(indexPath.row == [self.titleArray count] -2){
            static NSString *cellIdentifier = CUSTOM_SWITCH_CELL_IDENTIFIER;
            CustomSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SWITCH_CELL owner:self options:nil];
                cell = (CustomSwitchCell *)[topLevelObjects objectAtIndex:0];
                [cell.valueSwitch addTarget:self action:@selector(switchChagned:) forControlEvents:UIControlEventValueChanged];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.titleLbl.text = [self.titleArray objectAtIndex:indexPath.row];
            
            if([[paramsArray valueForKey:@"isPresent"] boolValue])
                [cell.valueSwitch setOn:YES];
            else [cell.valueSwitch setOn:NO];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
            CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
                cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.ValueTF.row = indexPath.row;
            cell.ValueTF.section = indexPath.section;
            
            cell.titleLbl.text = [self.titleArray objectAtIndex:indexPath.row];
            cell.ValueTF.placeholder =[NSString stringWithFormat:@"Enter %@",[self.titleArray objectAtIndex:indexPath.row]];
            cell.ValueTF.tag = indexPath.row + 1;
            if([[[ApplicantHelper sharedInstance]  getParamsKeyWithIndex:(int)cell.ValueTF.tag withScreen:self.Flag] isEqualToString:@"endDate"]){
                
                if([[paramsArray valueForKey:@"isPresent"] boolValue])
                    cell.ValueTF.text = @"Present";
                else
                    cell.ValueTF.text = [paramsArray valueForKey:[[ApplicantHelper sharedInstance]  getParamsKeyWithIndex:(int)cell.ValueTF.tag withScreen:self.Flag]];
            }else
                cell.ValueTF.text = [paramsArray valueForKey:[[ApplicantHelper sharedInstance]  getParamsKeyWithIndex:(int)cell.ValueTF.tag withScreen:self.Flag]];
            
            cell.ValueTF.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else if(indexPath.row == [self.titleArray count] -1){
            static NSString *cellIdentifier = CUSTOM_SWITCH_CELL_IDENTIFIER;
            CustomSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SWITCH_CELL owner:self options:nil];
                cell = (CustomSwitchCell *)[topLevelObjects objectAtIndex:0];
                [cell.valueSwitch addTarget:self action:@selector(switchChagned:) forControlEvents:UIControlEventValueChanged];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.titleLbl.text = [self.titleArray objectAtIndex:indexPath.row];
        
        
        if([[paramsArray valueForKey:@"isPresent"] boolValue])
                [cell.valueSwitch setOn:YES];
            else [cell.valueSwitch setOn:NO];
        
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
        CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
            cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.ValueTF.row = indexPath.row;
        cell.ValueTF.section = indexPath.section;
        
        cell.titleLbl.text = [self.titleArray objectAtIndex:indexPath.row];
        cell.ValueTF.placeholder =[NSString stringWithFormat:@"Enter %@",[self.titleArray objectAtIndex:indexPath.row]];
        cell.ValueTF.tag = indexPath.row + 1;
        if([[[ApplicantHelper sharedInstance]  getParamsKeyWithIndex:(int)cell.ValueTF.tag withScreen:self.Flag] isEqualToString:@"endDate"]){
      
            if([[paramsArray valueForKey:@"isPresent"] boolValue])
                    cell.ValueTF.text = @"Present";
                else
                    cell.ValueTF.text = [paramsArray valueForKey:[[ApplicantHelper sharedInstance]  getParamsKeyWithIndex:(int)cell.ValueTF.tag withScreen:self.Flag]];
        }else
            cell.ValueTF.text = [paramsArray valueForKey:[[ApplicantHelper sharedInstance]  getParamsKeyWithIndex:(int)cell.ValueTF.tag withScreen:self.Flag]];
        
            cell.ValueTF.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isAddDontHaveExperianceCell && indexPath.row == [self.titleArray count] -1) {
        [[ApplicantHelper sharedInstance] setParamsValue:@"0" forKey:@"totalexperience"];
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
        controller.Flag = 1;
        controller.isFirstTime = YES;
        controller.screen_id = 1000;
        [self.navigationController pushViewController:controller animated:YES];
    }
}



-(void)switchChagned:(id)sender
{
    UISwitch *switch_object = (UISwitch *)sender;
    if(switch_object.isOn){
        [paramsArray setObject:[Utility getStringWithDate:[NSDate date] withFormat:@"MMM yyyy"] forKey:@"endDate"];
        [paramsArray setObject:[NSDate date] forKey:@"endDateVal"];
        [paramsArray setObject:[NSNumber numberWithBool:1] forKey:@"isPresent"];
    }else{
        [paramsArray setObject:[NSNumber numberWithBool:0] forKey:@"isPresent"];
        [paramsArray removeObjectForKey:@"endDateVal"];
        [paramsArray removeObjectForKey:@"endDate"];
    }
    
    [self.table_view reloadData];
}

-(void)allocPopOver:(NSMutableArray *)arrayOfCites
{
    popListController  = [[PopOverListController alloc] initWithNibName:@"PopOverListController" bundle:nil];
    popListController.filterdCountriesArray = arrayOfCites;
    popListController.allCountriesArray = arrayOfCites;
    popListController.delegate = self;
    
    autocompleteTableView = [[WYPopoverController alloc] initWithContentViewController:popListController];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dismissOnTap = YES;
}

-(void)shwoAutoCompleteLocations:(NSString *)completedText
{
    
    if ([completedText length] == 0 ) {
        
        [paramsArray removeObjectForKey:@"location"];
       
        
    }
    else{
    if([completedText length] >= 3){
//        if([completedText length]%2==0 || [completedText length] == 3)
                [self APICallToService:completedText];
    }else{
        [autocompleteTableView dismissPopoverAnimated:YES];
        [popListController.filterdCountriesArray  removeAllObjects];
        [popListController.tableView reloadData];
    }
    }
/*    if(!autocompleteTableView.isPopoverVisible){
        [self allocPopOver];
        [autocompleteTableView presentPopoverFromRect:textField.bounds inView:textField permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    }*/
}

-(void)APICallToService:(NSString *)place_name
{
    [connection_manager.dataTask cancel];
    NSString *url_string = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&key=AIzaSyD3Uy7UwMEPx49hSfbJWQl6ZX3UFD-X518",place_name];
    connection_manager.delegate = self;
    [connection_manager startRequestWithURL:url_string WithParams:nil forRequest:-6000 controller:self httpMethod:HTTP_GET];
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 100){
        
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_SIGNUP_EXPERIENCE];
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_ADD_YOEOVERALL];

        paramsArray = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.Flag += 1;
        self.headerLbl.text = @"Add Education";
        [self.titleArray removeAllObjects];
        self.titleArray = nil;
        self.titleArray = [[NSMutableArray alloc] initWithObjects:@"School Name",@"Degree",@"Field of Study",@"Location",@"Start Date",@"End Date",@"Still Studying ? ", nil];
        
        if(self.selectedDictionary == nil )
        {
            [self.delete_button setTitle:@"" forState:UIControlStateNormal];
            self.delete_button.hidden = YES;
            isAddDontHaveExperianceCell = NO;
            
            if(self.selectedDictionary == nil)
            {
                [self performSelector:@selector(KeyboardStarted:) withObject:nil afterDelay:0.2];
            }
            
        }
        [self.table_view reloadData];
    }else if(tag == 200){
        [FireBaseAPICalls captureMixpannelEvent:APPLICANT_SIGNUP_EDUCATION];
        
        if(self.commingfromeditprofile == 100){ // if user comming from edit applicant
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        
        NSLog(@"my data%@",data);
        //Notes screen here
         //[[ApplicantHelper sharedInstance] updateApplicantServiceCallWithDelegate:self requestType:101];
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRNotesViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:@"WRNotesViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        
        if(self.selectedDictionary == nil ){
            [self.delete_button setTitle:@"" forState:UIControlStateNormal];
            self.delete_button.hidden = YES;
            isAddDontHaveExperianceCell = NO;
        }

    }else if(tag == -6000){
        NSMutableArray *array = [[data valueForKey:@"predictions"] mutableCopy];
        NSMutableArray *citiesArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for(NSMutableArray *dic_object in array){
            NSArray *termsArray = [dic_object valueForKeyPath:@"terms"];
            NSMutableString *stringValue = [[NSMutableString alloc] initWithCapacity:0];
            for(int k = 0; k < [termsArray count]; k++){
                NSDictionary *object_value = [termsArray objectAtIndex:k];
                if(k == 0)
                    [stringValue appendFormat:@"%@, ",[object_value valueForKey:@"value"]];
                else if (k == 1)
                    [stringValue appendFormat:@"%@.",[object_value valueForKey:@"value"]];
            }
            
            [citiesArray addObject:[NSString stringWithString:stringValue]];
        }
        
        [self allocPopOver:citiesArray];
        [autocompleteTableView presentPopoverFromRect:selected_text_field.bounds inView:selected_text_field permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.Flag == 0){
        if(textField.tag ==  3){
          
                [self shwoAutoCompleteLocations:textField.text];
            if (textField.text.length == 0) {
                
               [paramsArray removeObjectForKey:@"location"];
                
            }
            else{
            if([textField.text length] > 0)
                [popListController filterTheArray:textField.text];
            }
            return YES;
        }else if(textField.tag == 4 || textField.tag == 5){
            [self performSelector:@selector(showMonthYearPickerViewController:) withObject:textField afterDelay:0.3];
            return NO;
        }
    }else if(self.Flag == 1){
        if(textField.tag ==  2){
            [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
            return NO;
        }else if(textField.tag ==  4){
            [self shwoAutoCompleteLocations:textField.text];
            if (textField.text.length == 0) {
                
                 [paramsArray removeObjectForKey:@"location"];
                
                
            }else{
            if([textField.text length] > 0)
                [popListController filterTheArray:textField.text];
            }
            return YES;
        }else if(textField.tag == 5 || textField.tag == 6){
            [self performSelector:@selector(showMonthYearPickerViewController:) withObject:textField afterDelay:0.3];
            return NO;
        }
    }else if(self.Flag == 2){
        if(textField.tag == 4){
                [self shwoAutoCompleteLocations:textField.text];
            
            if (textField.text.length == 0) {
                
                
                [paramsArray removeObjectForKey:@"location"];
                
                
            }else{

            if([textField.text length] > 0)
                [popListController filterTheArray:textField.text];
            }
            return YES;
        }else if(textField.tag == 5 || textField.tag == 6){
            [self performSelector:@selector(showMonthYearPickerViewController:) withObject:textField afterDelay:0.3];
            return NO;
        }
    }
    return YES;
}

-(void)showMonthYearPickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    selected_text_field = (CustomTextField *)sender;

    if(isPickerShown || ([[paramsArray valueForKey:@"isPresent"] boolValue] &&  ( selected_text_field.tag == 6 || (selected_text_field.tag == 5 && self.Flag == 0 ))))
        return;

    [UIView animateWithDuration:0.25f animations:^{
        self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0);
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0);
    }];
    
    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    if(!date_picker_object){
        date_picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomDatePicker" owner:self options:nil] objectAtIndex:0];
        
        if(self.tabBarController)
            [self.tabBarController.view addSubview:date_picker_object];
        else
            [self.view addSubview:date_picker_object];
    }

    NSDate *date_c = nil;
    if((selected_text_field.tag == 4 && self.Flag == 0 ) || (selected_text_field.tag == 5 && (self.Flag == 1 ||  self.Flag == 2))){
        
        NSString *string_date = [paramsArray valueForKey:@"startDate"];
        date_c = [Utility getDateWithStringDate:string_date withFormat:@"MMM yyyy"];
        if(self.selectedDictionary)
            [date_picker_object.done_button setTitle:@"Done" forState:UIControlStateNormal];
        else
        [date_picker_object.done_button setTitle:@"Next" forState:UIControlStateNormal];
    }else{
        NSString *string_date = [paramsArray valueForKey:@"endDate"];
        date_c = [Utility getDateWithStringDate:string_date withFormat:@"MMM yyyy"];
        [date_picker_object.done_button setTitle:@"Done" forState:UIControlStateNormal];
    }
    
    if(date_c == nil)
        date_c = [NSDate date];

    
    date_picker_object.view_height = self.view.frame.size.height;
    date_picker_object.delegate = self;
    [date_picker_object.date_picker setDate:date_c];
    date_picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
    [date_picker_object showPicker];
    
    isPickerShown = YES;
}

-(void)didSelectDateWithDoneClicked:(NSString *)value forTag:(NSDate *)date
{
    if([date_picker_object.done_button.titleLabel.text isEqualToString:@"Done"] || self.selectedDictionary){
        [UIView animateWithDuration:0.25 animations:^{
            self.table_view.contentInset = UIEdgeInsetsZero;
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
        }];
    }

    isPickerShown = NO;

    if(date == nil)
        return;
    
    if((selected_text_field.tag == 4 && self.Flag == 0 ) || (selected_text_field.tag == 5 && (self.Flag == 1 ||  self.Flag == 2))){
        [paramsArray setObject:[Utility getStringWithDate:date withFormat:@"MMM yyyy"]  forKey:@"startDate"];
        [paramsArray setObject:date  forKey:@"startDateVal"];
        
        NSDate *current_date = [Utility getDate:[NSDate date] withFromat:@"MMM yyyy"];
        NSDate *selected_date = [Utility getDate:date withFromat:@"MMM yyyy"];

        if([current_date compare:selected_date] == NSOrderedSame){
            [paramsArray setObject:[Utility getStringWithDate:[NSDate date] withFormat:@"MMM yyyy"]  forKey:@"endDate"];
            [paramsArray setObject:date  forKey:@"endDateVal"];
            [paramsArray setObject:[NSNumber numberWithBool:1] forKey:@"isPresent"];
        }
        
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:selected_text_field.tag inSection:0];
        CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
        [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [nextCell.ValueTF becomeFirstResponder];
        
    }else{
        [paramsArray setObject:[Utility getStringWithDate:date withFormat:@"MMM yyyy"]  forKey:@"endDate"];
        [paramsArray setObject:date  forKey:@"endDateVal"];
    }
    selected_text_field.text = [Utility getStringWithDate:date withFormat:@"MMM yyyy"];
    [self.table_view reloadData];
    
}

-(void)showPickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });

    if(isPickerShown)
        return;
    
    selected_text_field = (CustomTextField *)sender;
    int selectedIndex = [CompanyHelper getJobRoleIdWithValue:[paramsArray valueForKey:@"degree_name"] parantKey:@"degrees" childKey:@"title"];

    if(!picker_object){
        picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
        if(self.tabBarController)
            [self.tabBarController.view addSubview:picker_object];
        else
            [self.view addSubview:picker_object];
    }
    
    picker_object.view_height = self.view.frame.size.height;
    picker_object.delegate = self;
    picker_object.objectsArray = [CompanyHelper getDropDownArrayWithTittleKey:@"title" parantKey:@"degrees"];
    [picker_object.picker_view reloadAllComponents];
    [picker_object.picker_view selectRow:selectedIndex inComponent:0 animated:YES];
    picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
    [picker_object showPicker];
}

-(void)didSelectPickerWithDoneClicked:(NSString *)value forTag:(int)tag
{
    isPickerShown = NO;

        [UIView animateWithDuration:0.25 animations:^{
            self.table_view.contentInset = UIEdgeInsetsZero;
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
        }];
    
    if(tag == -1)
        return;
    

    [paramsArray setObject:value forKey:@"degree_name"];
    [paramsArray setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"degrees" childKey:@"shortTitle"] forKey:@"degree_short_name"];

    NSMutableDictionary *degree_local = [[NSMutableDictionary alloc] initWithCapacity:0];
    [degree_local setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"degrees" childKey:@"degreeId"] forKey:@"degreeId"];
    [paramsArray setObject:degree_local  forKey:@"degree"];
    selected_text_field.text = value;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    selected_text_field = (CustomTextField *)textField;

    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];
    if((textField.tag == 3 && self.Flag == 0) || (textField.tag == 4 && (self.Flag == 1 || self.Flag == 2))){
        if ([textField.text length]==0) {
            
          [paramsArray removeObjectForKey:@"location"];
             
        }
        else{
        [self shwoAutoCompleteLocations:completeString];
        }
        return YES;
    }

    NSString *key = [[ApplicantHelper sharedInstance] getParamsKeyWithIndex:(int)textField.tag withScreen:self.Flag];
    if(key == nil)
        key = @"test";
    
    [paramsArray setObject:[Utility trim:completeString] forKey:key];
    return YES;
}
-(void)textChanged:(UITextField *)textField
{
    if((textField.tag == 3 && self.Flag == 0) || (textField.tag == 4 && (self.Flag == 1 || self.Flag == 2))){
    
        if (textField.text.length == 0) {
            [paramsArray removeObjectForKey:@"location"];
        }
    }
}
-(void)didSelectValue:(NSString *)value forIndex:(int)index
{
    if ([value length] == 0) {
        
       [paramsArray removeObjectForKey:@"location"];
          [self.table_view reloadData];
    }else{
    [paramsArray setObject:value forKey:@"location"];
    [self.table_view reloadData];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if(self.selectedDictionary == nil && !self.isFirstTime)
    {
        [textField resignFirstResponder];
    }
    if(![self.save_button.titleLabel.text isEqualToString:@"Save"])
    {
          [textField resignFirstResponder];
    }
    else
    {
        [autocompleteTableView dismissPopoverAnimated:YES];
        
        CreateCompanyCustomCell * currentCell = (CreateCompanyCustomCell *) textField.superview.superview;
        NSIndexPath * currentIndexPath = [self.table_view indexPathForCell:currentCell];
        
        if(_Flag == 0 && (textField.tag == 3 || textField.tag == 4 || textField.tag == 5)){
            [textField resignFirstResponder];
        }else if(_Flag == 1 && (textField.tag == 2 || textField.tag == 4 || textField.tag == 5 || textField.tag == 6))
            [textField resignFirstResponder];
        else if(_Flag == 2 && (textField.tag == 4 || textField.tag == 5 || textField.tag == 6))
            [textField resignFirstResponder];
        
        
        if (currentIndexPath.row != [self.titleArray count] - 2) {
            NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:0];
            CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
            [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [nextCell.ValueTF becomeFirstResponder];
        }else
            [textField resignFirstResponder];
    }
 
    return YES;
}

-(IBAction)nextButtonForProcess:(id)sender
{
    if(self.isFirstTime)
    {
        if(self.Flag == 0)
        {
            NSString *message =  [[ApplicantHelper sharedInstance] validateExperianceParams:paramsArray];
            if(![message isEqualToString:SUCESS_STRING]){
                [CustomAlertView showAlertWithTitle:@"Error" message:message OkButton:@"OK" delegate:self];
                return;
            }

            NSMutableArray *arrayExperiace = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"experience"] mutableCopy];
            if(arrayExperiace == nil)
                arrayExperiace = [[NSMutableArray alloc] initWithCapacity:0];

            if(self.selectedDictionary)
                [arrayExperiace replaceObjectAtIndex:self.index withObject:paramsArray];
            else
                [arrayExperiace addObject:paramsArray];
            
            arrayExperiace = [Utility sortTheArray:arrayExperiace];
            
           str =@"You have succussfully saved your Experience Details.";
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:arrayExperiace forKey:@"experience"];
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_ADD_EXPERIENCE];
             [[ApplicantHelper sharedInstance].paramsDictionary setObject:@"saveddata" forKey:@"experience1"];
            
        }
        else  if(self.Flag == 1)
        {
           NSString *message =  [[ApplicantHelper sharedInstance] validateEducationParams:paramsArray];
            if(![message isEqualToString:SUCESS_STRING]){
                [CustomAlertView showAlertWithTitle:@"Error" message:message OkButton:@"OK" delegate:self];
                return;
            }
            
            NSMutableArray *arrayExperiace = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"education"] mutableCopy];
            if(arrayExperiace == nil)
                arrayExperiace = [[NSMutableArray alloc] initWithCapacity:0];

            if(self.selectedDictionary)
                [arrayExperiace replaceObjectAtIndex:self.index withObject:paramsArray];
            else
                [arrayExperiace addObject:paramsArray];
            
            arrayExperiace = [Utility sortTheArray:arrayExperiace];

              str =@"You have succussfully saved your Education Details.";
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:arrayExperiace forKey:@"education"];

            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_ADD_EDUCATION];
            if(self.commingfromeditprofile != 100)
                [[ApplicantHelper sharedInstance] updateApplicantServiceCallWithDelegate:self requestType:102];
        }
        else if(self.Flag == 2)
        {
            NSString *message =  [[ApplicantHelper sharedInstance] validateAcadamicParams:paramsArray];
            if(![message isEqualToString:SUCESS_STRING]){
                [CustomAlertView showAlertWithTitle:@"Error" message:message OkButton:@"OK" delegate:self];
                return;
            }

            NSMutableArray *arrayExperiace = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"academic"] mutableCopy];
            if(arrayExperiace == nil)
                arrayExperiace = [[NSMutableArray alloc] initWithCapacity:0];

            if(self.selectedDictionary)
                    [arrayExperiace replaceObjectAtIndex:self.index withObject:paramsArray];
                else
                    [arrayExperiace addObject:paramsArray];
            
                arrayExperiace = [Utility sortTheArray:arrayExperiace];
            
            str =@"You have succussfully saved your Academic Details.";

            [[ApplicantHelper sharedInstance].paramsDictionary setObject:arrayExperiace forKey:@"academic"];

            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_ADD_ACADEMIC];
            
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:@"saveddata" forKey:@"experience1"];
            
        }

        if(self.screen_id == 1000)
        {
            if(self.Flag == 0)
                [[ApplicantHelper sharedInstance] updateExperianceToServer:self requestType:100];
            else if(self.Flag == 1)
                [[ApplicantHelper sharedInstance] updateEducationToServer:self requestType:200];
        }else
            
            if(self.isFirstTime && self.screen_id != 1000)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"DataUpdationALert" object:str];
                [self.navigationController popViewControllerAnimated:YES];
            }
        
    
        return;
    }

    if(self.Flag == 0)
    {
        NSString *message =  [[ApplicantHelper sharedInstance] validateExperianceParams:paramsArray];
        
        if([message isEqualToString:SUCESS_STRING]){
            [paramsArray removeObjectForKey:@"startDateVal"];
            [paramsArray removeObjectForKey:@"endDateVal"];
            
            NSMutableArray *arrayObjects = [[NSMutableArray alloc] initWithCapacity:0];
            [arrayObjects addObject:paramsArray];
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:arrayObjects forKey:@"experience"];
            
            [[ApplicantHelper sharedInstance] updateExperianceToServer:self requestType:100];
            
            
        }else{
            [CustomAlertView showAlertWithTitle:@"Error" message:message OkButton:@"OK" delegate:self];
        }
    }else{
        NSString *message =  [[ApplicantHelper sharedInstance] validateEducationParams:paramsArray];
        if([message isEqualToString:SUCESS_STRING]){

            [paramsArray removeObjectForKey:@"startDateVal"];
            [paramsArray removeObjectForKey:@"endDateVal"];
            
            NSMutableArray *arrayObjects = [[NSMutableArray alloc] initWithCapacity:0];
            [arrayObjects addObject:paramsArray];
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:arrayObjects forKey:@"education"];
            
            [[ApplicantHelper sharedInstance] updateEducationToServer:self requestType:200];
            //About us navigations here
        }else{
            [CustomAlertView showAlertWithTitle:@"Error" message:message OkButton:@"OK" delegate:self];
        }
    }
    
    
}
- (void)dropDownTextField:(CHDropDownTextField *)dropDownTextField didChooseDropDownOptionAtIndex:(NSUInteger)index
{
    
}

-(void)createMeTabBarController
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISLOGEDIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
