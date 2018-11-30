//
//  LoadDataManager.m
//  DAS mobile
//
//  Created by eMbience
//  Copyright (c) Digital Air Strike 2013. All rights reserved.
//

#import "LoadDataManager.h"
#import "AppDelegate.h"
#import "AFNetworking.h"

@implementation LoadDataManager

+(LoadDataManager *)sharedInstance
{
    static LoadDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoadDataManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)getApplicationData
{
    if(![[NSUserDefaults standardUserDefaults] valueForKey:ISLOGEDIN])
        return;
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTimeSynced"]) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            UINavigationController *firstViewController = self.tabBarController.viewControllers.firstObject;
            UIViewController *candidateProfileViewController = firstViewController.viewControllers.firstObject;
            [MBProgressHUD showHUDAddedTo:candidateProfileViewController.view animated:YES];
        }];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self stopLoading];
    });
    
    if([Utility isComapany]) {
        [[CompanyHelper sharedInstance] getRecruterMatches:self requestType:101];
        [[CompanyHelper sharedInstance] getShortListedProfiles:self requestType:350];
        [FireBaseAPICalls captureScreenDetails:COMPANY_CONVERSATION];
        [FireBaseAPICalls captureScreenDetails:COMPANY_APPLIED];
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID];
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:COMPANY_ACTIVITY_CONVERSATION_LISTVIEW setProperties:userName];
        [Utility getMixpanelData:COMPANY_ACTIVITY_LISTVIEW setProperties:userName];
    } else {
        [[ApplicantHelper sharedInstance] getApplicantJobMatches:self requestType:101];
        [[ApplicantHelper sharedInstance] viewAppliedJobs:self requestType:350];
        [FireBaseAPICalls captureScreenDetails:APPLICANT_CONVERSATION];
        [FireBaseAPICalls captureScreenDetails:APPLICANT_APPLIED];
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults] valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        [Utility getMixpanelData:APPLICANT_ACTIVITY_CONVERSATION_LISTVIEW setProperties:userName];
        [Utility getMixpanelData:APPLICANT_ACTIVITY_LISTVIEW setProperties:userName];
    }
}


-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if((tag == 350 || tag == -350) && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]) {
        NSMutableDictionary *dictionary_object = (NSMutableDictionary *)data;
        NSMutableArray *arrayObjects = [[data valueForKey:@"data"] mutableCopy];
        
        if ([[dictionary_object valueForKey:@"msg"]isEqualToString:@"ViewAppliedJobs Success"]) {
            [[ApplicantHelper sharedInstance] viewAppliedJobs_External:self requestType:arrayObjects?-200:200];
        } else {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jobSwipeActionDate" ascending:NO];
            arrayObjects = [[arrayObjects sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
            
            NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:arrayObjects];
            [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:INTRESTEDLISTARRAY];
        }
    } else if(tag == -200|| tag == 200) {
        NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:INTRESTEDLISTARRAY];
        NSMutableArray *arrayObjectsSaved = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
        
        if (!arrayObjectsSaved)
            arrayObjectsSaved = [NSMutableArray array];

        for (int j=0; j<[[data valueForKey:@"data"]count]; j++)
        {
            BOOL isContain = NO;
            
            NSMutableDictionary *savedDict = [[NSMutableDictionary alloc]init];
            [savedDict setValue:[[[data valueForKey:@"data"] objectAtIndex:j] valueForKey:@"company_ext"] forKey:@"companyName"];
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
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jobSwipeActionDate" ascending:NO];
        arrayObjectsSaved = [[arrayObjectsSaved sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
        
        NSData *dataArray1 = [NSKeyedArchiver archivedDataWithRootObject:arrayObjectsSaved];
        [[NSUserDefaults standardUserDefaults] setObject:dataArray1 forKey:INTRESTEDLISTARRAY];
    } else if((tag == 101|| tag == -101) && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]) {
        NSMutableArray *arrayObjects = [[data valueForKey:@"data"] mutableCopy];
        
        int server_side_count = (int)[arrayObjects count];
        int clint_side_count = (int)[[[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list order by last_update_date DESC"]] count];
        
        if(server_side_count > clint_side_count){
//            [self subcribeAllChannelsForPush:arrayObjects diff:clint_side_count-server_side_count];
        }
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTimeSynced"]) {
            [self stopLoading];
            return;
        }
        if (arrayObjects.count == 0) {
            [self stopLoading];
            return;
        }
        
        for(NSMutableDictionary *dictionary in arrayObjects)
        {
            [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"delete from conversation_list where channel_name = '%@'  ",[Utility getChannelName:dictionary]]];
            
            NSString *json_object = [Utility convertDictionaryToJSONString:dictionary];
            json_object = [json_object stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            NSDate *date = [NSDate date];
            
            if(![Utility isComapany])
                date =  [Utility getDateWithStringDate:[dictionary valueForKeyPath:@"conversationMatchDate"] withFormat:@"MMM yyyy dd  HH:mm a"];
            else
                date =  [Utility getDateWithStringDate:[dictionary valueForKeyPath:@"jobPostId.conversationMatchDate"] withFormat:@"MMM yyyy dd  HH:mm a"];
            
            NSString *userId = [Utility isComapany]?[dictionary valueForKeyPath:@"userId.userId"]:[dictionary valueForKeyPath:@"recruiter.userId"];
            
            [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"insert or replace into conversation_list (channel_name,last_update_date,json_text,un_read_count) VALUES ('%@','%@','%@',%d)",[Utility getChannelName:dictionary],date,json_object,[userId intValue]]];
            //[self getAllMessagesWithChannel:[Utility getChannelName:dictionary] isLast:dictionary==arrayObjects.lastObject];
        }
        [self stopLoading];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstTimeSynced"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}

- (void)getAllMessagesWithChannel:(NSString *)channel isLast:(BOOL)isLast
{
    FIRDatabaseReference *chatReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"/channels/%@",channel]];
    [chatReference keepSynced:YES];
    [chatReference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if (snapshot.value)
         {
             NSDictionary *dictionary_object = (NSDictionary *)snapshot.value;
             if ([[dictionary_object class] isSubclassOfClass:[NSNull class]]) {
                 [chatReference removeAllObservers];
                 if (isLast) {
                     [self stopLoading];
                 }
                 return;
             }
             
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
                     
                     if(final_count > 0 && [[[NSUserDefaults standardUserDefaults] valueForKey:@"FirstTimeSignIn"] boolValue]){
                         
                         [self addLocalNotifications:[messages.lastObject valueForKey:@"msg"]];
                         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"FirstTimeSignIn"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                     }
                     
                     [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)final_count] forKey:[NSString stringWithFormat:@"%@_unread_count",channel]];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                 }
                 
                 if (isLast)
                     [self stopLoading];
                 
                 [databaseReference removeAllObservers];
             }];
         }  else if (isLast) {
             [self stopLoading];
         }
         [chatReference removeAllObservers];
     }];
}

-(void)stopLoading
{
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//        [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName: UPDATEDATANOTIFICATION object:nil userInfo:nil];
    }];
}

- (void)addLocalNotifications:(NSString *)message
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] initWithCapacity:0];
    [aps setObject:[Utility isComapany]?@"Employer_View_Matched":@"Appicant_View_Matched" forKey:@"category"];
    [payload setObject:aps forKey:@"aps"];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.userInfo = payload;
    notification.alertTitle = @"Workruit";
    notification.alertBody = [NSString stringWithFormat:@"You have some unread messages."];
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app showMessage:@"You have some unread messages." withPayLoad:payload];
    }];
}

-(NSDate *)getDateFrom:(NSDictionary *)dictionary
{
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

@end

