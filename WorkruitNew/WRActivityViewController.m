//
//  WRActivityViewController.m
//  workruit
//
//  Created by Admin on 10/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRActivityViewController.h"
#import "AppDelegate.h"
#import "SVPullToRefresh.h"
#import "SkeletonCellTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "LoadOtherJobsViewController.h"

@interface WRActivityViewController ()
{
    IBOutlet UIView * myView;
    
    NSMutableArray *checkArray, *additionalArray, *arrayObjects;
    NSMutableDictionary *dictionary_object, *savedDict;
    
    BOOL checkFirst;
    BOOL loadCount;
    BOOL checkFirstTime;
}

@property(nonatomic, assign)BOOL conversationUpdated;
@end

@implementation WRActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    checkFirstTime = YES;
    
    checkArray = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadConversations:)
                                                 name:RELOADCONVERSATIONLIST
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReciveHistoryWithData:)
                                                 name:DIDRECIVEHISTORYWITHDATA
                                               object:nil];
    
    __weak WRActivityViewController *weakSelf = self;
    [self.table_view addPullToRefreshWithActionHandler:^{
        checkFirst = YES;
        [weakSelf  loadDataFromService];
    }];
    
    UILabel *labelStop = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 30.f)];
    labelStop.text = @"stoped";
    labelStop.textAlignment = NSTextAlignmentCenter;
    [self.table_view.infiniteScrollingView setCustomView:labelStop forState:SVInfiniteScrollingStateStopped];
    
    UILabel *labelTriggered = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 30.f)];
    labelTriggered.text = @"Triggered";
    labelTriggered.textAlignment = NSTextAlignmentCenter;
    [self.table_view.infiniteScrollingView setCustomView:labelTriggered forState:SVInfiniteScrollingStateTriggered];
    
    UILabel *labelLoading = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 30.f)];
    labelLoading.text = @"Loading...";
    labelLoading.textAlignment = NSTextAlignmentCenter;
    [self.table_view.infiniteScrollingView setCustomView:labelLoading forState:SVInfiniteScrollingStateLoading];
    
    if([Utility isComapany]){
        [self.segmentController setTitle:@"Interested" forSegmentAtIndex:0];
        self.titleLbl.text = @" No interested profiles";
        self.messageLbl.text = @"When you like applicants, you’ll be able to review their profiles here.";
    }else{
        [self.segmentController setTitle:@"Applied" forSegmentAtIndex:0];
        
        self.titleLbl.text = @"No applied jobs";
        self.messageLbl.text = @"When you apply for jobs, you’ll be able to review details here.";
    }
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.table_view setSeparatorColor:DividerLineColor];
    
    [Utility setThescreensforiPhonex:myView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FireBaseAPICalls captureMixpannelEvent:[Utility isComapany]?COMPANY_ACTIVITY:APPLICANTS_ACTIVITY];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.table_view.hidden = YES;
    self.message_view.hidden = YES;
    self.skeleton_Image.hidden = YES;
    
    checkFirst = YES;
    //Load data
    [self loadDataFromService];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadDataFromService
{
    if(self.isConversationFlag) {
        NSMutableArray __block *backgroundArray = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            backgroundArray = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                arrayObjects = backgroundArray;
                self.segmentController.selectedSegmentIndex = 1;
                
                checkArray = arrayObjects;
                
                if([arrayObjects count] > 0) {
                    self.table_view.hidden = NO;
                    self.message_view.hidden = YES;
                } else {
                    self.table_view.hidden = YES;
                    //            self.message_view.hidden = NO;
                }
                
                
                if (!self.conversationUpdated) {
                    self.table_view.hidden = YES;
                    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                }
                [self updateUI];
                
                if([Utility isComapany]) {
                    [[CompanyHelper sharedInstance] getRecruterMatches:self requestType:arrayObjects?-101:101];
                    [FireBaseAPICalls captureScreenDetails:COMPANY_CONVERSATION];
                    
                    NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
                    NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID];
                    NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
                    
                    [Utility getMixpanelData:COMPANY_ACTIVITY_CONVERSATION_LISTVIEW setProperties:userName];
                } else {
                    [[ApplicantHelper sharedInstance] getApplicantJobMatches:self requestType:arrayObjects?-101:101];
                    
                    [FireBaseAPICalls captureScreenDetails:APPLICANT_CONVERSATION];
                    
                    NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
                    NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
                    NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
                    
                    [Utility getMixpanelData:APPLICANT_ACTIVITY_CONVERSATION_LISTVIEW setProperties:userName];
                }
            });
        });
    } else {
        arrayObjects = [[NSMutableArray alloc]init];
        arrayObjects = nil;
        [arrayObjects removeAllObjects];
        
        self.segmentController.selectedSegmentIndex = 0;
        
        NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:INTRESTEDLISTARRAY];
        arrayObjects = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
        
        if([arrayObjects count] > 0) {
            self.table_view.hidden = NO;
            self.message_view.hidden = YES;
        } else {
            self.table_view.hidden = YES;
            if (checkFirst == NO)
            self.message_view.hidden = NO;
        }
        
        [self updateUI];
        
        if([Utility isComapany]) {
            [[CompanyHelper sharedInstance] getShortListedProfiles:self requestType:arrayObjects?-350:350];
            
            [FireBaseAPICalls captureScreenDetails:COMPANY_APPLIED];
            NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID];
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            [Utility getMixpanelData:COMPANY_ACTIVITY_LISTVIEW setProperties:userName];
        } else {
            if (checkFirst == YES) {
                [[ApplicantHelper sharedInstance] viewAppliedJobs:self requestType:arrayObjects?-350:350];
                checkFirst = NO;
            } else {
                [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    [self.table_view.pullToRefreshView stopAnimating];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
            }
            
            [FireBaseAPICalls captureScreenDetails:APPLICANT_APPLIED];
            
            NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            [Utility getMixpanelData:APPLICANT_ACTIVITY_LISTVIEW setProperties:userName];
        }
    }
}


