//
//  WRJobsViewController.m
//  workruit
//
//  Created by Admin on 10/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRJobsViewController.h"
#import "SVPullToRefresh.h"
#import "CustomActiveJobsCell.h"

@interface WRJobsViewController ()<WRCreateNewJobControllerDelegate>
{
    NSMutableArray *jobsArray;
    BOOL checkFirstTime;
    IBOutlet UIView * myView;
    
}
@end

@implementation WRJobsViewController

-(void)didSucessfullyClosedJob:(NSDictionary *)job forTag:(int)tag
{
    //    if (self.segmentController.selectedSegmentIndex == 0) {
    //        if (jobsArray.count > 0) {
    //            NSDictionary *jobFromList = [jobsArray objectAtIndex:0];
    //            if ([[jobFromList valueForKey:@"jobPostId"] intValue] == [[jobsArray valueForKey:@"jobPostId"] intValue]) {
    //
    //            }
    //        }
    //    }
}



-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)createNewJobAction:(id)sender
{
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRCreateNewJobController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRCREATE_NEW_JOB_CONTROLLER_IDENTIFIER];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if([CompanyHelper sharedInstance].isJobPosted){
        [CompanyHelper sharedInstance].isJobPosted = NO;
        self.segmentController.selectedSegmentIndex = 1;
    }
    
    if(self.navigateToCreateJobScreen == 113){
        
        [self createNewJobAction:nil];
        self.navigateToCreateJobScreen = - 1;
    }
    
    NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:JOBSLISTARRAY];
    NSMutableArray *arrayList = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
    
    [self filterTheArray:arrayList];
    
    if([jobsArray count] > 0){
        self.table_view.hidden = NO;
        self.create_job_btn.hidden = NO;
        self.no_jobs_view.hidden = NO;
        [self.table_view reloadData];
    }else{
        self.no_jobs_view.hidden = YES;
        
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:COMPANY_JOB_POST setProperties:userName];
        
        
    }
    
    [FireBaseAPICalls captureScreenDetails:APPLICANT_RIGHT_SWIPE];
    
    [self loadDataFromService:nil];
}

-(void)filterTheArray:(NSMutableArray *)filterdArray
{
    jobsArray = nil;
    jobsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(NSMutableDictionary *jobObject in filterdArray)
    {
        switch (self.segmentController.selectedSegmentIndex)
        {
                case 0: //Active
            {
                if([[jobObject valueForKey:@"status"] intValue] == 2)
                [jobsArray addObject:jobObject];
                
                NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:FIRST_NAME_KEY];
                NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                            valueForKey:RECRUITER_REGISTRATION_ID];
                
                
                NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
                
                
                [Utility getMixpanelData:COMPANY_JOB_ACTIVE setProperties:userName];
                
                self.titleLbl.text = @"There are no active jobs.";
                self.messageLbl.text = @"Get started and post a job today.";
            }break;
                case 1: //Pending
            {
                if([[jobObject valueForKey:@"status"] intValue] == 1 || [[jobObject valueForKey:@"status"] intValue] == 4)
                [jobsArray addObject:jobObject];
                
                NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:FIRST_NAME_KEY];
                NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                            valueForKey:RECRUITER_REGISTRATION_ID];
                
                
                NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
                
                
                [Utility getMixpanelData:COMPANY_JOB_PENDING setProperties:userName];
                
                self.titleLbl.text = @"There are no pending jobs.";
                self.messageLbl.text = @"Get started and post a job today.";
                
            }break;
                case 2: //Closed
            {
                if([[jobObject valueForKey:@"status"] intValue] == 3)
                [jobsArray addObject:jobObject];
                
                
                NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                       valueForKey:FIRST_NAME_KEY];
                NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                            valueForKey:RECRUITER_REGISTRATION_ID];
                
                
                NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
                
                
                [Utility getMixpanelData:COMPANY_JOB_CLOSED setProperties:userName];
                
                self.titleLbl.text = @"There are no closed jobs.";
                self.messageLbl.text = @"Get started and post a job today.";
            }break;
        }
    }
    
    if([jobsArray count] > 0)
    {
        self.table_view.hidden = NO;
        self.create_job_btn.hidden = NO;
        self.no_jobs_view.hidden = YES;
        
        if(checkFirstTime == YES)
        {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }];
            checkFirstTime = NO;
        }
        else
        {
            switch (self.segmentController.selectedSegmentIndex)
            {
                    case 0:
                {
                    NSData * unArchieve = [[NSUserDefaults standardUserDefaults]objectForKey:@"SaveIndexvalue1"];
                    NSIndexPath* indexValue = [NSKeyedUnarchiver unarchiveObjectWithData:unArchieve];
                    if (jobsArray.count >= indexValue.section)
                    {
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            @try
                            {
                                [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexValue.row-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
                            }
                            @catch (NSException *exception)
                            {
                            }
                        }];
                    }
                }
                    case 1:
                {
                    NSData * unArchieve = [[NSUserDefaults standardUserDefaults]objectForKey:@"SaveIndexvalue2"];
                    NSIndexPath* indexValue = [NSKeyedUnarchiver unarchiveObjectWithData:unArchieve];
                    if (jobsArray.count >= indexValue.section)
                    {
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            @try
                            {
                                [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexValue.row-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
                            }
                            @catch (NSException *exception)
                            {
                            }
                        }];
                    }
                }
                    case 2:
                {
                    NSData * unArchieve = [[NSUserDefaults standardUserDefaults]objectForKey:@"SaveIndexvalue3"];
                    NSIndexPath* indexValue = [NSKeyedUnarchiver unarchiveObjectWithData:unArchieve];
                    if (jobsArray.count >= indexValue.section)
                    {
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            @try
                            {
                                [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexValue.row-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
                            }
                            @catch (NSException *exception)
                            {
                            }
                        }];
                    }
                }
                    break;
            }
        }
    }
    else{
        self.table_view.hidden = YES;
        self.create_job_btn.hidden = YES;
        self.no_jobs_view.hidden = NO;
        
        switch (self.segmentController.selectedSegmentIndex) {
                case 0: //Active
            {
                self.titleLbl.text = @"There are no active jobs.";
                self.messageLbl.text = @"Get started and post a job today.";
            }
                break;
                case 1: //Pending
            {
                self.titleLbl.text = @"There are no pending jobs.";
                self.messageLbl.text = @"Get started and post a job today.";
            }
                break;
                case 2: //Closed
            {
                self.titleLbl.text = @"There are no closed jobs.";
                self.messageLbl.text = @"Get started and post a job today.";
            }
                break;
        }
    }
    
    
    if (self.segmentController.selectedSegmentIndex == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%@",[[self->jobsArray firstObject] valueForKey:@"jobPostId"]] forKey:@"lastCreatedJobId"];
        [defaults setObject:[[self->jobsArray firstObject] valueForKey:@"title"] forKey:@"lastCreatedJobName"];  NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:[self->jobsArray firstObject]];
        [defaults setObject:dataArray forKey:@"lastCreatedJobObject"];
        [CompanyHelper sharedInstance].prefrences_object = [self->jobsArray firstObject];
        [defaults synchronize];
    }
    
    
    [self.table_view reloadData];
}

