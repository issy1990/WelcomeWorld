
#import "WRConversationViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface WRConversationViewController ()<ChatManagerDelegate,HTTPHelper_Delegate>
{
    NSMutableArray *fireBaseArray;
    
    NSString *channel_name;
    UILabel *isTypinglabel;
    NSString *subTitleString;
    
    NSTimer *timer;
    
    NSString *date1;
    NSString *uniqNumber;
    NSString *jobString1;
    NSString *screen_title;
    NSString *screen_sub_title;
    NSString *device_type;
    NSMutableArray *messages;
    
    BOOL moreClicked;
    BOOL loadFirstTime;
    IBOutlet UIView * myView;
}

@end

@implementation WRConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    AppDelegate *app_delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate clearAllNotifications];
    
    if([Utility isComapany])
    {
        app_delegate.current_regId = [self.object_dictionary valueForKeyPath:@"userId.regdId"];
        app_delegate.current_user_id = [self.object_dictionary valueForKeyPath:@"userId.userId"];
        device_type = [self.object_dictionary valueForKeyPath:@"userId.deviceType"];
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:COMPANY_ACTIVITY_CONVERSATION_CHATSCREEN setProperties:userName];
    }
    else
    {
        app_delegate.current_regId = [self.object_dictionary valueForKeyPath:@"recruiter.regdId"];
        app_delegate.current_user_id = [self.object_dictionary valueForKeyPath:@"recruiter.userId"];
        device_type = [self.object_dictionary valueForKeyPath:@"recruiter.deviceType"];
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        [Utility getMixpanelData:APPLICANT_ACTIVITY_CONVERSATION_CHATSCREEN setProperties:userName];
    }
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:GlobalFontRegular size:16.0f];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:62/255.0f green:187/255.0f blue:100/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"Source Sans Pro Semibold" size:17.0] forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_button"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = barBtn;
    
    UIBarButtonItem *barBtn1 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"wr_more"] style:UIBarButtonItemStylePlain target:self action:@selector(detailButtonAction:)];
    self.navigationItem.rightBarButtonItem = barBtn1;
    
    screen_title = @"";
    screen_sub_title = @"";
    
    if([Utility isComapany])
    {
        //Channel name 83174
        channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[self.object_dictionary valueForKeyPath:@"jobPostId.jobPostId"],[self.object_dictionary valueForKeyPath:@"userId.userId"]];
        
        self.senderId = [[CompanyHelper sharedInstance].params valueForKey:@"email"]; // Company id or requrutor id
        self.senderDisplayName  = [NSString stringWithFormat:@"%@ %@",[[CompanyHelper sharedInstance].params valueForKey:FIRST_NAME_KEY],[[CompanyHelper sharedInstance].params valueForKey:LAST_NAME_KEY]];
        
        screen_title = [NSString stringWithFormat:@"%@ %@",[self.object_dictionary valueForKeyPath:@"userId.firstname"],[self.object_dictionary valueForKeyPath:@"userId.lastname"]];
        screen_sub_title = [self.object_dictionary valueForKeyPath:@"userId.userJobTitle"];
    }
    else
    {
        //Channel name
        channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[self.object_dictionary valueForKeyPath:@"jobPostId"],[[NSUserDefaults standardUserDefaults] valueForKeyPath:APPLICANT_REGISTRATION_ID]];
        
        self.senderId = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"email"]; // Company id or requrutor id
        self.senderDisplayName  = [NSString stringWithFormat:@"%@ %@",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:FIRST_NAME_KEY],[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:LAST_NAME_KEY]];
        
        if ([[self.object_dictionary valueForKeyPath:@"recruiter.jobRoleId"] intValue]-1 == -1 )
        {
            NSString *job_role_name = [CompanyHelper getJobRoleIdWithIndex:1 parantKey:@"jobRoles" childKey:@"jobRoleName"];
            
            screen_title = [NSString stringWithFormat:@"%@ %@",[self.object_dictionary valueForKeyPath:@"recruiter.firstname"],[self.object_dictionary valueForKeyPath:@"recruiter.lastname"]];
            
            NSLog(@"screen title: %@", screen_title);
            
            if([screen_title isEqualToString:@"(null) (null)"] ){
                screen_title = [NSString stringWithFormat:@"Manikanth Challa"];
            }
            screen_sub_title =[NSString stringWithFormat:@"%@",job_role_name];
        }
        else
        {
            NSString *job_role_name = [CompanyHelper getJobRoleIdWithIndex:[[self.object_dictionary valueForKeyPath:@"recruiter.jobRoleId"] intValue]-1 parantKey:@"jobRoles" childKey:@"jobRoleName"];
            
            screen_title = [NSString stringWithFormat:@"%@ %@",[self.object_dictionary valueForKeyPath:@"recruiter.firstname"],[self.object_dictionary valueForKeyPath:@"recruiter.lastname"]];
            
            NSLog(@"screen title: %@", screen_title);
            
            if([screen_title isEqualToString:@"(null) (null)"] ){
                screen_title = [NSString stringWithFormat:@"Manikanth Challa"];
            }
            screen_sub_title =[NSString stringWithFormat:@"%@",job_role_name];
        }
    }
    
    subTitleString = screen_sub_title;
    UIView *title_view = [Utility getConversationTitleViewWithTitle:screen_title subTitle:screen_sub_title];
    isTypinglabel = (UILabel *)[title_view viewWithTag:10];
    self.navigationItem.titleView = title_view;
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.showLoadEarlierMessagesHeader = YES;
    fireBaseArray  = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.inputToolbar.contentView.textView.delegate = self;
    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:GlobalFontRegular size:16.0f];
    
    // For RTL language support
    self.inputToolbar.contentView.leftBarButtonItem =  [JSQMessagesToolbarButtonFactory defaultAccessoryButtonItem];
    self.inputToolbar.contentView.leftBarButtonItem =  nil;
    
    UIButton *send_btn = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
    send_btn.titleLabel.font = [UIFont fontWithName:GlobalFontSemibold size:16.0f];
    send_btn.titleLabel.textColor = [UIColor colorWithRed:51/255.0f green:122/255.0f blue:183/255.0f alpha:1.0f];
    self.inputToolbar.contentView.rightBarButtonItem = send_btn;
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"ChatMessagesd"];
    
    BOOL isFirstTimeMessageDissplayed = [[NSUserDefaults standardUserDefaults] valueForKey:@"isFirstMessageDissplayed"];
    // The library will call the correct selector for each button, based on this value
    
    if(!isFirstTimeMessageDissplayed && [savedValue isEqualToString:@"View Message"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isFirstMessageDissplayed"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Main" forKey:@"ChatMessagesd"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString * statusValue;
    if(![Utility isComapany])
    {
        statusValue =[self.object_dictionary valueForKeyPath:@"status"];
    }
    else{
        statusValue =[self.object_dictionary valueForKeyPath:@"jobPostId.status"];
    }
    
    // If Job is closed then either user or employee cant send the messages to each other
    if([statusValue intValue] == 3) {
        if([[[self.object_dictionary  valueForKeyPath:@"experienceMax"]stringValue] isEqualToString:[NSString stringWithFormat:@"-1"]]) {
            self.inputToolbar.sendButtonOnRight = YES;
            self.inputToolbar.contentView.textView.userInteractionEnabled = YES;
        } else {
            self.inputToolbar.contentView.rightBarButtonItem =  nil;
            self.inputToolbar.sendButtonOnRight = NO;
            self.inputToolbar.contentView.textView.text =@"You can't send messages to this user because the job is no longer active.";
            self.inputToolbar.contentView.textView.userInteractionEnabled = NO;
            self.inputToolbar.contentView.textView.layer.cornerRadius = 0.0;
            self.inputToolbar.contentView.textView.layer.borderWidth = 0.0;
            self.inputToolbar.contentView.textView.layer.borderColor = [UIColor clearColor].CGColor;
            self.inputToolbar.contentView.textView.backgroundColor = [UIColor clearColor];
            self.inputToolbar.contentView.textView.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:100];
        }
    } else {
        self.inputToolbar.sendButtonOnRight = YES;
        self.inputToolbar.contentView.textView.userInteractionEnabled = YES;
    }
    [Utility setThescreensforiPhonex:myView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(moreClicked){
        moreClicked = NO;
        return;
    }
    
    jobString1 = @"";
    self.navigationController.navigationBarHidden = NO;
    
    if([Utility isComapany])
    [FireBaseAPICalls captureScreenDetails:COMPANY_CHAT];
    else
    [FireBaseAPICalls captureScreenDetails:APPLICANT_CHAT];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FirstTimeLoad"]==NO)
    {
        [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior context:NULL];
    }
    [self loadMessages];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(moreClicked)
    return;
    
    [[NSUserDefaults standardUserDefaults] setObject:[[messages lastObject]  text] forKey:[NSString stringWithFormat:@"%@_last_message",channel_name]];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self updateTotalMessageCountToFirebase:messages.count];
    
    [[ChatManager sharedManager] clearAllAbserver];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.current_channel = nil;
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FirstTimeLoad"]==NO)
    {
        [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"FirstTimeLoad"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)messagesDidUpdate:(JSQMessage*)message
{
    //Run UI Updates
    [messages addObject:message];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    messages = [[messages sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    [self finishReceivingMessage];
    [self updateTotalMessageCountToFirebase:messages.count];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)updateTotalMessageCountToFirebase:(NSUInteger)count
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%@_unread_count",channel_name]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *reg_id = [Utility isComapany]?[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
    
    FIRDatabaseReference *databaseReference = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"%@_%@",channel_name,reg_id]];
    [databaseReference setValue:@(count)];
}

-(void)loadMessages {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    messages = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *arrayObjects = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from chat_table where channel_name = '%@'  order by date",channel_name]];
        
        NSMutableArray *localMessages = [[NSMutableArray alloc]init];
        for (NSMutableDictionary *dictionary in arrayObjects) {
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
            
            JSQMessage *object_message = [[JSQMessage alloc] initWithSenderId:[dictionary valueForKey:@"from_id"] senderDisplayName:[dictionary valueForKey:@"msg_id"] date:date text:[dictionary valueForKey:@"msg"]];
            
            [localMessages addObject:object_message];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        localMessages = [[localMessages sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
        
        [self updateTotalMessageCountToFirebase:localMessages.count];
        [ChatManager sharedManager].channel_name = channel_name;
        [ChatManager sharedManager].delegate = self;
        [[ChatManager sharedManager] connect];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.current_channel = channel_name;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            messages = localMessages;
            if([[[self.object_dictionary valueForKeyPath:@"experienceMax"]stringValue] isEqualToString:[NSString stringWithFormat:@"-1"]]) {
                [self addDefultMessageFromWorkRuitAndDissableSendButton];
            }
            [self.collectionView reloadData];
            [self scrollToBottomAnimated:NO];
        });
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.collectionView reloadData];
		NSLog(@"test real convo");
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(IBAction)backButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOADCONVERSATIONLIST object:nil userInfo:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(UIView *)getHeaderView
{
    UIView *view_1 = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width+80, 100)];
    [view_1 setBackgroundColor:[UIColor whiteColor]];
    view_1.layer.borderWidth = 0;
    view_1.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:0.4].CGColor;
    
    UILabel * lineLbl =[[UILabel alloc]initWithFrame:CGRectMake(0, 99, self.view.frame.size.width, 1)];
    lineLbl.backgroundColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:0.4];
    [view_1 addSubview:lineLbl];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 25, 50, 50)];
    imageView.image = [UIImage imageNamed:@"aplicant_placeholder"];
    
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    [view_1 addSubview:imageView];
    
    NSString *nameString = @"";
    NSString *jobString = @"";
    
    if([Utility isComapany])
    {
        nameString = [NSString stringWithFormat:@"%@ %@",[self.object_dictionary valueForKeyPath:@"userId.firstname"],[self.object_dictionary valueForKeyPath:@"userId.lastname"]];
        jobString = [NSString stringWithFormat:@"Matched for %@ ",[self.object_dictionary valueForKeyPath:@"jobPostId.title"]];
        // imageView.image = [UIImage imageNamed:@"aplicant_placeholder"];
        
        if(![Utility isNullValueCheck:[self.object_dictionary valueForKeyPath:@"userId.pic"]] && [[self.object_dictionary valueForKeyPath:@"userId.pic"] length] > 0){
            [imageView sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.object_dictionary valueForKeyPath:@"userId.pic"]]]
                         placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                  options:SDWebImageRefreshCached];
        }else{
            [imageView sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.object_dictionary valueForKeyPath:@"userId.picture"]]]
                         placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                  options:SDWebImageRefreshCached];
        }
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }else{
        nameString = [self.object_dictionary valueForKeyPath:@"recruiter.recruiterCompanyName"];
        jobString = [NSString stringWithFormat:@"Job - %@",[self.object_dictionary valueForKeyPath:@"title"]];
        if ([jobString isEqualToString: @"Job - (null)" ] || [jobString isEqualToString: @"Job -  " ])  {
            jobString = [NSString stringWithFormat:@"Job - Hello From Workruit"];
            nameString = [NSString stringWithFormat:@"Workruit"];
            jobString1 = [NSString stringWithFormat:@"Hello From Workruit"];
        }
        
        NSLog(@"my string:%@",jobString);
        // imageView.image = [UIImage imageNamed:@"company_placeholder"];
        
        if(![Utility isNullValueCheck:[self.object_dictionary valueForKeyPath:@"company.pic"]] && [[self.object_dictionary valueForKeyPath:@"company.pic"] length] > 0){
            [imageView sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.object_dictionary valueForKeyPath:@"company.pic"]]]
                         placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                  options:SDWebImageRefreshCached];
        }else{
            [imageView sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.object_dictionary valueForKeyPath:@"company.picture"]]]
                         placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                  options:SDWebImageRefreshCached];
        }
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:[Utility isComapany]?@"View Resume":@"View Job" forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromRGB(0x337ab7) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:GlobalFontSemibold size:14.0f];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setFrame:CGRectMake(100, 60, 150, 25)];
    [btn addTarget:self action:@selector(viewResume:) forControlEvents:UIControlEventTouchUpInside];
    [view_1 addSubview:btn];
    int y_value = 0;
    if([Utility isComapany] && [[Utility trim:[self.object_dictionary valueForKeyPath:@"userId.resume"]] length] <= 0){
        btn.hidden = YES;
        y_value = 10;
    }
    
    UILabel *labelOne = [[UILabel alloc] initWithFrame:CGRectMake(100, 15 + y_value, self.view.frame.size.width, 25)];
    labelOne.font = [UIFont fontWithName:GlobalFontRegular size:18.0f];
    labelOne.text = nameString;
    labelOne.textColor = [UIColor colorWithRed:47/255.0f green:47/255.0f blue:47/255.0f alpha:1.0f];
    [view_1 addSubview:labelOne];
    
    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(100, 37+y_value, self.view.frame.size.width, 25)];
    labelTwo.font = [UIFont fontWithName:GlobalFontRegular size:15.0f];
    labelTwo.numberOfLines = 2;
    labelTwo.textColor = [UIColor colorWithRed:106/255.0f green:106/255.0f blue:106/255.0f alpha:1.0f];
    labelTwo.text = jobString;
    [view_1 addSubview:labelTwo];
    
    return view_1;
}