- (void)getMessagesWithObject:(NSMutableDictionary *)dictionary {
    [self getAllMessagesWithChannel:[Utility getChannelName:dictionary] isLast:dictionary==self->arrayObjects.lastObject];
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if ([NSThread isMainThread]) {
        [self.table_view.pullToRefreshView stopAnimating];
        [MBProgressHUD hideHUDForView:self.view animated:NO];
    } else {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self.table_view.pullToRefreshView stopAnimating];
            [MBProgressHUD hideHUDForView:self.view animated:NO];
        }];
    }
    
    if (self.isConversationFlag) {
        if((tag == 101|| tag == -101) && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]) {
            dictionary_object = (NSMutableDictionary *)data;
            arrayObjects = [[data valueForKey:@"data"] mutableCopy];
            
            int server_side_count = (int)[arrayObjects count];
            int clint_side_count = (int)[[[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list order by last_update_date DESC"]] count];
            BOOL shouldSyncFromFirebase = NO;
            if(server_side_count > clint_side_count)
            [self subcribeAllChannelsForPush:arrayObjects diff:clint_side_count-server_side_count];
            if (!self.conversationUpdated && arrayObjects.count > 0) {
                shouldSyncFromFirebase = YES;
                if ([NSThread isMainThread]) {
                    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                    });
                }
            }
            for(NSMutableDictionary *dictionary in arrayObjects) {
                [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"delete from conversation_list where channel_name = '%@'  ",[Utility getChannelName:dictionary]]];
                
                NSString *json_object = [Utility convertDictionaryToJSONString:dictionary];
                json_object = [json_object stringByReplacingOccurrencesOfString:@"'" withString:@""];
                
                NSDate *date = [NSDate date];
                
                if(![Utility isComapany])
                date = [Utility getDateWithStringDate:[dictionary valueForKeyPath:@"conversationMatchDate"] withFormat:@"MMM yyyy dd  HH:mm a"];
                else
                date = [Utility getDateWithStringDate:[dictionary valueForKeyPath:@"jobPostId.conversationMatchDate"] withFormat:@"MMM yyyy dd  HH:mm a"];
                
                NSString *userId = [Utility isComapany]?[dictionary valueForKeyPath:@"userId.userId"]:[dictionary valueForKeyPath:@"recruiter.userId"];
                
                [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"insert or replace into conversation_list (channel_name,last_update_date,json_text,un_read_count) VALUES ('%@','%@','%@',%d)",[Utility getChannelName:dictionary],date,json_object,[userId intValue]]];
                if (shouldSyncFromFirebase) {
                    [self getMessagesWithObject:dictionary];
                }
            }
            if (!shouldSyncFromFirebase) {
                [self stopLoading:YES];
            }
        }
    } else {
        if((tag == 350 || tag == -350) && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]) {
            dictionary_object = (NSMutableDictionary *)data;
            
            if ([[dictionary_object valueForKey:@"msg"]isEqualToString:@"ViewAppliedJobs Success"]) {
                [[ApplicantHelper sharedInstance] viewAppliedJobs_External:self requestType:arrayObjects?-200:200];
            } else {
                arrayObjects = [[data valueForKey:@"data"] mutableCopy];
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jobSwipeActionDate" ascending:NO];
                arrayObjects = [[arrayObjects sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
                
                NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:arrayObjects];
                [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:INTRESTEDLISTARRAY];
                
                if([arrayObjects count] > 0) {
                    self.table_view.hidden = NO;
                    self.message_view.hidden = YES;
                } else {
                    self.table_view.hidden = YES;
                    self.message_view.hidden = NO;
                }
                self.skeleton_Image.hidden = YES;
                
                [self updateUI];
            }
            
            [self updateUI];
        } else if(tag == -200|| tag == 200) {
            NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:INTRESTEDLISTARRAY];
            NSMutableArray *arrayObjectsSaved = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
            arrayObjectsSaved = [NSMutableArray array];
            
            if (!arrayObjectsSaved)
            arrayObjectsSaved = [NSMutableArray array];
            
            for (int j=0; j<[[data valueForKey:@"data"]count]; j++)
            {
                BOOL isContain = NO;
                
                NSMutableDictionary *savedDict = [[NSMutableDictionary alloc]init];
                [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"company_ext"] forKey:@"companyName"];
                [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"jobSwipeActionDate"] forKey:@"jobSwipeActionDate"];
                
                NSString *dateStr = [[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"jobSwipeActionDate"];
                NSArray *dateComponents = [dateStr componentsSeparatedByString:@"."];
                if (dateComponents.count > 0 ){
                    NSDate *dateFm = [Utility getDateWithStringDate:[dateComponents objectAtIndex:0] withFormat:@"MMM yyyy dd hh:mm:ss"];
                    if (dateFm) {
                        [savedDict setValue:dateFm forKey:@"jobSwipeActionDate1"];
                    }
                }
                
                [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"jobSwipeActionDate"] forKey:@"jobSwipeActionDate"];
                [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"logo"] forKey:@"logo"];
                [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"title"] forKey:@"title"];
                [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"via"] forKey:@"status"];
                [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"link"] forKey:@"link"];
                [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"jobPostId"] forKey:@"jobPostId"];
                [savedDict setValue:@"1" forKey:@"ext_status"];
                
                for (NSDictionary *dict in arrayObjectsSaved)
                if ([[dict valueForKey:@"jobPostId"] integerValue] == [[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"jobPostId"] integerValue])
                isContain = YES;
                
                if (!isContain)
                [arrayObjectsSaved addObject:savedDict];
            }
            
            for (int j=0; j<[[dictionary_object valueForKey:@"data"]count]; j++)
            {
                BOOL isContain = NO;
                for (NSDictionary *dict in arrayObjectsSaved)
                if ([[dict valueForKey:@"jobPostId"] integerValue] == [[[[dictionary_object valueForKey:@"data"] objectAtIndex:j] valueForKey:@"jobPostId"] integerValue])
                isContain = YES;
                
                if (!isContain)
                [arrayObjectsSaved addObject:[[dictionary_object valueForKey:@"data"] objectAtIndex:j]];
            }
            
            for (int j=0; j<[arrayObjectsSaved count]; j++)
            {
                NSMutableDictionary *jobDictionaryObject = [[arrayObjectsSaved objectAtIndex:j] mutableCopy];
                NSString *dateStr = [jobDictionaryObject valueForKey:@"jobSwipeActionDate"];
                NSArray *dateComponents = [dateStr componentsSeparatedByString:@"."];
                if (dateComponents.count > 0 ) {
                    NSDate *dateFm = [Utility getDateWithStringDate:[dateComponents objectAtIndex:0] withFormat:@"MMM yyyy dd hh:mm:ss"];
                    if (dateFm) {
                        [jobDictionaryObject setValue:dateFm forKey:@"jobSwipeActionDate1"];
                    }
                }
                [arrayObjectsSaved replaceObjectAtIndex:j withObject:jobDictionaryObject];
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jobSwipeActionDate1" ascending:NO];
            arrayObjectsSaved = [[arrayObjectsSaved sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
            
            NSData *dataArray1 = [NSKeyedArchiver archivedDataWithRootObject:arrayObjectsSaved];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray1 forKey:INTRESTEDLISTARRAY];
            
            arrayObjects = arrayObjectsSaved;
            
            if([arrayObjects count] > 0) {
                self.table_view.hidden = NO;
                self.message_view.hidden = YES;
            } else {
                self.table_view.hidden = YES;
                self.message_view.hidden = NO;
            }
            self.skeleton_Image.hidden = YES;
            
            [self updateUI];
            
        }
    }
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag {
    
}

