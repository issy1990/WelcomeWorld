//
//  WRPrefrenceListController.m
//  workruit
//
//  Created by Admin on 11/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRPrefrenceListController.h"


@interface WRPrefrenceListController ()
{
    NSMutableArray *jobsArray;
    NSMutableDictionary *selected_dictionary;
     NSMutableArray *SelectedRows;
    IBOutlet UIView * myView;
    NSString * selctJob;

    
}
@end

@implementation WRPrefrenceListController

@synthesize wrlocation_jobString;



- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // [self.table_view reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.save_button.hidden = YES;
    self.no_jobs_view.hidden = YES;
    
    if(self.flag == 1000)
    {
        NSMutableArray  *tempArray = nil;
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
        tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobTypes"] mutableCopy];
        else
        tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobTypes"] mutableCopy];
        
        jobsArray = [CompanyHelper getArrayWithParentKey:@"jobTypes"];
        
        if(![Utility isComapany]){
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:APPLICANT_REGISTRATION_ID];
            
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            
            [Utility getMixpanelData:APPLICANT_PREFERENCE_VIEW setProperties:userName];
            
            
            if(tempArray.count == 0){
                
                
                NSMutableArray  *tempArray1 = [[ApplicantHelper sharedInstance].paramsDictionary  valueForKey:@"SelectedRows"] ;
                
                for (NSMutableDictionary *dictionary1  in jobsArray)
                for (NSMutableDictionary *dictionary  in tempArray1)
                if ([[dictionary valueForKey:@"jobTypeId"] intValue] == [[dictionary1 valueForKey:@"jobTypeId"] intValue]){
                    [dictionary1 setObject:@"1" forKey:@"isSelected"];
                    break;
                }
                else
                [dictionary1 setObject:@"0" forKey:@"isSelected"];
            }
            else{
                for (NSMutableDictionary *dictionary1  in jobsArray)
                for (NSMutableDictionary *dictionary  in tempArray)
                if ([[dictionary valueForKey:@"jobTypeId"] intValue] == [[dictionary1 valueForKey:@"jobTypeId"] intValue]){
                    [dictionary1 setObject:@"1" forKey:@"isSelected"];
                    break;
                }
                else
                [dictionary1 setObject:@"0" forKey:@"isSelected"];
            }
        }
        
        else{
            
            //Company
            
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:RECRUITER_REGISTRATION_ID];
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            [Utility getMixpanelData:COMPANY_PREFERENCE_VIEW setProperties:userName];
            NSMutableDictionary *prefrences_object  =   [[CompanyHelper sharedInstance].prefrences_object mutableCopy];
            
            for(NSMutableDictionary *dictionary in jobsArray){
                if([[dictionary valueForKey:@"jobTypeId"] intValue] == [[prefrences_object valueForKeyPath:@"jobType.jobTypeId"] intValue]){
                    [dictionary setObject:@"1" forKey:@"selected"];
                }
            }
        }
        
        self.headerTitleLbl.text = @"Job Type";
        
    }else if(self.flag == 1001){
        
        NSMutableArray  *tempArray = nil;
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
        tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobLocations"] mutableCopy];
        else
        tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobLocations"] mutableCopy];
        
        
        jobsArray = [CompanyHelper getArrayWithParentKey:@"locations"];
        
        
        if(![Utility isComapany])
        {
            if(tempArray.count == 0)
            {
                NSMutableArray  *tempArray1 = [[ApplicantHelper sharedInstance].paramsDictionary  valueForKey:@"SelectedRows"] ;
                
                for (NSMutableDictionary *dictionary1  in jobsArray)
                for (NSMutableDictionary *dictionary  in tempArray1)
                if ([[dictionary valueForKey:@"locationId"] intValue] == [[dictionary1 valueForKey:@"locationId"] intValue]){
                    [dictionary1 setObject:@"1" forKey:@"isSelected"];
                    break;
                }
                else
                [dictionary1 setObject:@"0" forKey:@"isSelected"];
                
            }
            else if ([[[tempArray objectAtIndex:0] valueForKey:@"title"] isEqualToString:@"All"])
            {
                for (NSMutableDictionary *dictionary1  in jobsArray)
                for (NSMutableDictionary *dictionary  in tempArray)
                if ([[dictionary valueForKey:@"locationId"] intValue] == [[dictionary1 valueForKey:@"locationId"] intValue]){
                    [dictionary1 setObject:@"0" forKey:@"isSelected"];
                    break;
                }
                else
                [dictionary1 setObject:@"1" forKey:@"isSelected"];
            }
            
            else{
                for (NSMutableDictionary *dictionary1  in jobsArray)
                for (NSMutableDictionary *dictionary  in tempArray)
                if ([[dictionary valueForKey:@"locationId"] intValue] == [[dictionary1 valueForKey:@"locationId"] intValue]){
                    [dictionary1 setObject:@"1" forKey:@"isSelected"];
                    break;
                }
                else
                [dictionary1 setObject:@"0" forKey:@"isSelected"];
            }
            
        }else{
            //Company
            NSMutableDictionary *prefrences_object  =   [[CompanyHelper sharedInstance].prefrences_object mutableCopy];
            
            for(NSMutableDictionary *dictionary in jobsArray){
                if([[dictionary valueForKey:@"locationId"] intValue] == [[prefrences_object valueForKeyPath:@"location.locationId"] intValue]){
                    [dictionary setObject:@"1" forKey:@"selected"];
                }
            }
        }
        self.headerTitleLbl.text = @"Location";
        
    }else{
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTheJobsFromServer:)
                                                     name:RELOADJOBSLIST
                                                   object:nil];
        
        [self.table_view setSeparatorColor:DividerLineColor];
        
        if(![CompanyHelper sharedInstance].prefrences_object) {
            NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastCreatedJobObject"];
            [CompanyHelper sharedInstance].prefrences_object = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
        }
        
        selected_dictionary = [[CompanyHelper sharedInstance].prefrences_object mutableCopy];
        self.headerTitleLbl.text = @"Jobs";
        NSArray *activeJobs = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"ActiveJobs"]];
        [self updateJobsListWithArray:[activeJobs mutableCopy]];
        [self.table_view reloadData];
    }
    
    [Utility setThescreensforiPhonex:myView];
    
}

