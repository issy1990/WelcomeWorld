//
//  WRLocationViewController.m
//  workruit
//
//  Created by Admin on 10/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRLocationViewController.h"
#import "WRAddExperianceController.h"
#import "WRJobFunctionViewController.h"

@interface WRLocationViewController ()<UITextFieldDelegate,CHDropDownTextFieldDelegate,POPOVER_Delegate,WYPopoverControllerDelegate,CLLocationManagerDelegate>
{
    int keyBoardHight;
    UIButton *currentLaction;
    NSString *currentCity;
    CLLocationManager *locationManager;
    PopOverListController *popListController;
    WYPopoverController *autocompleteTableView;
    CustomPickerView *picker_object;
    CustomTextField *selected_text_field;
    CLLocation *currentLocation;
    
    //CLGeocoder *geocoder;
    // CLPlacemark *placemark;
    //CLPlacemark *placemark;
    BOOL isPickerShown;
    
    NSString * userStatusStr;
    IBOutlet UIView * myView;

}
@end

@implementation WRLocationViewController
@synthesize jobTypeFromArray,comingFromAccountPage;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.table_view reloadData];
    
    
    if(self.flag == 1)
    {
        [currentLaction setTitle:@"Don’t have experience? Click here" forState:0];
        self.headerLbl.text = @"Years of Experience";
    }else
        currentLaction.hidden = YES;
    
    if(self.json_data_from_profile){
        [self.save_button setTitle:@"Save" forState:UIControlStateNormal];
        [self.save_button setImage:nil forState:UIControlStateNormal];
        self.save_button.hidden = YES;
    }
    
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
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height)+64, 0.0);
        keyBoardHight = (keyboardSize.height)+64;
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height)+44, 0.0);
        keyBoardHight = (keyboardSize.height)+44;
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
-(void)KeyboardStarted:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger i = [sender tag];
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CreateCompanyCustomCell * nextCell = [self.table_view cellForRowAtIndexPath:nextIndexPath];
        if ([nextCell.ValueTF.placeholder = @"Enter Location" isEqualToString:@"Enter Location"])
        {
            [nextCell.ValueTF becomeFirstResponder];
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //Setting the table view footer view to zeero
    
     [self performSelector:@selector(KeyboardStarted:) withObject:nil afterDelay:0.7];
    
    if ([self.comingFromAccountPage isEqualToString:@"AccountPage"]) {
        
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save" forState:UIControlStateNormal];
        self.save_button.hidden = NO;
        
    }
    self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.table_view setSeparatorColor:DividerLineColor];
    
    currentLaction =[[UIButton alloc]initWithFrame:CGRectMake(0, 180, self.view.frame.size.width, 40)];
    [currentLaction.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [currentLaction.titleLabel setFont:[UIFont fontWithName:GlobalFontRegular size:16.0]];
    [currentLaction setTitle:@"Use Current Location" forState:0];
    [currentLaction setTitleColor:UIColorFromRGB(0x337ab7) forState:UIControlStateNormal];
    
    [self.view addSubview:currentLaction];
    [currentLaction addTarget:self action:@selector(getUserCurrentLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    [Utility setThescreensforiPhonex:myView];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)CurrentLocationIdentifier
{
    //---- For getting current gps location
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    //------
}
-(NSString *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude
{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false",pdblLatitude, pdblLongitude];
    NSError* error;
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
    
    NSData *data = [locationString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *dic = nil;
    
    if([[json objectForKey:@"results"] count] > 0)
        dic = [[json objectForKey:@"results"] objectAtIndex:0];
    
    NSArray* arr = [dic objectForKey:@"address_components"];

    //Iterate each result of address components - find locality and country
    NSString *cityName;
    NSString *countryName;
    for (NSDictionary* d in arr)
    {
        NSArray* typesArr = [d objectForKey:@"types"];
        NSString* firstType = [typesArr objectAtIndex:0];
        
        if([firstType isEqualToString:@"locality"]){
            cityName = [d objectForKey:@"long_name"];
            break;
        }
        
        if([firstType isEqualToString:@"country"])
            countryName = [d objectForKey:@"long_name"];
    }
    
        return [NSString stringWithFormat:@"%@",cityName];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(currentLocation != nil)
        return;
    
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];

   currentCity = [self getAddressFromLatLon:currentLocation.coordinate.latitude withLongitude:currentLocation.coordinate.longitude];
    
    if([currentCity isKindOfClass:[NSNull class]] || [currentCity isEqualToString:@"(null)"] || currentCity == nil){
        [CustomAlertView showAlertWithTitle:@"Message" message:@"Unable to Determine Location!" OkButton:@"Try again" delegate:self];
        currentCity = @"";
    }
    
    
    self.save_button.hidden = NO;
    [MBProgressHUD hideHUDForView: self.view animated:YES];
    [manager stopUpdatingLocation];
    [self.table_view reloadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        return 100.0f;
        
    }
    
    else{
        
        return CELL_HEIGHT;
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isComingFromSignUpProcess == 100)
        return 4;
    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        static NSString *cellIdentifier = GETCURRENT_LOCATIONCELL_IDENTIFIER;
        GetLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:GET_LOCATION_CELL owner:self options:nil];
            cell = (GetLocationTableViewCell *)[topLevelObjects objectAtIndex:0];
            [cell.ValueTF addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            cell.ValueTF.delegate = self;
        }
        if(self.flag == 1)
        {
            cell.titleLbl.text = @"Year of Work Experience";
            cell.ValueTF.placeholder = @"Enter Experience";
            cell.ValueTF.keyboardType = UIKeyboardTypeNumberPad;
        }
        else
        {
            cell.titleLbl.text = @"Location";
            cell.ValueTF.placeholder = @"Enter Location";
            if(currentCity)
                cell.ValueTF.text = currentCity;
            [cell.cureentLocation.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.cureentLocation setTitle:@"Use Current Location" forState:0];
            [cell.cureentLocation   setTitleColor:UIColorFromRGB(0x337ab7) forState:UIControlStateNormal];
            [cell.cureentLocation addTarget:self action:@selector(getUserCurrentLocation:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell.ValueTF.section = indexPath.section;
        cell.ValueTF.row = indexPath.row;
        
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
        cell.titleLbl.text = indexPath.row == 1?@"Job Type":@"Experience";
        cell.ValueTF.placeholder = indexPath.row == 1?@"Job Type":@"Experience";
        NSMutableArray  *tempArray = nil;
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
            tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobTypes"] mutableCopy];
        else
            tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobTypes"] mutableCopy];
        
        if (indexPath.row == 1) {
        cell.ValueTF.text = [ApplicantHelper getJobTypesFromArray:tempArray];
            
        }
        
        if(indexPath.row == 3)
        {
           cell.titleLbl.text = @"Current Status";
            cell.ValueTF.placeholder = @"Job Status";
            NSMutableArray *statusArray = [CompanyHelper getDropDownArrayWithTittleKey:@"statusValue" parantKey:@"curentStatus"];
            
//            if([[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"status"] !=nil)
//            {
//                if ([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"status"]intValue] == 1)
//                {
//                      cell.ValueTF.text = [statusArray objectAtIndex:[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"status"] intValue]];
//                }
//                else
//                {
//                     cell.ValueTF.text = [statusArray objectAtIndex:[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"status"] intValue]-1];
//                }
//                userStatusStr = cell.ValueTF.text;
//            }
            
            if([[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"status"] !=nil)
            {
                cell.ValueTF.text = [statusArray objectAtIndex:[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"status"] intValue]-1];
                userStatusStr = cell.ValueTF.text;
            }
            
            
            cell.ValueTF.delegate = self;
        }
        
        cell.ValueTF.delegate = self;
        cell.ValueTF.section = indexPath.section;
        cell.ValueTF.row = indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
}
-(void)getUserCurrentLocation:(id)sender
{
    if(_flag == 1){
        [[ApplicantHelper sharedInstance] setParamsValue:@"0" forKey:@"totalexperience"];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
        controller.Flag = 1;
        controller.isFirstTime = YES;
        controller.screen_id = 1000;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    
    currentLocation = nil;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CustomTextField *text_field = (CustomTextField *)textField;
    if(text_field.tag == 0 && text_field.row == 1){
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRPrefrenceListController *prefrence_controller = [mystoryboard instantiateViewControllerWithIdentifier:WRPREFERECES_LIST_CONTROLER_IDENTIFIER];
        prefrence_controller.flag = 1000 + (int)text_field.section;
        
        NSLog(@"%d", prefrence_controller.flag);
        prefrence_controller.wrlocation_jobString = @"jobtypeString";
        [self.navigationController pushViewController:prefrence_controller animated:YES];
        return NO;
    }else if(text_field.section == 0 && text_field.row == 2){
        [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }
    else if(text_field.section == 0 && text_field.row == 3)
    {
         [self showActionSheet:nil];
        return NO;
    }
    else{
        if(self.flag == 1)
            return YES;
        
        [self shwoAutoCompleteLocations:textField];
        if([textField.text length] > 0)
            [popListController filterTheArray:textField.text];
        return YES;
    }
    return YES;
}

-(void)showPickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
    if(isPickerShown)
        return;
    
    selected_text_field = (CustomTextField *)sender;
    NSString *titleString = @"";
    NSMutableArray *tempArray = nil;
    NSMutableArray *tempArray1 = nil;
    int numberOfComponents = 0;
    int idx = 0;
    
    numberOfComponents = 2;
    
    titleString = @"Select experience";
    tempArray = [CompanyHelper getYearsArray];
    tempArray1 = [CompanyHelper getMonthsArray];
    
    //idx = [CompanyHelper getJobRoleIdWithValue:[[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:LOCATION_KEY]  valueForKey:@"title"] parantKey:@"locations" childKey:@"title"];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        
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
        
        [picker_object.done_button setTitle:@"Done" forState:UIControlStateNormal];
        
        
        picker_object.view_height = self.view.frame.size.height;
        picker_object.delegate = self;
        picker_object.objectsArray = tempArray;
        picker_object.subObjectsArray = tempArray1;
        picker_object.numberOfComponents = numberOfComponents;
        [picker_object.picker_view reloadAllComponents];
        [picker_object.picker_view selectRow:idx inComponent:0 animated:YES];
        picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
        [picker_object showPicker];
    });
    isPickerShown = YES;
}


-(void)didSelectPickerWithDoneClicked:(NSString *)value withSubRow:(NSString *)subValue forTag:(int)tag
{
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
        selected_text_field.text = [NSString stringWithFormat:@"%@.%@ years",years,months];
    else
        selected_text_field.text = [NSString stringWithFormat:@"%@.%@ years",years,months];
    
    
    [[ApplicantHelper sharedInstance].paramsDictionary setObject:[NSString stringWithFormat:@"%@.%@",years,months] forKey:@"totalexperience"];
    
    
    [self.table_view reloadData];
}

-(void)MoveToNextField:(int)section row:(int)row
{
    NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
    [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [nextCell.ValueTF becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    CustomTextField *text_field = (CustomTextField *)textField;
    
    if(text_field.row == 0){
        if (textField.text.length == 0) {
            currentCity = @"";
        }else{
            NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            completeString = [Utility trim:completeString];
            if([completeString length] >= 2){
                
                if([completeString length]%2==0){
                    
                    if(text_field.row == 0){
                        if(self.flag == 1){
                            currentCity = completeString;
                            return YES;
                        }
                        [popListController filterTheArray:completeString];
                        [self shwoAutoCompleteLocations:textField];
                    }
                }
            }
            else{
                [autocompleteTableView dismissPopoverAnimated:YES];
                [popListController.filterdCountriesArray  removeAllObjects];
                [popListController.tableView reloadData];
            }
        }
    }
    return YES;
}

-(void)didSelectValue:(NSString *)value forIndex:(int)index
{
    self.save_button.hidden = NO;
    currentCity = value;
    [self.table_view reloadData];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

-(void)textChanged:(UITextField *)textField


{
    CustomTextField *text_field = (CustomTextField *)textField;
    
    if(text_field.row == 0){
        
        if (textField.text.length == 0) {
            
            currentCity = @"";
            
            
        }
        else{
            
            [popListController filterTheArray:textField.text];
            [self shwoAutoCompleteLocations:textField];
            
        }
        
        
        
        
    }
    
    
    
}


-(IBAction)previousButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)nextButtonAction:(id)sender
{

    NSLog(@"%@",currentCity);
    
    if(currentCity){
        [[ApplicantHelper sharedInstance] setParamsValue:currentCity forKey:@"location"];
        [self.json_data_from_profile setObject:currentCity forKey:@"location"];
    }
    
    if(self.json_data_from_profile){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if(_flag == 1){
        if([currentCity intValue] > 0 && [currentCity intValue] <= 30){
            [[ApplicantHelper sharedInstance] setParamsValue:[NSString stringWithFormat:@"%@",currentCity] forKey:@"totalexperience"];
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            [CustomAlertView showAlertWithTitle:@"Error" message:@"Your experience must be between 1 to 30 years." OkButton:@"OK" delegate:self];
        }
    }else{
        
        NSMutableArray  *tempArray = nil;
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
            tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobTypes"] mutableCopy];
        else
            tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobTypes"] mutableCopy];
        
        if (tempArray.count == 0) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            tempArray = [userDefaults objectForKey:@"tableViewDataText"];
            
            
            
            
        }
        
        if([currentCity length] > 0 && [ selected_text_field.text length]  > 0 && [tempArray count] > 0 && [userStatusStr length]>0)
        {
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:[NSString stringWithFormat:@"%@ years",selected_text_field.text] forKey:@"totalexperiencedisplay"];
            
            [[ApplicantHelper sharedInstance] updateLocationServer:self requestType:100];
       }
        
        else
            
        {
            [CustomAlertView showAlertWithTitle:@"Error" message:@"Please fill all the fields." OkButton:@"OK" delegate:self];
        }
    }
}


-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 100){
        
        if ([selected_text_field.text isEqualToString:@"0.0 years"]) {
            
            
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:APPLICANT_REGISTRATION_ID];
            
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            NSLog(@"%@",userName);
            [Utility getMixpanelData:APPLICANT_SIGNUP_PREFNOEXP setProperties:userName];
            
            
            
            
            
        }
        else{
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",FIRST_NAME_KEY,APPLICANT_REGISTRATION_ID];
            
            
            [Utility getMixpanelData:APPLICANT_SIGNUP_PREFEXP setProperties:userName];
            
            
            
            
        }
        
        
        
        
        
        NSMutableDictionary *jobLocations = [[NSMutableDictionary alloc] initWithCapacity:0];
        [jobLocations setObject:[NSNumber numberWithInt:-1] forKey:@"locationId"];
        [jobLocations setObject:@"All" forKey:@"title"];
        
        NSMutableDictionary *jobTypes = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobType"];
        NSMutableDictionary *userPreferences = [[NSMutableDictionary alloc] initWithCapacity:0];
        [userPreferences setObject:[NSArray arrayWithObjects:jobLocations, nil] forKey:@"jobLocations"];
        [userPreferences setObject:[NSArray arrayWithObjects:jobTypes, nil] forKey:@"jobTypes"];
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:userPreferences forKey:@"userPreferences"];
        
        if([[data valueForKey:@"percentage"] floatValue] > 0)
            [ApplicantHelper sharedInstance].profilePercentage = [[data valueForKey:@"percentage"] floatValue];
        
        [ApplicantHelper sharedInstance].halfProfile = [[data valueForKey:@"halfProfile"] boolValue];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRJobFunctionViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:@"WRJobFunctionViewController"];
        NSString *valueToSave = @"verifyMobile";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"screen"];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"responseData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController pushViewController:controller animated:YES];
        
        //        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
        //     WRChooseCompanyIndustry *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER];
        //  [self.navigationController pushViewController:controller animated:YES];
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
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:@"1" forKey:@"status"];
            [self.table_view reloadData];
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    
    if([statusArray count]  > 1){
        [actionSheet addAction:[UIAlertAction actionWithTitle:[statusArray objectAtIndex:1] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // OK button tapped.
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:@"2" forKey:@"status"];
            [self.table_view reloadData];
            
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
    
    if([statusArray count]  > 2){
        [actionSheet addAction:[UIAlertAction actionWithTitle:[statusArray objectAtIndex:2] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // OK button tapped.
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:@"3" forKey:@"status"];
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


#pragma AUTOCOMPLETE TEXT FIELD DELEGATE
- (void)dropDownTextField:(CHDropDownTextField *)dropDownTextField didChooseDropDownOptionAtIndex:(NSUInteger)index
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