-(void)stopLoading:(BOOL)successful {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] updateUnreadCount];
    });
    [self setConversationUpdated:YES];
    arrayObjects = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list"]];
    checkArray = arrayObjects;
    
    if([arrayObjects count] > 0) {
        self.table_view.hidden = NO;
        self.message_view.hidden = YES;
    } else {
        self.table_view.hidden = YES;
        self.message_view.hidden = NO;
    }
    [self updateUI];
    
    self.skeleton_Image.hidden = YES;
    
}

-(NSDate *)getDateFrom:(NSDictionary *)dictionary {
    NSDate *date = [Utility getDateWithStringDate:[dictionary valueForKey:@"date"] withFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    if(date == nil){
        date = [Utility getDateWithStringDate:[dictionary valueForKey:@"date"] withFormat:@"yyyy-MM-dd HH:mm:ss.zzz"];
    }
    if(date == nil)
    {
        NSString * data = [dictionary valueForKey:@"date"];
        NSString * finalStr = [data stringByReplacingOccurrencesOfString:@"IST" withString:@""];
        date = [Utility getDateWithStringDate:finalStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return date;
}

-(void)didReciveHistoryWithData:(NSNotification *)notification
{
    if(!self.isConversationFlag)
    return;
    [self updateUI];
}

-(void)reloadConversations:(NSNotification *)notifications
{
    self.isConversationFlag = YES;
    [self loadDataFromService];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(IBAction)segmentControllerChange:(id)sender
{
    self.skeleton_Image.hidden = YES;
    
    self.message_view.hidden = YES;
    UISegmentedControl *segmentController = (UISegmentedControl *)sender;
    NSInteger selectedSegment = segmentController.selectedSegmentIndex;
    
    if(selectedSegment == 0)
    {
        //Applied
        self.isConversationFlag = NO;
        
        [self loadDataFromService];
        
        if([Utility isComapany]){//Company
            self.titleLbl.text = @"No interested profiles";
            self.messageLbl.text = @"When you like applicants, you’ll be able to review their profiles here.";
        }else{
            self.titleLbl.text = @"No applied jobs";
            self.messageLbl.text = @"When you apply for jobs, you’ll be able to review details here.";
        }
        
        if (arrayObjects.count !=0)
        {
            if(checkFirstTime == YES)
            {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }];
                checkFirstTime = NO;
            }
            else
            {
                //            NSData * unArchieve = [[NSUserDefaults standardUserDefaults]objectForKey:@"SaveIndex1"];
                //            NSIndexPath * indexValue = [NSKeyedUnarchiver unarchiveObjectWithData:unArchieve];
                //            if (arrayObjects.count >= indexValue.section)
                //            {
                //                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                //                    @try
                //                    {
                //                        [self.table_view scrollToRowAtIndexPath:indexValue atScrollPosition:UITableViewScrollPositionNone animated:NO];
                //                    }
                //                    @catch (NSException *exception)
                //                    {
                //
                //                    }
                //                }];
                //            }
            }
        }
    }
    else
    {
        
        //Conversations
        
        self.isConversationFlag = YES;
        if([Utility isComapany]){ //Comapany
            self.titleLbl.text = @"No new matches";
            self.messageLbl.text = @"Your conversations with matched applicants will appear here.";
        }else{
            self.titleLbl.text = @"No new matches";
            self.messageLbl.text = @"Your conversations with matched recruiters will appear here.";
        }
        
        [self loadDataFromService];
        
        
        if (arrayObjects.count !=0)
        {
            if(checkFirstTime == YES)
            {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }];
                checkFirstTime = NO;
            }
            else{
                
                //                NSData * unArchieve = [[NSUserDefaults standardUserDefaults]objectForKey:@"SaveIndex"];
                //                NSIndexPath * indexValue = [NSKeyedUnarchiver unarchiveObjectWithData:unArchieve];
                //
                //                if (checkArray.count >= indexValue.section)
                //                {
                //                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                //                        @try
                //                        {
                //                            [self.table_view scrollToRowAtIndexPath:indexValue atScrollPosition:UITableViewScrollPositionNone animated:NO];
                //                        }
                //                        @catch (NSException *exception)
                //                        {
                //                        }
                //                    }];
                //                }
            }
        }
    }
    
    [self updateUI];
}