-(void)reloadTheJobsFromServer:(NSNotification *)notification
{
    [[CompanyHelper sharedInstance] getApplicantProfilesWithDelegate:self requestType:100];
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if([Utility isComapany]){
        [FireBaseAPICalls captureScreenDetails:COMPANY_PREFERENCES];
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:COMPANY_PREFERENCE_UPDATE setProperties:userName];
   
    }
    else
    {
        [FireBaseAPICalls captureScreenDetails:APPLICANT_PREFERENCES];
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:APPLICANT_PREFERENCE_UPDATE setProperties:userName];
        
    }
    
    if(tag == 100 && ![Utility isComapany]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self updateJobsListWithArray:[data valueForKey:@"data"]];
    }
}
-(void)updateJobsListWithArray:(NSMutableArray *)array
{
    jobsArray = nil;
    jobsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableArray *tempArray = (NSMutableArray *)array;
    BOOL isSelected = NO;
    for(NSMutableDictionary *dictionary in tempArray)
    {
        NSMutableDictionary *dictionaryNew = [dictionary mutableCopy];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([[dictionaryNew valueForKey:@"jobPostId"] intValue] == [[defaults valueForKey:@"lastCreatedJobId"] intValue])
        {
            [dictionaryNew setObject:@"1" forKey:@"isSelected"];
            isSelected = YES;
        }else
        {
            [dictionaryNew setObject:@"0" forKey:@"isSelected"];
        }
        [jobsArray addObject:dictionaryNew];
    }
    
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:jobsArray];
    jobsArray = [[orderedSet array] mutableCopy];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM yyyy dd hh:mm a"];
    [jobsArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *createDatStringFirst = [(NSDictionary *)obj1 valueForKey:@"createdDate"];
        if (createDatStringFirst) {
            NSDate *createdDateFirst = [formatter dateFromString:createDatStringFirst];
            NSString *createDateStringSecond = [(NSDictionary *)obj2 valueForKey:@"createdDate"];
            if (createDateStringSecond) {
                NSDate *createdDateSecond = [formatter dateFromString:createDateStringSecond];
                if (createdDateFirst > createdDateSecond) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }
        }
        return NSOrderedSame;
    }];
    if([jobsArray count] > 0){
        self.table_view.hidden = NO;
        self.no_jobs_view.hidden = YES;
        [self.table_view reloadData];
    }else{
        self.no_jobs_view.hidden = NO;
        self.table_view.hidden = YES;
    }
}
-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)saveButtonAction:(id)sender
{
    if(![Utility isComapany])
    {
        NSMutableDictionary *dictionary  = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences"] mutableCopy];
        if(dictionary == nil)
            dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];

        if(self.flag == 1000)
        {
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"jobTypes"];
            
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"SelectedRows"];
           
           [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"userPreferences.jobTypes"];
        }
        else
        {
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray]  forKey:@"jobLocations"];
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"SelectedRows"];
            
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"userPreferences.jobLocations"];
        }
      
        if (wrlocation_jobString.length>0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self callAPIWithParams];
        }
       
    }
    else
    {
        [CompanyHelper sharedInstance].prefrences_object = nil;
        [CompanyHelper sharedInstance].companyProfiles = nil;
        [CompanyHelper sharedInstance].loadJobCardsWithPrefreceSettings = NO;
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%@",[selected_dictionary valueForKey:@"jobPostId"]] forKey:@"lastCreatedJobId"];
        [defaults setObject:[selected_dictionary valueForKey:@"title"] forKey:@"lastCreatedJobName"];
        
        NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:[selected_dictionary mutableCopy]];
        [defaults setObject:dataArray forKey:@"lastCreatedJobObject"];
        
        [defaults setObject:selctJob forKey:@"showJobHeader"];
        
        [defaults synchronize];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 20.0f;
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
    return [jobsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = MULTIPLE_SELECTION_CELL_IDENTIFIER;
    MultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MULTIPLE_SELECTION_CELL owner:self options:nil];
        cell = (MultipleSelectionCell *)[topLevelObjects objectAtIndex:0];
    }
    if(self.flag == 1000){
            cell.titleLbl.text = [[jobsArray objectAtIndex:indexPath.row] valueForKey:@"jobTypeTitle"];
        
        if([[[jobsArray objectAtIndex:indexPath.row] valueForKey:@"isSelected"] intValue] == 1)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else cell.accessoryType = UITableViewCellAccessoryNone;
        
        
    }
    else if(self.flag == 1001){
            cell.titleLbl.text = [[jobsArray objectAtIndex:indexPath.row] valueForKey:@"title"];
        
        if([[[jobsArray objectAtIndex:indexPath.row] valueForKey:@"isSelected"] intValue] == 1)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
            cell.titleLbl.text = [[jobsArray objectAtIndex:indexPath.row] valueForKey:@"title"];
        
        if([[[jobsArray objectAtIndex:indexPath.row] valueForKey:@"selected"] intValue] == 0)
            cell.accessoryType  = UITableViewCellAccessoryNone;
        else
            cell.accessoryType  = UITableViewCellAccessoryCheckmark;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![Utility isComapany]){
        
         self.save_button.hidden = NO;
        // Applicant side code
        if([[[jobsArray objectAtIndex:indexPath.row] valueForKey:@"isSelected"] intValue] == 1)
            [[jobsArray objectAtIndex:indexPath.row] setObject:@"0" forKey:@"isSelected"];
        else
            [[jobsArray objectAtIndex:indexPath.row] setObject:@"1" forKey:@"isSelected"];
        }
    else{
        if(self.flag == 1000 || self.flag == 1001){
            NSMutableDictionary  *selected_job_dictionary = [CompanyHelper sharedInstance].prefrences_object;
            if(self.flag == 1001)
                [selected_job_dictionary setObject:[jobsArray objectAtIndex:indexPath.row] forKey:@"location"];
            else
                [selected_job_dictionary setObject:[jobsArray objectAtIndex:indexPath.row] forKey:@"jobType"];
            
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:[selected_job_dictionary mutableCopy]];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:@"lastCreatedJobObject"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            selctJob =[[jobsArray objectAtIndex:indexPath.row] valueForKey:@"title"];
            self.save_button.hidden = NO;
            for(int  i = 0; i < [jobsArray count]; i++){
                NSMutableDictionary *dictionary = [jobsArray objectAtIndex:i];
                if(i == indexPath.row){
                    [dictionary setObject:@"1" forKey:@"selected"];
                    selected_dictionary = dictionary;
                }
                else
                    [dictionary setObject:@"0" forKey:@"selected"];
            }
        }
    }
    [self.table_view reloadData];
}