-(void)viewResume:(id)sender
{
    moreClicked = YES;
    
    if([Utility isComapany]){
        
        //When user clicks on jobs
        [FireBaseAPICalls captureMixpannelEvent:COMPANY_ACTIVITY_CONVERSATION_URLCLICKED];
        
        WRResumePreview *controller = [[WRResumePreview  alloc] initWithNibName:@"WRResumePreview" bundle:nil];
        controller.string_url = [NSString stringWithFormat:@"http://docs.google.com/viewer?url=%@%@",IMAGE_BASE_URL,[self.object_dictionary valueForKeyPath:@"userId.resume"]];
        controller.hidesBottomBarWhenPushed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:controller animated:YES completion:nil];
        });
        
    }else{
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        WRJobCardDetailsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRJOB_CARD_DETAILS_VIEW_CONTROLLER];
        cardObject.profile_dictionary = self.object_dictionary;
        cardObject.comingFromChat = @"chatscreen";
        cardObject.hideButtomBar = YES;
        cardObject.hidesBottomBarWhenPushed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:cardObject animated:YES completion:nil];
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"])
    {
        NSValue *new = [change valueForKey:@"new"];
        NSValue *old = [change valueForKey:@"old"];
        
        if (new && old)
        {
            if (![old isEqualToValue:new])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:NO];
                });
            }
        }
    }
}
- (UICollectionReusableView *)collectionView:(JSQMessagesCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (self.showLoadEarlierMessagesHeader && [kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        JSQMessagesLoadEarlierHeaderView *header = [collectionView dequeueLoadEarlierMessagesViewHeaderForIndexPath:indexPath];
        header.frame =  CGRectMake(0, 0, self.view.frame.size.width, 100);
        // Customize header
        [header addSubview:[self getHeaderView]];
        return header;
    }
    
    return [super collectionView:collectionView
viewForSupplementaryElementOfKind:kind
                     atIndexPath:indexPath];
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [self.inputToolbar toggleSendButtonEnabled];
    [self getUniqNumber];
}

#pragma mark - JSQMessages collection view data source

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    
    @try
    {
        if (messages.count == 0)
        {
            return 0;
        }
        else
        {
            return [messages objectAtIndex:indexPath.row];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@",exception);
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    if ([messages count]<=0) {
    } else {
        JSQMessage *message = [messages objectAtIndex:indexPath.item];
        if ([message.senderId isEqualToString:self.senderId])
        return  [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:51/255.0f green:122/255.0f blue:183/255.0f alpha:1.0f]];
        else
        return  [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:241/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f]];
    }
    return  [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:241/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f]];
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesAvatarImage *cookImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_cook"] diameter:50];
    
    JSQMessagesAvatarImage *cookImage1 = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_jobs"] diameter:50];
    
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    return  cookImage;
    else
    return  cookImage1;
}