-(IBAction)onClickNotificationChange:(int)flag
{
    if(flag == 0){
        self.isConversationFlag = NO;
        if([Utility isComapany]){//Company
            self.titleLbl.text = @"No interested profiles";
            self.messageLbl.text = @"When you like applicants, you’ll be able to review their profiles here.";
        }else{
            self.titleLbl.text = @"No applied jobs";
            self.messageLbl.text = @"When you apply for jobs, you’ll be able to review details here.";
        }
    }else{
        self.isConversationFlag = YES;
        if([Utility isComapany]){ //Comapany
            self.titleLbl.text = @"No new matches";
            self.messageLbl.text = @"Your conversations with matched applicants will appear here.";
        }else{
            self.titleLbl.text = @"No new matches";
            self.messageLbl.text = @"Your conversations with matched recruiters will appear here.";
        }
    }
    
    self.segmentController.selectedSegmentIndex = flag;
    [self loadDataFromService];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(arrayObjects.count <= 0)
    {
        return 0;
    }
    else{
        return arrayObjects.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isConversationFlag)
    {
        static NSString *cellIdentifier = WRCUSTOM_CONVERSATION_CELL_IDENTIFIER;
        CustomConversationsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:WRCUSTOM_CONVERSATION_CELL owner:self options:nil];
            cell = (CustomConversationsCell *)[topLevelObjects objectAtIndex:0];
        }
        
        NSDictionary *sectionDict = [arrayObjects objectAtIndex:indexPath.section];
        
        NSMutableDictionary *dictionary = [Utility getDictionaryFromString:[sectionDict valueForKey:@"json_text"]];
        
        NSString *count = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_unread_count",[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"channel_name"]]];
        
        if([count intValue] <= 0)
        cell.count_lbl.hidden = YES;
        else{
            cell.count_lbl.hidden = NO;
            cell.count_lbl.text = [NSString stringWithFormat:@"%@",count];
        }
        
        NSString *last_message = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_last_message",[sectionDict valueForKey:@"channel_name"]]];
        
        if (!last_message)
        last_message = @"";
        
        if ([last_message isEqualToString:@""] && [[[dictionary valueForKeyPath:@"experienceMax"]stringValue] isEqualToString: [NSString stringWithFormat:@"-1"]])
        last_message = APP_DEFAULT_MESSAGE;
        
        // Check about the status of the job and conversation
        if([[dictionary valueForKey:@"status"] intValue] == 3)
        {
            if([[[dictionary  valueForKeyPath:@"experienceMax"]stringValue] isEqualToString:[NSString stringWithFormat:@"-1"]])
            {
                if(last_message.length > 0)
                {
                    cell.jobRoleLbl.text = last_message;
                    cell.jobRoleLbl.font = [UIFont fontWithName:GlobalFontRegular size:14];
                }else{
                    cell.jobRoleLbl.font = [UIFont fontWithName:GlobalFontSemibold size:14];
                    NSNumber *expireDays = [[dictionary valueForKey:@"jobPostId"] valueForKey:@"expireDays"];
                    if ([expireDays isKindOfClass:[NSNumber class]] && [expireDays integerValue] <= 0) {
                        cell.jobRoleLbl.text = @"Job Expired";
                        cell.jobRoleLbl.textColor = [UIColor redColor];
                    } else {
                        cell.jobRoleLbl.textColor = [UIColor blackColor];
                        cell.jobRoleLbl.text = @"Start a conversation today!";
                    }
                }
                [cell.jobRoleLbl setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
            }
            else{
                if(last_message.length > 0)
                {
                    cell.jobRoleLbl.text = last_message;
                    cell.jobRoleLbl.font = [UIFont fontWithName:GlobalFontRegular size:14];
                    [cell.jobRoleLbl setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
                }else{
                    cell.jobRoleLbl.font = [UIFont fontWithName:GlobalFontSemibold size:14];
                    cell.jobRoleLbl.text = @"Job Expired";
                    [cell.jobRoleLbl setTextColor:[UIColor colorWithRed:244/255.0 green:78/255.0 blue:75/255.0 alpha:1]];
                }
            }
        }
        else
        {
            [cell.jobRoleLbl setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
            if(last_message.length > 0)
            {
                cell.jobRoleLbl.text = last_message;
                cell.jobRoleLbl.font = [UIFont fontWithName:GlobalFontRegular size:14];
                
            }else{
                cell.jobRoleLbl.font = [UIFont fontWithName:GlobalFontSemibold size:14];
                NSDictionary *jobPostID = [dictionary valueForKey:@"jobPostId"];
                NSNumber *expireDays = nil;
                NSString *expireMessage = nil;
                if ([jobPostID isKindOfClass:[NSDictionary class]]) {
                    expireDays = [jobPostID valueForKey:@"expireDays"];
                    expireMessage = [jobPostID valueForKey:@"expireMessage"];
                } else {
                    expireDays = [dictionary valueForKey:@"expireDays"];
                    expireMessage = [dictionary valueForKey:@"expireMessage"];
                }
                BOOL expired = [expireDays isKindOfClass:[NSNumber class]] && [expireDays integerValue] <= 0;
                BOOL closed = [expireMessage isKindOfClass:[NSString class]] && ![expireMessage isEqualToString:@"JOB NOT EXPIRED!"];
                if (expired || closed) {
                    cell.jobRoleLbl.text = @"Job Expired";
                    cell.jobRoleLbl.textColor = [UIColor redColor];
                } else {
                    cell.jobRoleLbl.textColor = [UIColor blackColor];
                    cell.jobRoleLbl.text = @"Start a conversation today!";
                }
            }
        }
        if([Utility isComapany])
        {
            cell.userNameLbl.text = [NSString stringWithFormat:@"%@ %@",[[dictionary valueForKey:@"userId"] valueForKey:@"firstname"],[[dictionary valueForKey:@"userId"] valueForKey:@"lastname"]];
            //First - last
            cell.jobTitleLbl.text = [NSString stringWithFormat:@"Job - %@",[[dictionary valueForKey:@"jobPostId"] valueForKey:@"title"]];
            
            
            //            NSString *conver_sationmatch_date = [[dictionary valueForKey: @"jobPostId"] valueForKey:@"conversationMatchDate"];
            //            conver_sationmatch_date = [Utility  getStringWithDate:conver_sationmatch_date withOldFormat:@"MMM yyyy dd HH:mm a" newFormat:@"MMM dd"];
            //            cell.jobDateLbl.text = conver_sationmatch_date;
            
            
            NSString *conver_sationmatch_date = [[dictionary valueForKey: @"jobPostId"] valueForKey:@"conversationMatchDate"];
            conver_sationmatch_date = [Utility  getStringWithDate:[Utility getStringWithDate_Compamny:conver_sationmatch_date] withOldFormat:@"dd MMM yyyy hh:mm" newFormat:@"MMM dd"];
            cell.jobDateLbl.text = conver_sationmatch_date;
            
            
            cell.profileImage.hidden = NO;
            
            if(![Utility isNullValueCheck:[dictionary valueForKeyPath:@"userId.pic"]] && [[dictionary valueForKeyPath:@"userId.pic"] length] > 0)
            {
                [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[dictionary valueForKeyPath:@"userId.pic"]]]
                                     placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                              options:SDWebImageRefreshCached];
                cell.profileImage.contentMode = UIViewContentModeScaleAspectFit;
                
            }
            else
            {
                
                [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[dictionary valueForKeyPath:@"userId.picture"]]]
                                     placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                              options:SDWebImageRefreshCached];
            }
            
            //cell.profileImage.placeholderImage = [UIImage imageNamed:@"aplicant_placeholder"];
            cell.profileImage.contentMode = UIViewContentModeScaleAspectFit;
            
        }else
        {
            cell.userNameLbl.text = [dictionary valueForKey:@"title"];
            
            cell.jobTitleLbl.text = [dictionary valueForKeyPath:@"company.companyName"];
            
            
            //            NSString *conver_sationmatch_date = [dictionary  valueForKey:@"conversationMatchDate"];
            //            conver_sationmatch_date = [Utility  getStringWithDate:conver_sationmatch_date withOldFormat:@"MMM yyyy dd HH:mm a" newFormat:@"MMM dd"];
            //            cell.jobDateLbl.text = [NSString stringWithFormat:@"%@",conver_sationmatch_date];
            
            NSString *conver_sationmatch_date = [dictionary  valueForKey:@"conversationMatchDate"];
            conver_sationmatch_date = [Utility  getStringWithDate:[Utility getStringWithDate_Compamny:conver_sationmatch_date] withOldFormat:@"dd MMM yyyy hh:mm" newFormat:@"MMM dd"];
            cell.jobDateLbl.text = conver_sationmatch_date;
            
            
            // cell.profileImage.image = [UIImage imageNamed:@"company_placeholder"];
            //cell.profileImage.placeholderImage = [UIImage imageNamed:@"company_placeholder"];
            cell.profileImage.hidden = NO;
            
            cell.profileImage.contentMode = UIViewContentModeScaleAspectFit;
            
            
            if(![Utility isNullValueCheck:[dictionary valueForKeyPath:@"company.pic"]] && [[dictionary valueForKeyPath:@"company.pic"] length] > 0)
            {
                [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[dictionary valueForKeyPath:@"company.pic"]]]
                                     placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                              options:SDWebImageRefreshCached];            }
            else
            {
                [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[dictionary valueForKeyPath:@"company.picture"]]]
                                     placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                              options:SDWebImageRefreshCached];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Save the indexpath
        NSData *archiver = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
        [[NSUserDefaults standardUserDefaults]setObject:archiver forKey:@"SaveIndex"];
        
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = WRCUSTOM_INTRESTED_CELL_IDENTIFIER;
        CustomIntrestedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:WRCUSTOM_INTRESTED_CELL owner:self options:nil];
            cell = (CustomIntrestedCell *)[topLevelObjects objectAtIndex:0];
        }
        
        if([Utility isComapany])
        {
            cell.userTitleLbl.text = [NSString stringWithFormat:@"%@ (%@)",[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"userId.firstname"],[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"userId.userJobTitle"] ] ;
            cell.jobTitleLbl.text = [NSString stringWithFormat:@"Job - %@",[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"jobPostId.title"]];
            
            
            //            NSString *conver_sationmatch_date = [[arrayObjects objectAtIndex:indexPath.section]  valueForKeyPath:@"jobPostId.candidateJobActionDate"];
            //            conver_sationmatch_date = [Utility  getStringWithDate:[Utility getStringWithDate_Compamny:conver_sationmatch_date] withOldFormat:@"dd MMM yyyy hh:mm" newFormat:@"MMM dd"];
            //            cell.jobDateLbl.text = conver_sationmatch_date;
            
            
            NSString *conver_sationmatch_date = [[arrayObjects objectAtIndex:indexPath.section]valueForKeyPath:@"jobPostId.candidateJobActionDate"];
            conver_sationmatch_date = [Utility  getStringWithDate:[Utility getStringWithDate_Compamny:conver_sationmatch_date] withOldFormat:@"dd MMM yyyy hh:mm" newFormat:@"MMM dd"];
            cell.jobDateLbl.text = conver_sationmatch_date;
            
            
            NSString* formattedNumber = [NSString stringWithFormat:@"%.1f years", [[[arrayObjects objectAtIndex:indexPath.section]valueForKeyPath:@"userId.totalExperienceText"]floatValue]];
            cell.expLabel.text = [[arrayObjects objectAtIndex:indexPath.section]valueForKeyPath:@"userId.totalExperienceText"];
            
            cell.profileImage.hidden = NO;
            
            //  cell.profileImage.image = [UIImage imageNamed:@"aplicant_placeholder"];
            cell.profileImage.contentMode = UIViewContentModeScaleAspectFit;
            
            if(![Utility isNullValueCheck:[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"userId.picture"]] && [[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"userId.picture"] length] > 0){
                
                [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"userId.picture"]]]
                                     placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                              options:SDWebImageRefreshCached];
            }else{
                [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"userId.pic"]]]
                                     placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                              options:SDWebImageRefreshCached];
            }
            //            [cell.profileImage setImage:[UIImage imageNamed:@"aplicant_placeholder"]];
            cell.backGroundView.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            if ([[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"ext_status"]isEqualToString:@"1"])
            {
                cell.userTitleLbl.text =[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"title"] ;
                cell.jobTitleLbl.text = [[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"companyName"];
                
                NSString *conver_sationmatch_date = [[arrayObjects objectAtIndex:indexPath.section]valueForKey:@"jobSwipeActionDate"];
                conver_sationmatch_date = [Utility  getStringWithDate:[Utility getStringWithDate1:conver_sationmatch_date] withOldFormat:@"dd MMM yyyy hh:mm:ss" newFormat:@"MMM dd"];
                cell.jobDateLbl.text = conver_sationmatch_date;
                
                
                cell.expLabel.textColor = UIColorFromRGB(0x6a6a6a);
                cell.expLabel.text= [NSString stringWithFormat:@"Job via %@",[[arrayObjects objectAtIndex:indexPath.section]  valueForKey:@"status"]];
                
                NSMutableAttributedString *text =[[NSMutableAttributedString alloc]initWithAttributedString: cell.expLabel.attributedText];
                
                if ([[[arrayObjects objectAtIndex:indexPath.section]valueForKey:@"status"] isEqualToString:@"indeed"]) {
                    [text addAttribute:NSForegroundColorAttributeName
                                 value:UIColorFromRGB(0x1D5AF1)
                                 range:NSMakeRange(8, cell.expLabel.text.length - 8)];
                }
                else if ([[[arrayObjects objectAtIndex:indexPath.section]  valueForKey:@"status"] isEqualToString:@"monster"]) {
                    [text addAttribute:NSForegroundColorAttributeName
                                 value:UIColorFromRGB(0x534698)
                                 range:NSMakeRange(8, cell.expLabel.text.length - 8)];
                }
                else if ([[[arrayObjects objectAtIndex:indexPath.section]  valueForKey:@"status"] isEqualToString:@"naukri"]) {
                    [text addAttribute:NSForegroundColorAttributeName
                                 value:UIColorFromRGB(0x25A1DD)
                                 range:NSMakeRange(8, cell.expLabel.text.length - 8)];
                }
                else if ([[[arrayObjects objectAtIndex:indexPath.section]  valueForKey:@"status"] isEqualToString:@"timesJob"])
                {
                    
                    text = [[NSMutableAttributedString alloc]initWithAttributedString: cell.expLabel.attributedText];
                    
                    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x000000) range:NSMakeRange(8,cell.expLabel.text.length - 8)];
                    
                    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFF0004) range:NSMakeRange(13,2)];
                }
                [cell.expLabel setAttributedText: text];
                cell.expLabel.font = [UIFont fontWithName:GlobalFontRegular size:14];
                cell.profileImage.hidden = NO;
                
                if (![[[arrayObjects objectAtIndex:indexPath.section]  valueForKey:@"logo"]isEqualToString:@""]) {
                    [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"logo"]]]
                                         placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                                  options:SDWebImageRefreshCached];
                }
                else
                {
                    cell.profileImage.image = [UIImage imageNamed:@"company_placeholder"];
                }
                cell.backGroundView.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                if([[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==1||[[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==2||[[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==3)
                {
                    cell.userTitleLbl.text =[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"title"] ;
                    cell.jobTitleLbl.text = [[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"company.companyName"];
                    
                    
                    NSString *conver_sationmatch_date = [[arrayObjects objectAtIndex:indexPath.section]valueForKey:@"jobSwipeActionDate"];
                    conver_sationmatch_date = [Utility  getStringWithDate:[Utility getStringWithDate1:conver_sationmatch_date] withOldFormat:@"dd MMM yyyy hh:mm:ss" newFormat:@"MMM dd"];
                    cell.jobDateLbl.text = conver_sationmatch_date;
                    
                    
                    if([[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==2)
                    {
                        cell.expLabel.text =@"Applied";
                        [cell.expLabel setTextColor:[UIColor colorWithRed:51/255.0 green:122/255.0 blue:183/255.0 alpha:1]];
                        cell.expLabel.font = [UIFont fontWithName:GlobalFontRegular size:14];
                    }
                    else if([[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==1)
                    {
                        cell.expLabel.text =@"Pending";
                        [cell.expLabel setTextColor:[UIColor colorWithRed:51/255.0 green:122/255.0 blue:183/255.0 alpha:1]];
                        cell.expLabel.font = [UIFont fontWithName:GlobalFontRegular size:14];
                    }
                    else if([[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"status"]intValue] ==3)
                    {
                        cell.expLabel.text =@"Job Expired";
                        [cell.expLabel setTextColor:[UIColor colorWithRed:244/255.0 green:78/255.0 blue:75/255.0 alpha:1]];
                        cell.expLabel.font = [UIFont fontWithName:GlobalFontSemibold size:14];
                    }
                    
                    cell.profileImage.hidden = NO;
                    
                    cell.profileImage.contentMode = UIViewContentModeScaleAspectFit;
                    
                    if(![Utility isNullValueCheck:[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"company.picture"]] && [[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"company.picture"] length] > 0)
                    {
                        [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"company.picture"]]]
                                             placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                                      options:SDWebImageRefreshCached];
                    }else{
                        [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[[arrayObjects objectAtIndex:indexPath.section] valueForKeyPath:@"company.pic"]]]
                                             placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                                      options:SDWebImageRefreshCached];
                    }
                    cell.backGroundView.backgroundColor = [UIColor whiteColor];
                }
                else
                {
                    self.table_view.hidden = YES;
                    self.message_view.hidden = NO;
                }
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Save the indexpath
        NSData *archiver = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
        [[NSUserDefaults standardUserDefaults]setObject:archiver forKey:@"SaveIndex1"];
        
        return cell;
    }
}

-(NSString *)getUnreadCountFromDatabase:(NSMutableDictionary *)dictionary
{
    NSMutableArray *array1 =  [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select msg from chat_table where channel_name = '%@' and is_message_read = 1",[dictionary valueForKey:@"channel_name"]]];
    return [NSString stringWithFormat:@"%lu",(unsigned long)[array1 count]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isConversationFlag){
        
        if ([Utility isComapany]) {
            
            
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:RECRUITER_REGISTRATION_ID];
            
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            
            [Utility getMixpanelData:COMPANY_ACTIVITY_CONVERSATION_VIEWDETAIL setProperties:userName];
        }
        else
        {
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:APPLICANT_REGISTRATION_ID];
            
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            
            [Utility getMixpanelData:APPLICANT_ACTIVITY_CONVERSATION_VIEWDETAIL setProperties:userName];
            
        }
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRConversationViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRCONVERSATION_VIEWCONTROLLER_IDENTIFIER];
        cardObject.hidesBottomBarWhenPushed = YES;
        NSMutableDictionary *dictionary = [Utility getDictionaryFromString:[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"json_text"]];
        cardObject.object_dictionary = dictionary;
        [self.navigationController pushViewController:cardObject animated:YES];
        return;
    }
    
    if([Utility isComapany]){
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:COMPANY_ACTIVITY_DETAILVIEW setProperties:userName];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRCardDetailsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRCARD_DETAILS_VIEW_CONTROLLER_IDENTIFIER];
        NSMutableDictionary *temp_object = [[NSMutableDictionary alloc] initWithCapacity:0];
        [temp_object addEntriesFromDictionary:[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"jobPostId"]];
        [temp_object addEntriesFromDictionary:[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"userId"]];
        cardObject.profile_dictionary = temp_object;
        cardObject.hidesBottomBarWhenPushed = YES;
        cardObject.hideButtomBar = YES;
        cardObject.viewingInterestedProfileDetail = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:cardObject animated:YES completion:nil];
        });
    }
    else
    {
        if ([[[arrayObjects objectAtIndex:indexPath.section] valueForKey:@"ext_status"]isEqualToString:@"1"])
        {
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            LoadOtherJobsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:@"LoadOtherJobsViewController"];
            cardObject.webLink =[[arrayObjects objectAtIndex:indexPath.section]valueForKey:@"link"];
            cardObject.titleStr =[[arrayObjects objectAtIndex:indexPath.section]valueForKey:@"title"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:cardObject animated:YES completion:nil];
            });
            return;
        }
        else
        {
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:APPLICANT_REGISTRATION_ID];
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            [Utility getMixpanelData:APPLICANT_ACTIVITY_VIEWDETAIL setProperties:userName];
            
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
            WRJobCardDetailsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRJOB_CARD_DETAILS_VIEW_CONTROLLER];
            cardObject.hideButtomBar = YES;
            cardObject.profile_dictionary = [arrayObjects objectAtIndex:indexPath.section];
            cardObject.hidesBottomBarWhenPushed = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:cardObject animated:YES completion:nil];
            });
        }
    }
}