-(void)loadDataFromService:(NSNotification *)notification
{
    [[CompanyHelper sharedInstance] getApplicantProfilesWithDelegate:self requestType:jobsArray?-105:105];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.table_view.hidden = YES;
    self.create_job_btn.hidden = YES;
    self.no_jobs_view.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDataFromService:)
                                                 name:RELOADJOBSLIST
                                               object:nil];
    
    self.segmentController.selectedSegmentIndex = 0;
    
    __weak WRJobsViewController *weakSelf = self;
    // setup pull-to-refresh
    [self.table_view addPullToRefreshWithActionHandler:^{
        [weakSelf  loadDataFromService:nil];
    }];
    
    //Setting the table view footer view to zeero
    // self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    // [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    checkFirstTime = YES;
    
    [Utility setThescreensforiPhonex:myView];
    
    // self.top_Contsrint.constant =-50;
    
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.table_view.pullToRefreshView stopAnimating];
    
    NSMutableArray *tempObjectsArray = (NSMutableArray *)[data valueForKey:@"data"];
    [self filterTheArray:tempObjectsArray];
    
    NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:tempObjectsArray];
    [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:JOBSLISTARRAY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag{}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return jobsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"customActiveJobsCellIdentifier";
    CustomActiveJobsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomActiveJobsCell" owner:self options:nil];
        cell = (CustomActiveJobsCell *)[topLevelObjects objectAtIndex:0];
    }
    
    if ([[[jobsArray objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==2)
    {
        cell.expLabel.text =[NSString stringWithFormat:@"Expires in %@ days",[[jobsArray objectAtIndex:indexPath.section] valueForKey:@"expireDays"]];
        [cell.expLabel setTextColor:[UIColor colorWithRed:244/255.0 green:78/255.0 blue:75/255.0 alpha:1]];
        cell.expLabel.font = [UIFont fontWithName:GlobalFontSemibold size:14];
        
        NSString *dateStr = [[jobsArray objectAtIndex:indexPath.section]  valueForKey:@"createdDate"];
        dateStr = [Utility  getStringWithDate:[Utility getStringWithDate_Compamny:dateStr] withOldFormat:@"dd MMM yyyy hh:mm" newFormat:@"MMM dd"];
        cell.jobDateLbl.text = dateStr;
        
        
        // cell.jobDateLbl.text = [Utility formateTheDateWithString:dateStr];
        
        //        NSString *conver_sationmatch_date = [[dictionary valueForKey: @"jobPostId"] valueForKey:@"conversationMatchDate"];
        //        conver_sationmatch_date = [Utility  getStringWithDate:[Utility getStringWithDate_Compamny:conver_sationmatch_date] withOldFormat:@"dd MMM yyyy hh:mm" newFormat:@"MMM dd"];
        //        cell.jobDateLbl.text = conver_sationmatch_date;
        
        
        // Save the indexpath
        NSData *archiver = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
        [[NSUserDefaults standardUserDefaults]setObject:archiver forKey:@"SaveIndexvalue1"];
        
    }
    else if ([[[jobsArray objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==1||[[[jobsArray objectAtIndex:indexPath.section] valueForKey:@"status"]intValue]==4)
    {
        cell.expLabel.text =@"Pending";
        [cell.expLabel setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
        cell.expLabel.font = [UIFont fontWithName:GlobalFontRegular size:14];
        
        //NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:NO];
        //NSArray *descriptors=[NSArray arrayWithObject: descriptor];
        //NSArray *reverseOrder=[jobsArray sortedArrayUsingDescriptors:descriptors];;
        
        NSString *dateStr = [[jobsArray objectAtIndex:indexPath.section]  valueForKey:@"updatedDate"];
        dateStr = [Utility  getStringWithDate:[Utility getStringWithDate_Compamny:dateStr] withOldFormat:@"dd MMM yyyy hh:mm" newFormat:@"MMM dd"];
        cell.jobDateLbl.text= dateStr;
        
        // Save the indexpath
        NSData *archiver = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
        [[NSUserDefaults standardUserDefaults]setObject:archiver forKey:@"SaveIndexvalue2"];
        
    }
    else if ([[[jobsArray objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==3)
    {
        cell.expLabel.text =[NSString stringWithFormat:@"Closed %@ days ago",[[jobsArray objectAtIndex:indexPath.section] valueForKey:@"expireDays"]];
        [cell.expLabel setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
        cell.expLabel.font = [UIFont fontWithName:GlobalFontRegular size:14];
        
        //posted date
        //NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:NO];
        //NSArray *descriptors=[NSArray arrayWithObject: descriptor];
        //NSArray *reverseOrder=[jobsArray sortedArrayUsingDescriptors:descriptors];;
        
        NSString *dateStr = [[jobsArray objectAtIndex:indexPath.section]  valueForKey:@"updatedDate"];
        dateStr = [Utility  getStringWithDate:[Utility getStringWithDate_Compamny:dateStr] withOldFormat:@"dd MMM yyyy hh:mm" newFormat:@"MMM dd"];
        cell.jobDateLbl.text= dateStr;
        
        // cell.jobDateLbl.text = [Utility formateTheDateWithString:dateStr];
        
        // Save the indexpath
        NSData *archiver = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
        [[NSUserDefaults standardUserDefaults]setObject:archiver forKey:@"SaveIndexvalue3"];
        
    }
    
    cell.userTitleLbl.text = [[jobsArray objectAtIndex:indexPath.section] valueForKey:@"title"];
    
    int jb_id = [[[[jobsArray objectAtIndex:indexPath.section] valueForKey:@"jobFunction"] objectAtIndex:0] intValue];
    
    NSString *jobFunction_name = [CJCompanyHelper getJobRoleIdWithidx:jb_id parantKey:@"jobFunctions" childKey:@"jobFunctionId" withValueKey:@"jobFunctionName"];
    cell.jobTitleLbl.text = jobFunction_name;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentController.selectedSegmentIndex) {
            case 0:
            [FireBaseAPICalls captureMixpannelEvent:COMPANY_JOB_ACTIVEDETAIL];
            break;
            case 1:
            [FireBaseAPICalls captureMixpannelEvent:COMPANY_JOB_PENDINGDETAIL];
            break;
            case 2:
            [FireBaseAPICalls captureMixpannelEvent:COMPANY_JOB_CLOSEDDETAILS];
            break;
    }
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRCreateNewJobController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRCREATE_NEW_JOB_CONTROLLER_IDENTIFIER];
    controller.hidesBottomBarWhenPushed = YES;
    controller.delegate = self;
    controller.selectedDictionary = [[jobsArray objectAtIndex:indexPath.section] mutableCopy];
    [self.navigationController pushViewController:controller  animated:YES];
}

-(IBAction)segmentControllerChange:(id)sender
{
    NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:JOBSLISTARRAY];
    NSMutableArray *arrayList = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
    [self filterTheArray:arrayList];
}

@end