#pragma mark - Collection view data source

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([messages count]<=0) {
    }
    else
    {
        JSQMessage *message = [messages objectAtIndex:indexPath.item];
        
        if (indexPath.item == 0) {
            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
        }
        
        if (indexPath.item - 1 > 0) {
            JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
            
            if ([message.date timeIntervalSinceDate:previousMessage.date] / 60 > 1) {
                return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
            }
        }
        return nil;
        
    }
    
    return nil;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault+10;
    }
    if (indexPath.item - 1 > 0) {
        
        if ([messages count]<=0)
        {
            return 0.0f;
        }
        else
        {
            JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
            JSQMessage *message = [messages objectAtIndex:indexPath.item];
            if ([message.date timeIntervalSinceDate:previousMessage.date] / 60 > 1) {
                return kJSQMessagesCollectionViewCellLabelHeightDefault;
            }
        }
        
    }
    
    return 0.0f;
}
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item >= messages.count) {
        return 0;
    }
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return 0.0f;
    } else {
        return 4.0;
    }
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(5.0f, 0, 0, 0);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([messages count]<=0) {
        return 0;
    }
    else {
        return messages.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    cell.textView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([messages count]<=0) {
        
    }
    else
    {
        JSQMessage *message = [messages objectAtIndex:indexPath.item];
        
        if ([message.senderId isEqualToString:self.senderId])
        {
            cell.textView.textColor = [UIColor whiteColor];
            cell.textView.contentMode = UIViewContentModeScaleAspectFit;
        }else{
            cell.textView.textColor = MainTextColor;
            cell.textView.contentMode = UIViewContentModeScaleAspectFit;
        }
        cell.cellTopLabel.font = [UIFont fontWithName:GlobalFontSemibold size:12];
        
        [cell.avatarImageView setNeedsDisplay];
        cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    
    return cell;
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods

- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    textView.scrollEnabled = NO;
    if ([UIPasteboard generalPasteboard].image) {
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

#pragma mark - JSQMessagesViewAccessoryDelegate methods

#pragma mark - Messages view controller

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    if([[self.object_dictionary valueForKey:@"title"] isEqualToString:@"Hello From Workruit"] && [messages count] >= [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatLimit"] intValue]){
        button.enabled = NO;
        return;
    }
    
    button.enabled = NO;
	NSLog(@"TEST text: %@ senderId: %@ senderDisName: %@", text, senderId, senderDisplayName);
	
    [[ChatManager sharedManager] sendMessageFrom:self.senderDisplayName withContent:[self getSendMessageStringWithMessage:text senderId:senderId senderDisplayName:senderDisplayName date:date isTyping:NO] withPayload:[self getMobilePushPayload:text]];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - Notification Handlers
-(void)getUniqNumber
{
    date1 = [Utility convertToGMTTimeZone:[NSDate date] withFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    long time = (long)[[NSDate date] timeIntervalSince1970];
    uniqNumber = [NSString stringWithFormat:@"%ld",time];
    
    //uniqNumber = [Utility convertToGMTTimeZone:[NSDate date] withFormat:@"yyyy MM dd hh:mma"];
}

-(NSMutableDictionary *)getSendMessageStringWithMessage:(NSString *)text
                                               senderId:(NSString *)senderId
                                      senderDisplayName:(NSString *)senderDisplayName
                                                   date:(NSDate *)date isTyping:(BOOL)isTyping
{
    [self getUniqNumber];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dictionary setObject:senderId forKey:@"from_id"];
    [dictionary setObject:@"123" forKey:@"to_id"];
    [dictionary setObject:uniqNumber forKey:@"msg_id"];
    [dictionary setObject:text forKey:@"msg"];
    [dictionary setObject:date1 forKey:@"date"];
    [dictionary setObject:@"iOS" forKey:@"source"];
    [dictionary setObject:@"text" forKey:@"media_type"];
    [dictionary setObject:@"single" forKey:@"chat_type"];
    [dictionary setObject:uniqNumber forKey:@"timestamp"];
    [dictionary setObject:channel_name forKey:@"channel"];
    //    [dictionary setObject:[NSNumber numberWithBool:isTyping] forKey:@"isTyping"];
    
    NSLog(@"my dictionary:%@",text);
    return  dictionary;
}

//TODO Sudheer please lookin to params
-(NSMutableDictionary *)getMobilePushPayload:(NSString *)message
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *regdId = app.current_regId;
    
    if(regdId == nil)
    regdId = @"";
    
    NSString *to_id = [Utility isComapany]? [[NSUserDefaults standardUserDefaults] valueForKeyPath:RECRUITER_REGISTRATION_ID]: [[NSUserDefaults standardUserDefaults] valueForKeyPath:APPLICANT_REGISTRATION_ID];
    
    NSMutableDictionary *main_dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (regdId.length > 0 && ![regdId isEqualToString:@"NA"]) {
        if([device_type.lowercaseString isEqualToString:@"ios"]) {
            [main_dictionary setObject:regdId forKey:@"to"];
        }
        else {
            [main_dictionary setObject:[NSString stringWithFormat:@"/topics/%@",channel_name] forKey:@"to"];
        }
    } else {
        [main_dictionary setObject:[NSString stringWithFormat:@"/topics/%@",channel_name] forKey:@"to"];
    }
    [main_dictionary setObject:@"high" forKey:@"priority"];
    [main_dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"content_available"];
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *name = @"";
    NSString * title;
    
    if([Utility isComapany])
    {
        name =  [NSString stringWithFormat:@"%@ (%@)",[[CompanyHelper sharedInstance].params valueForKeyPath:@"firstname"],[[CompanyHelper sharedInstance].params valueForKeyPath:@"companyName"]];
        
        screen_sub_title = [CompanyHelper getJobRoleNameWithId:[NSString stringWithFormat:@"%@",[[CompanyHelper sharedInstance].params valueForKeyPath:@"jobRoleId"]] parantKey:@"jobRoles" childKey:@"jobRoleId"  valueKey:@"jobRoleName"];
        
        title=[NSString stringWithFormat:@"%@ %@",[[CompanyHelper sharedInstance].params valueForKeyPath:@"firstname"],[[CompanyHelper sharedInstance].params valueForKeyPath:@"lastname"]];
    }
    else
    {
        name = [NSString stringWithFormat:@"%@ %@",[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"firstname"],[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"lastname"]];
        
        screen_sub_title =[NSString stringWithFormat:@"%@",[[ApplicantHelper sharedInstance].paramsDictionary valueForKeyPath:@"title"]];
        
    }
    
    if([Utility isComapany])
    [aps setObject:[NSString stringWithFormat:@"You have a new message from %@.",name] forKey:@"body"];
    else
    [aps setObject:[NSString stringWithFormat:@"You have a new message from %@.",name]  forKey:@"body"];
    
    
    [aps setObject:[NSString stringWithFormat:@"%@", message] forKey:@"msg"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
    [aps setObject:@"bingbong.aiff" forKey:@"sound"];
    [aps setObject:channel_name forKey:@"channel"];
    [aps setObject:self.senderId forKey:@"from_id"];
    [aps setObject:uniqNumber forKey:@"timestamp"];
    [aps setObject:name forKey:@"name"];
    [aps setObject:[NSString stringWithFormat:@"%@",to_id] forKey:@"to_id"];
    [aps setObject:date1 forKey:@"date"];
    [aps setObject:uniqNumber forKey:@"msg_id"];
    [aps setObject:PUBNUB forKey:NOTIFICATION_TYPE];
    [main_dictionary setObject:[aps mutableCopy] forKey:@"notification"];
    if([Utility isComapany])
    [aps setObject:title forKey:@"title"];
    else
    [aps setObject:name forKey:@"title"];
    [aps setObject:screen_sub_title forKey:@"subtitle"];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:0];
    [aps setObject:[NSString stringWithFormat:@"%@", message] forKey:@"msg"];
    [aps setObject:[NSNumber numberWithBool:0] forKey:@"isTyping"];
    [data setObject:[Utility convertDictionaryToJSONString:aps] forKey:@"chat_obj"];
    
    
    [main_dictionary setObject:data forKey:@"data"];
    
    
    return main_dictionary;
}

-(void)callNetworkAPIForEevryMessage:(NSMutableDictionary *)payload
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/channel",API_BASE_URL] WithParams:[CompanyHelper convertDictionaryToJSONString:payload] forRequest:-100 controller:self httpMethod:HTTP_POST];
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    if(tag == -100){
        [defaults setObject:[NSString stringWithFormat:@"%@",[data valueForKey:@"data"]] forKey:[NSString stringWithFormat:@"%@_block",channel_name]];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:[NSString stringWithFormat:@"%@_SendMessageViaServer",channel_name]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if (tag == -200){
        [defaults setObject:[NSString stringWithFormat:@"%@",[[[data valueForKeyPath:@"data"] lastObject] valueForKey:@"blocked"]] forKey:[NSString stringWithFormat:@"%@_ack",channel_name]];
    }
    [defaults synchronize];
    
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}
-(void)detailButtonAction:(id)sender
{
    moreClicked = YES;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"More" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    
    if([Utility isComapany]){
        if ([[self.object_dictionary valueForKeyPath:@"userId.resume"] length] <= 0) {
        }else{
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"View Resume" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self viewResume:sender];
            }]];
        }}
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:[Utility isComapany]?@"View Profile":@"View Job" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if([Utility isComapany]){
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
            WRCardDetailsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRCARD_DETAILS_VIEW_CONTROLLER_IDENTIFIER];
            NSMutableDictionary *temp_object = [[NSMutableDictionary alloc] initWithCapacity:0];
            [temp_object addEntriesFromDictionary:[self.object_dictionary valueForKey:@"jobPostId"]];
            [temp_object addEntriesFromDictionary:[self.object_dictionary valueForKey:@"userId"]];
            cardObject.profile_dictionary = temp_object;
            cardObject.comingFromChat = @"chatscreen";
            cardObject.hidesBottomBarWhenPushed = YES;
            cardObject.hideButtomBar = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:cardObject animated:YES completion:nil];
            });
        }else{
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
            WRJobCardDetailsViewController *cardObject = [mystoryboard instantiateViewControllerWithIdentifier:WRJOB_CARD_DETAILS_VIEW_CONTROLLER];
            cardObject.profile_dictionary = self.object_dictionary;
            cardObject.comingFromChat = @"chatscreen";
            cardObject.hideButtomBar = YES;
            cardObject.hidesBottomBarWhenPushed = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:cardObject animated:YES completion:nil];
            });
        }
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}
-(void)addDefultMessageFromWorkRuitAndDissableSendButton
{
    NSString *defaultChat = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"chat"]];
    if ([defaultChat isEqualToString:@"(null)"])
    defaultChat = APP_DEFAULT_MESSAGE;
    
    NSDate *date; 
    if (messages.count == 0) {
        NSTimeInterval interval = [[self.object_dictionary valueForKey:@"conversationMatchDateValue"] doubleValue]/1000;
        date = [NSDate dateWithTimeIntervalSince1970:interval];
        //date = [Utility getDateWithStringDate1:[self.object_dictionary valueForKey:@"conversationMatchDate"] withFormat:@"MMM yyyy dd  HH:mm a"];
        if (date == nil)
        date = [NSDate date];
    } else {
        JSQMessage *firstObject = messages.firstObject;
        date = [firstObject.date dateByAddingTimeInterval:-60];
    }
    
    JSQMessage *object_message = [[JSQMessage alloc] initWithSenderId:@"admin@workruit.com" senderDisplayName:@"Admin" date:date text:defaultChat];
    [messages insertObject:object_message atIndex:0];
}

@end