-(void)subcribeAllChannelsForPush:(NSMutableArray *)array diff:(int)diff
{
    for(int i = 0; i < diff; i++){
        NSMutableDictionary *dictionary = [array objectAtIndex:i];
        NSString *channel_name = @"";
        if([Utility isComapany]){
            //Channel name 83174
            channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[dictionary valueForKeyPath:@"jobPostId.jobPostId"],[dictionary  valueForKeyPath:@"userId.userId"]];
        }else{
            //Channel name
            channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[dictionary  valueForKeyPath:@"jobPostId"],[[NSUserDefaults standardUserDefaults] valueForKeyPath:APPLICANT_REGISTRATION_ID]];
        }
        [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", channel_name]];
        
    }
}
-(void)navigateToConverstaionScreenOnReciveMatch:(NSMutableDictionary *)dictionary
{
    self.isConversationFlag = YES;
    double delayInSeconds = 1.0;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.isConversationFlag = YES;
        self.segmentController.selectedSegmentIndex = 1;
        
        arrayObjects =  [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list"]];
        
        [self updateUI];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRConversationViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRCONVERSATION_VIEWCONTROLLER_IDENTIFIER];
        cardObject.hidesBottomBarWhenPushed = YES;
        cardObject.object_dictionary = dictionary;
        [self.navigationController pushViewController:cardObject animated:NO];
    });
}