-(NSMutableArray *)checkCountInArray
{
    
    NSMutableArray *selected_industies = [[NSMutableArray alloc] initWithCapacity:4];
    for(NSMutableDictionary *dictionary in jobsArray)
        if([[dictionary valueForKey:@"isSelected"] intValue] == 1)
            [selected_industies addObject:dictionary];
    
    NSLog(@"%@",selected_industies);
    
    return selected_industies;
}


-(void)callAPIWithParams
{
    ///////
    NSMutableArray *jobTypes_values_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *jobLocations_values_array = [[NSMutableArray alloc] initWithCapacity:0];
    
     ApplicantHelper *selectedRows = [[ApplicantHelper alloc]init];
    if(self.flag == 1000){
       
        
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobTypeId"] length] <= 0 )
        {
          [jobTypes_values_array addObjectsFromArray:[selectedRows getJobTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobTypes"] ]];
              NSMutableArray  *tempArray = nil;
            if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
                tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobLocations"] mutableCopy];
            else
                tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobLocations"] mutableCopy];
            
            
            NSLog(@"%@",tempArray);
            if (tempArray.count > 0) {
                if ([[[tempArray objectAtIndex:0] valueForKey:@"title"] isEqualToString:@"All"]) {
                    tempArray   = [CompanyHelper getArrayWithParentKey:@"locations"] ;
                    
                }
                [jobLocations_values_array addObjectsFromArray:[selectedRows getLocationTypesIdFromArray:tempArray ]];
            }
        }
        else{
        
         [jobTypes_values_array addObjectsFromArray:[selectedRows getJobTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobTypeId"] ]];
            
            [jobLocations_values_array addObjectsFromArray:[selectedRows getLocationTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobLocations"] ]];
        }
    }
    
    else{
        if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"locationId"] length] <= 0 )
        {
           [jobLocations_values_array addObjectsFromArray:[selectedRows getLocationTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobLocations"] ]];
               NSMutableArray  *tempArray = nil;
            if([[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
                tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"userPreferences.jobTypes"] mutableCopy];
            else
                tempArray =   [[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"jobTypes"] mutableCopy];
             [jobTypes_values_array addObjectsFromArray:[selectedRows getJobTypesIdFromArray:tempArray ]];
        }
        else{
         [jobLocations_values_array addObjectsFromArray:[selectedRows getLocationTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobLocations"] ]];
            [jobTypes_values_array addObjectsFromArray:[selectedRows getJobTypesIdFromArray:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobTypeId"] ]];
        }
    }
    //[jobLocations_values_array addObject:[NSNumber numberWithInt:-1]];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:jobLocations_values_array forKey:@"locationId"];
    [params setObject:jobTypes_values_array forKey:@"jobTypeId"];
    [params setObject:[NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults]valueForKey:@"savedExternalJobsValue"]integerValue]] forKey:@"hide_ext"];

    [[NSUserDefaults standardUserDefaults]setObject:jobLocations_values_array forKey:@"locationId"];
    [[NSUserDefaults standardUserDefaults]setObject:jobTypes_values_array forKey:@"jobTypeId"];

    NSLog(@"%@",params);
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [[ApplicantHelper sharedInstance] updateApplicantPreferences:self requestType:100 params:params];
    }];
    
   // [self.navigationController popViewControllerAnimated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