-(void)onFCMNotificationClicked:(NSDictionary *)notification
{
    self.isConversationFlag = YES;
    self.segmentController.selectedSegmentIndex = 1;
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    NSString *channel_name = [notification valueForKey:@"gcm.notification.channel"];
    if(channel_name == nil)
    channel_name = [notification valueForKey:@"channel"];
    
    arrayObjects = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list where channel_name = '%@'  order by last_update_date DESC",channel_name]];
    
    if([arrayObjects count] <= 0)
    return;
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRConversationViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRCONVERSATION_VIEWCONTROLLER_IDENTIFIER];
    cardObject.hidesBottomBarWhenPushed = YES;
    cardObject.object_dictionary = [Utility getDictionaryFromString:[[arrayObjects objectAtIndex:0] valueForKey:@"json_text"]];;
    [self.navigationController pushViewController:cardObject animated:NO];
}

-(void)updateUI
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *arrayObjects1 =  [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list order by last_update_date DESC"]];
        NSInteger unreadConversations = 0;
        
        for(NSDictionary *dictionary_object1 in arrayObjects1){
            NSString *count = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_unread_count",[dictionary_object1 valueForKey:@"channel_name"]]];
            if([count intValue] > 0)
            unreadConversations ++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(unreadConversations > 0){
                [[[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%ld",(long)unreadConversations]];
                [self.segmentController setTitle:[NSString  stringWithFormat:@"Conversations (%ld)",(long)unreadConversations]   forSegmentAtIndex:1];
                
                for (UIView *tabBarButton in self.navigationController.tabBarController.tabBar.subviews)
                {
                    for (UIView *badgeView in tabBarButton.subviews)
                    {
                        NSString *className = NSStringFromClass([badgeView class]);
                        if ([className rangeOfString:@"BadgeView"].location != NSNotFound)
                        {
                            badgeView.layer.transform = CATransform3DIdentity;
                            badgeView.layer.transform = CATransform3DMakeTranslation(-8.0, 0.0, 1.0);
                        }
                    }
                }
            } else {
                [[[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:nil];
                [self.segmentController setTitle:@"Conversations"  forSegmentAtIndex:1];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table_view reloadData];
            });
        });
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table_view reloadData];
    });
}


- (void)getAllMessagesWithChannel:(NSString *)channel isLast:(BOOL)isLast {
    FIRDatabaseReference *chatReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"/channels/%@",channel]];
    [chatReference keepSynced:YES];
    [chatReference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         NSDictionary *dictionary_object = (NSDictionary *)snapshot.value;
         if ([[dictionary_object class] isSubclassOfClass:[NSNull class]]) {
             [chatReference removeAllObservers];
             if (isLast) {
                 [self stopLoading:YES];
             }
             return;
         }
         
         NSArray *keys = dictionary_object.allKeys;
         BOOL shouldStop = false;
         if ([keys containsObject:@"-LFm0Yv7II7p8hQksd1q"]) {
             shouldStop = true;
         }
         for (NSString *key in keys) {
             
             if (shouldStop) {
                 NSLog(@"%@", key);
             }
             
             NSDictionary *dict = [dictionary_object valueForKey:key];
             NSString *message = [dict valueForKey:@"msg"];
             
             if ([message isEqualToString:APP_DEFAULT_MESSAGE])
             continue;
             
             message = [message stringByReplacingOccurrencesOfString:@"\'" withString:@""];
             message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@""];
             
             [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"insert or replace into chat_table (channel_name,date,from_id,to_id,msg_id,msg,chat_type,media_type) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')",channel,[dict valueForKey:@"date"],[dict valueForKey:@"from_id"],[dict valueForKey:@"to_id"],[dict valueForKey:@"msg_id"],message,[dict valueForKey:@"chat_type"],[dict valueForKey:@"media_type"]]];
         }
         
         NSMutableArray *messages = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from chat_table where channel_name = '%@'  order by date",channel]];
         
         NSArray *arraySorted = [messages sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
             NSDate *d1 = [self getDateFrom: obj1];
             NSDate *d2 = [self getDateFrom: obj2];
             return [d1 compare: d2];
         }];
         
         if (arraySorted.count>0) {
             [[NSUserDefaults standardUserDefaults] setObject:[arraySorted.lastObject valueForKey:@"msg"] forKey:[NSString stringWithFormat:@"%@_last_message",channel]];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         
         NSString *reg_id = [Utility isComapany]?[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
         
         FIRDatabaseReference *databaseReference = [[FIRDatabase database] reference];
         [[databaseReference child:[NSString stringWithFormat:@"%@_%@",channel,reg_id]] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
             
             id value = snapshot.value;
             
             if ([value class] == [NSNull class])
             value = nil;
             
             if (value)
             {
                 NSInteger last_scene_count = [value integerValue];
                 NSInteger final_count = messages.count - last_scene_count;
                 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)final_count] forKey:[NSString stringWithFormat:@"%@_unread_count",channel]];
                 [[NSUserDefaults standardUserDefaults] synchronize];
             }
             
             if (isLast)
             [self stopLoading:YES];
             
             [databaseReference removeAllObservers];
         }];
         [chatReference removeAllObservers];
         [self.table_view reloadData];
     }];
}

/******************************
 HANDLE UNREAD LOGIC WITH FCM
 *******************************/
/*- (void)getAllMessagesWithChannel:(NSString *)channel isLast:(BOOL)isLast {
 FIRDatabaseReference *chatReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"/channels/%@",channel]];
 [chatReference keepSynced:YES];
 [chatReference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
 
 // Reset Instance
 NSDictionary *dictionary_object = (NSDictionary *)snapshot.value;
 [self resetDicttionary:chatReference dictionary_object:dictionary_object isLast:isLast];
 
 //Save In DB
 //        NSArray *keys = dictionary_object.allKeys;
 [self saveInDB:channel dictionary_object:dictionary_object];
 
 //Get From DB and Sort messages
 NSMutableArray * messages = [self getFromDBandSortmessages:channel];
 
 // Get RG_ID
 NSString * reg_id = [self getRGID];
 
 //Handle Unread Count
 [self requestFirebaseChildToHandleUnreadCount:channel isLast:isLast messages:messages reg_id:reg_id];
 
 [chatReference removeAllObservers];
 
 } withCancelBlock:^(NSError * _Nonnull error) {
 NSLog(@"%@",error.localizedDescription);
 }];
 }
 
 - (void)requestFirebaseChildToHandleUnreadCount:(NSString *)channel isLast:(BOOL)isLast messages:(NSMutableArray *)messages reg_id:(NSString *)reg_id {
 FIRDatabaseReference *databaseReference = [[FIRDatabase database] reference];
 [[databaseReference child:[NSString stringWithFormat:@"%@_%@",channel,reg_id]] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
 
 id value = snapshot.value;
 if ([value class] == [NSNull class])
 value = nil;
 [self handleUnReadCount:channel messages:messages value:value];
 
 if (isLast)
 [self stopLoading:YES];
 
 [databaseReference removeAllObservers];
 } withCancelBlock:^(NSError * _Nonnull error) {
 NSLog(@"%@",error.localizedDescription);
 }];
 }
 
 - (void)resetDicttionary:(FIRDatabaseReference *)chatReference dictionary_object:(NSDictionary *)dictionary_object isLast:(BOOL)isLast {
 if ([[dictionary_object class] isSubclassOfClass:[NSNull class]]) {
 [chatReference removeAllObservers];
 if (isLast) {
 [self stopLoading:YES];
 }
 return;
 }
 }
 
 - (void)saveInDB:(NSString *)channel dictionary_object:(NSDictionary *)dictionary_object {
 NSArray *keys = dictionary_object.allKeys;
 
 for (NSString *key in keys) {
 NSDictionary *dict = [dictionary_object valueForKey:key];
 NSString *message = [dict valueForKey:@"msg"];
 
 if ([message isEqualToString:APP_DEFAULT_MESSAGE])
 continue;
 
 message = [message stringByReplacingOccurrencesOfString:@"\'" withString:@""];
 message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@""];
 
 [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"insert or replace into chat_table (channel_name,date,from_id,to_id,msg_id,msg,chat_type,media_type) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')",channel,[dict valueForKey:@"date"],[dict valueForKey:@"from_id"],[dict valueForKey:@"to_id"],[dict valueForKey:@"msg_id"],message,[dict valueForKey:@"chat_type"],[dict valueForKey:@"media_type"]]];
 }
 }
 
 - (NSMutableArray *)getFromDBandSortmessages:(NSString *)channel {
 NSMutableArray *messages = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from chat_table where channel_name = '%@'  order by date",channel]];
 NSArray *arraySorted = [messages sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
 NSDate *d1 = [self getDateFrom: obj1];
 NSDate *d2 = [self getDateFrom: obj2];
 return [d1 compare: d2];
 }];
 if (arraySorted.count>0) {
 [[NSUserDefaults standardUserDefaults] setObject:[arraySorted.lastObject valueForKey:@"msg"] forKey:[NSString stringWithFormat:@"%@_last_message",channel]];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 return messages;
 }
 
 - (NSString *)getRGID {
 NSString *reg_id = [Utility isComapany]?[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
 return reg_id;
 }
 
 - (void)handleUnReadCount:(NSString *)channel messages:(NSMutableArray *)messages value:(id)value {
 if (value) {
 NSInteger last_scene_count = [value integerValue];
 NSInteger final_count = messages.count - last_scene_count;
 
 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)final_count] forKey:[NSString stringWithFormat:@"%@_unread_count",channel]];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 }
 */
/******************************
 HANDLE UNREAD LOGIC WITH FCM
 *******************************/

@end


