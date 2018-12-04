//
//  AppDelegate.m
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import "NotificaitonView.h"
#import "WRACMatchScreen.h"
#import "FMDBDataAccess.h"

#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "WRVerifyMobileController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;


@interface AppDelegate ()<HTTPHelper_Delegate>

@end

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate,HTTPHelper_Delegate>
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Workruit" icon:[UIImage imageNamed:@"app_icon_image"] defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSWest2 identityPoolId:@"us-west-2:87e8ec4c-48e8-4787-a44a-b74266cada11"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo) {
        NSLog(@"app recieved notification from remote%@",userInfo);
        [self performSelector:@selector(onclickNotificationHandleNavigation:) withObject:userInfo afterDelay:1.0f];
    } else {
        NSLog(@"app did not recieve notification");
    }
    
    [FIRApp configure];
    [FIRDatabase database].persistenceEnabled = YES;

    [self confrigrationPushNotification];
    [self configureReachability];
    [[FMDBDataAccess sharedInstance] start];
		[Fabric with:@[[Crashlytics class], [AWSCognito class]]];
		[Fabric sharedSDK].debug = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.notification_container = [CWStatusBarNotification new];
    self.notification_container.notificationAnimationInStyle = 0;
    self.notification_container.notificationAnimationOutStyle = 0;
    self.notification_container.notificationStyle =  CWNotificationStyleNavigationBarNotification;

    NSLog(@"----- %@ ---",[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissNotificationFromView:) name:DISMISSNOTIFICATIONFROMVIEW object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCount) name:UPDATEDATANOTIFICATION object:nil];

    //Temp hard coded value
    //Check Login Status
    [self performSelector:@selector(getLoginStatusFromServer) withObject:self afterDelay:3.0f];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameAchievedLevel];

//    // Added for Verification for Employee EMail Check
//    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
//    if ([[url scheme] isEqualToString:@"workruit"])
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:EMAIL_VERIFICATION_SERVICE_NOTIFIER object:self userInfo:nil];
//        return YES;
//    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([[url scheme] isEqualToString:@"workruit"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:EMAIL_VERIFICATION_SERVICE_NOTIFIER object:self userInfo:nil];
        return YES;
    } else {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navigationController = (UINavigationController *)_window.rootViewController;
        if ([url.pathComponents containsObject:@"home"]) {
            [navigationController pushViewController:[storyBoard instantiateViewControllerWithIdentifier:@"HomeScreenId"] animated:YES];
        }else if ([url.pathComponents containsObject:@"about"]){
            [navigationController pushViewController:[storyBoard instantiateViewControllerWithIdentifier:@"AboutScreenId"] animated:YES];
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: self.unreadConversationCount];
    
    //Save the object
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_LOCAL_OBJECTS_NOTIFICATION object:nil];
    
    // [[FIRMessaging messaging] disconnect];
    
    [[FIRMessaging messaging] shouldEstablishDirectChannel];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: self.unreadConversationCount];
    
    //Save the object
    [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_LOCAL_OBJECTS_NOTIFICATION object:nil];
    
    [[FIRMessaging messaging] shouldEstablishDirectChannel];
    
    // [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"FirstTimeLoad"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self connectToFcm];
    
    [FBSDKAppEvents activateApp];
    
   // NSLog(@"-------- %@ --------",[[NSUserDefaults standardUserDefaults] valueForKey:APPCRITICAL_UPDATE_NOTIFICATION_FLAG]);
    
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:APPCRITICAL_UPDATE_NOTIFICATION_FLAG] boolValue])
    {
        if([Utility converVersionToFloat:[[NSUserDefaults standardUserDefaults] valueForKey:APP_CRITICAL_UPDATE_OS_VERSION]] > [Utility converVersionToFloat:[Utility getAppVersionNumber]]){
            [[NSNotificationCenter defaultCenter] postNotificationName:APPCRITICAL_UPDATE_NOTIFICATION object:nil];
        }
    }
}

#pragma mark Remote Notification
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [FIRMessaging messaging].APNSToken = deviceToken;
    
    NSString *tokenStr = [deviceToken description];
    NSString *push_token = [[[tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@",push_token);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSLog(@"%@",userInfo);
    [self didReceiveRemoteNotification:userInfo isFCM:YES];
    completionHandler(UIBackgroundFetchResultNewData);

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC),
//                   dispatch_get_main_queue(), ^{
//                       completionHandler(UIBackgroundFetchResultNewData);
//                   });
}

#pragma mark Remote Notification - FIRMessagingDelegate
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage
{
    NSLog(@"%@", [remoteMessage appData]);
    [self didReceiveRemoteNotification:[remoteMessage appData] isFCM:YES];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken
{
    [self tokenRefreshNotification];
}

#pragma mark Remote Notification - UNUserNotificationCenterDelegate
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    NSData *objectData = [[userInfo valueForKey:@"chat_obj"] dataUsingEncoding:NSUTF8StringEncoding];
    if(objectData) {
        NSMutableDictionary *chatObject = [NSJSONSerialization JSONObjectWithData:objectData
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:nil];
        
        //if([[chatObject valueForKey:@"source"] isEqualToString:@"Android"])
        //     [self showMessageWIthNotificationObject:chatObject];
        
        //Online
        // Print full message.
        NSLog(@"%@", chatObject);
    }
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"Anwer hussain 1%@", userInfo);
    
    if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_OTP_Not_Verified"])
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClickedOnSignUPProcess" object:nil userInfo:userInfo];        
//        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
//        WRVerifyMobileController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WRVERIFY_MOBILE_VIEW_CONTROLLER_IDENTIFIER];
//        UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:controller];
//        navController2.navigationBarHidden = YES;
//        [self.window setRootViewController:navController2];
    }
    else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_OTP_Verified"])
    {
    }
    else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_JobFunction"])
    {
    }
    else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Skills_No_Experience"])
    {
    }
    else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Exp_No_Education"])
    {
    }
    else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Experience_SkipClick"])
    {
    }
    else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Education_SkipClick"])
    {
    }
    else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_No_Candidates"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION object:nil userInfo:userInfo];
    }
    else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_Candidates"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION object:nil userInfo:userInfo];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION_ON_CLICK object:nil userInfo:userInfo];
    }
}
#endif

-(void)confrigrationPushNotification
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        // For iOS 10 data message (sent via FCM)
        [FIRMessaging messaging].delegate = self;
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification) name:kFIRInstanceIDTokenRefreshNotification object:nil];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo isFCM:(BOOL)isFCM
{
    NSString *notificationTypeKey;
    
//    if (isFCM) {
//        notificationTypeKey = @"notification.notification_type";
//    } else {
        notificationTypeKey = @"gcm.notification.notification_type";
//    }
    
    
    //long badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    //badgeCount = badgeCount + 1;
    //NSLog(@"?????????? %ld ?????????????",badgeCount);

    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    
    NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    //NSLog(@"------- %@ ---",userInfo);
    
    if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:NOTIFICATION_AUTO_LOGOUT]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_LOGOUT_NOTIFICATION_NAME_KEY object:userInfo];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPLICANT_OBJECT_PARAMS];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:COMPANY_OBJECT_PARAMS];
        return;
    } else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:CRITCAL_UPDATE_CATEGORY]) {
        NSString *ios_version = [userInfo valueForKey:@"iosVersion"];
        [[NSUserDefaults standardUserDefaults] setObject:ios_version forKey:APP_CRITICAL_UPDATE_OS_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:APP_CRITICAL_UPDATE_OS_VERSION]);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:APPCRITICAL_UPDATE_NOTIFICATION object:nil];
        return;
    } else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_User_Reg_Update"]) {
        if([self.current_user_id intValue] == [[userInfo valueForKey:@"userId"] intValue])
            self.current_regId = [userInfo valueForKey:@"regdId"];
        
        [self updateRegistrationIdToDataBase:userInfo];
        return;
    }
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        NSLog(@"Inactive - the user has tapped in the notification when app was closed or in background");
        
        //Show Match screen when app is active state
        if([session_id length] > 0)
            [self performSelector:@selector(postNotificationToNavigate:) withObject:userInfo afterDelay:1.0f];
        
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSLog(@"application Background - notification has arrived when app was in background");
        
        if([[userInfo valueForKeyPath:notificationTypeKey] isEqualToString:@"FCM"])
        {
            NSData *objectData = [[userInfo valueForKey:@"chat_obj"] dataUsingEncoding:NSUTF8StringEncoding];
            if(objectData) {
                NSMutableDictionary *chatObject = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                  options:NSJSONReadingMutableContainers
                                                                                    error:nil];
                [self updateUnreadCountOnFirebase:chatObject];
            }
        } else if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_OTP_Not_Verified"]||[[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_OTP_Verified"]||[[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_JobFunction"]||[[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Skills_No_Experience"]||[[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Exp_No_Education"]||[[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Education_SkipClick"]||[[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Applicant_Experience_SkipClick"]) {
        } else if ([[userInfo valueForKeyPath:@"aps.category"]isEqualToString:@"Notif_Recruiter_No_Candidates"]) {
        } else if ([[userInfo valueForKeyPath:@"aps.category"]isEqualToString:@"Notif_Recruiter_Candidates"]) {
        } else {
            //Show Match screen when app is active state
            if([session_id length] > 0)
                [self performSelector:@selector(postNotificationToNavigate:) withObject:userInfo afterDelay:1.0f];
        }
    } else {
        NSLog(@"application Active - notication has arrived while app was opened");
        //Show Match screen when app is active state
        if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_JobSeeker_JobMatch"] || ([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_JobMatch"])){
            //       [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", [userInfo valueForKey:@"channel"]]];
            [self performSelector:@selector(postNotificationToNavigate:) withObject:userInfo afterDelay:1.0f];
        } else if(![[userInfo valueForKeyPath:notificationTypeKey] isEqualToString:@"FCM"]) {
            [self showMessage:[userInfo valueForKeyPath:@"aps.alert.body"] withPayLoad:(NSMutableDictionary *)userInfo];
            
            if([[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Recruiter_No_JobPost"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Active"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Closed"] || [[userInfo valueForKeyPath:@"aps.category"] isEqualToString:@"Notif_Job_Reject"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:RELOADJOBSLIST object:nil];
            }
        } else  if([[userInfo valueForKeyPath:notificationTypeKey] isEqualToString:@"FCM"]) {
            NSData *objectData = [[userInfo valueForKey:@"chat_obj"] dataUsingEncoding:NSUTF8StringEncoding];
            if(objectData) {
                NSMutableDictionary *chatObject = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                  options:NSJSONReadingMutableContainers
                                                                                    error:nil];
                [self showMessageWIthNotificationObject:chatObject];
            }
        }
    }
    long badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badgeCount = badgeCount + 1;
    NSLog(@"?????????? %ld ?????????????",badgeCount);
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
}

- (void)tokenRefreshNotification
{
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    if(refreshedToken == nil)
        return;
    
    [Utility saveToDefaultsWithKey:PUSH_TOKEN_ID value:refreshedToken];
    [[NSUserDefaults standardUserDefaults] setObject:refreshedToken forKey:@"DeviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Refresh %@-----%@", [[NSUserDefaults standardUserDefaults] valueForKeyPath:PUSH_TOKEN_ID], [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"DeviceToken"]);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
    [self updateTokenToApplicanServer:refreshedToken];
}

- (void)connectToFcm
{
    [FIRMessaging messaging].shouldEstablishDirectChannel = YES;
}

-(void)updateTokenToApplicanServer:(NSString *)regdId
{
    NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    
    if([session_id length] > 0){
        NSString *userId = [Utility isComapany]?[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]]:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
        
        if([userId intValue] <= 0)
            return;
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:userId forKey:@"userId"];
        [params setObject:regdId forKey:@"regdId"];
        
        ConnectionManager *manager = [[ConnectionManager alloc] init];
        manager.delegate = self;
        [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,UPDATE_REGID] WithParams:[CompanyHelper convertDictionaryToJSONString:params] forRequest:-400 controller:self httpMethod:HTTP_POST];
    }
}

-(void)showMessageWIthNotificationObject:(NSDictionary *)chatObject
{
    if((![Utility isComapany] && [[chatObject valueForKey:@"from_id"] isEqualToString:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:EMAIL_KEY]]) || ([Utility isComapany] && [[chatObject valueForKey:@"from_id"] isEqualToString:[[CompanyHelper sharedInstance].params valueForKey:EMAIL_KEY]]))
        return;
    
    if([[chatObject valueForKeyPath:@"notification_type"] isEqualToString:@"FCM"]  && ![[chatObject valueForKeyPath:@"channel"] isEqualToString:self.current_channel]){
        
        [self showMessage:[NSString stringWithFormat:@"You have a new message from \n %@.", [[chatObject valueForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] withPayLoad:(NSMutableDictionary *)chatObject];
        
        [self updateUnreadCountOnFirebase:chatObject];
    }
}

-(void)showMessage:(NSString *)message withPayLoad:(NSMutableDictionary *)payLoad
{
    NSDate *date_one = [Utility getDateWithStringDate:[payLoad valueForKey:@"date"] withFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    if(date_one == nil){
        date_one = [Utility getDateWithStringDate:[payLoad valueForKey:@"date"] withFormat:@"yyyy-MM-dd HH:mm:ss.zzz"];
    }
    
    LNNotification* notification = [LNNotification notificationWithMessage:message];
    notification.title = @"Workruit";
    if (date_one != nil) {
        notification.date = date_one;
    }
    notification.soundName = @"demo.aiff";
    notification.icon = [UIImage imageNamed:@"app_icon_image"];
    notification.defaultAction = [LNNotificationAction actionWithTitle:@"View" handler:^(LNNotificationAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION_ON_CLICK object:nil userInfo:payLoad];
    }];
        
    if (![notification valueForKey:@"message"])
        return;
    
    [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
}

-(void)updateUnreadCountOnFirebase:(NSDictionary *)chatObject
{
    if((![Utility isComapany] && [[chatObject valueForKey:@"from_id"] isEqualToString:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:EMAIL_KEY]]) || ([Utility isComapany] && [[chatObject valueForKey:@"from_id"] isEqualToString:[[CompanyHelper sharedInstance].params valueForKey:EMAIL_KEY]]))
        return;
    
    if([[chatObject valueForKeyPath:@"notification_type"] isEqualToString:@"FCM"]  && ![[chatObject valueForKeyPath:@"channel"] isEqualToString:self.current_channel])
    {
        NSString *count = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_unread_count",[chatObject valueForKey:@"channel"]]];
        int unread_count = [count intValue] + 1;
        
        NSString *message = [chatObject valueForKey:@"msg"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:unread_count] forKey:[NSString stringWithFormat:@"%@_unread_count",[chatObject valueForKey:@"channel"]]];
        [[NSUserDefaults standardUserDefaults] setObject:message forKey:[NSString stringWithFormat:@"%@_last_message",[chatObject valueForKey:@"channel"]]];
        [[NSUserDefaults standardUserDefaults] synchronize];

        message = [message stringByReplacingOccurrencesOfString:@"\'" withString:@""];
        message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"insert or replace into chat_table (channel_name,date,from_id,to_id,msg_id,msg,chat_type,media_type) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')",[chatObject valueForKeyPath:@"channel"],[chatObject valueForKey:@"date"],[chatObject valueForKey:@"from_id"],[chatObject valueForKey:@"to_id"],[chatObject valueForKey:@"msg_id"],message,[chatObject valueForKey:@"chat_type"],[chatObject valueForKey:@"media_type"]]];
        
        [self performSelector:@selector(chatPostNotification:) withObject:chatObject afterDelay:0.3f];
        NSLog(@"%d",unread_count);
    }
    
    [self updateUnreadCount];
}

-(void)chatPostNotification:(NSDictionary *)chatObject {
    [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVEHISTORYWITHDATA object:nil userInfo:chatObject];
}

-(void)updateUnreadCount
{
    NSMutableArray *arrayObjects1 = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list order by last_update_date DESC"]];
    NSInteger unreadConversations = 0;
    
    for(NSDictionary *dictionary_object1 in arrayObjects1){
        NSString *count = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_unread_count",[dictionary_object1 valueForKey:@"channel_name"]]];
        if([count intValue] > 0)
            unreadConversations = unreadConversations + [count intValue];
    }
    
    self.unreadConversationCount = unreadConversations;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: unreadConversations];
}

-(void)clearAllNotifications
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void)dismissNotificationFromView:(NSNotification *)handle
{
    [self.notification_container dismissNotification];
}

-(void)onclickNotificationHandleNavigation:(NSDictionary *)dictionary
{
    [self clearAllNotifications];
    [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION_ON_CLICK object:nil userInfo:dictionary];
}

-(void)getLoginStatusFromServer
{
    NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    if([session_id length] > 0){
        
        NSString *userId = [Utility isComapany]?[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]]:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
        
        if([userId intValue] <= 0)
            return;
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params setObject:userId forKey:@"userId"];
        [params setObject:session_id forKey:@"sessionId"];
    
        ConnectionManager *manager = [[ConnectionManager alloc] init];
        manager.delegate = self;
        [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,GET_LOGIN_STATUS] WithParams:[CompanyHelper convertDictionaryToJSONStringWithPassword:params] forRequest:-121212 controller:self httpMethod:HTTP_POST];
    }
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == -200 || tag == - 400)
        return;
    
    if([[data valueForKeyPath:@"data.status"] intValue] == 0 && tag == -121212)
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_LOGOUT_NOTIFICATION_NAME_KEY object:nil];
    
    if([[data valueForKeyPath:@"data.ios.critical"] boolValue] && [Utility converVersionToFloat:[data valueForKeyPath:@"data.ios.version"]] > [Utility converVersionToFloat:[Utility getAppVersionNumber]])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[data valueForKeyPath:@"data.ios.version"] forKey:APP_CRITICAL_UPDATE_OS_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[NSNotificationCenter defaultCenter] postNotificationName:APPCRITICAL_UPDATE_NOTIFICATION object:nil];
    }
    
    NSMutableArray *arrayOfMatchPayloades = [data valueForKeyPath:@"data.jobMatches"];
  //  [[NSUserDefaults standardUserDefaults]setObject:arrayOfMatchPayloades forKey:@"Match_Notify"];
    if([arrayOfMatchPayloades count] > 0){
        
//        for (int i=0; i<arrayOfMatchPayloades.count; i++) {
//            [self postNotificationToNavigate:[arrayOfMatchPayloades objectAtIndex:i]];
//        }
        for (NSInteger i = 0; i < arrayOfMatchPayloades.count; i++) {
            NSDictionary *data = arrayOfMatchPayloades[i];
            if ([self postNotificationToNavigate:data]) {
                [self acknowledgeMentService:data];
                break;
            }
        }
    }
}

-(void)acknowledgeMentService:(NSDictionary *)payloads
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    
//    for (NSMutableDictionary *object in payloads) {
//        [array addObject:[object valueForKey:@"channel"]];
//    }
    NSString *channel = [payloads valueForKey:@"channel"];
    if ([channel isKindOfClass:[NSString class]]) {
        [dictionary setObject:@[channel] forKey:@"channels"];
    }
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/channel/acknowledge",API_BASE_URL] WithParams:[CompanyHelper convertDictionaryToJSONString:dictionary] forRequest:-200 controller:self httpMethod:HTTP_POST];
}

-(void)updateRegistrationIdToDataBase:(NSDictionary *)payload
{
    NSMutableArray *arrayObjects = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from conversation_list where  un_read_count = %@",[payload valueForKey:@"userId"]]];
    
    if([arrayObjects count] > 0){
        NSMutableDictionary *dictionary = [Utility getDictionaryFromString:[[arrayObjects objectAtIndex:0] valueForKey:@"json_text"]];
        dictionary = [dictionary mutableCopy];
        if([Utility isComapany]){
            NSMutableDictionary *userIdObject = [[dictionary valueForKeyPath:@"userId"] mutableCopy];
            [userIdObject setObject:[payload valueForKey:@"regdId"] forKey:@"regdId"];
            [dictionary setObject:userIdObject forKey:@"userId"];
        }else{
            NSMutableDictionary *recruiterObject = [[dictionary valueForKeyPath:@"recruiter"] mutableCopy];
            [recruiterObject setObject:[payload valueForKey:@"regdId"] forKey:@"regdId"];
            [dictionary setObject:recruiterObject forKey:@"recruiter"];
        }

        NSString *json_object = [Utility convertDictionaryToJSONString:dictionary];
        [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"update conversation_list set json_text = '%@' where un_read_count= %@",json_object,[payload valueForKey:@"userId"]]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: RELOADCONVERSATIONLIST object:nil userInfo:nil];
}

-(BOOL)postNotificationToNavigate:(NSDictionary *)dictionary
{
    
    NSMutableArray *arrayObjects = [[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"jobMatchIds"] mutableCopy];
    
    if(arrayObjects == nil)
        arrayObjects = [[NSMutableArray alloc] initWithCapacity:0];

    BOOL isThereObject = NO;
    for(NSString *matchId in arrayObjects){
        if([[dictionary valueForKey:@"job_match_id"] intValue] == [matchId intValue]){
            isThereObject = YES;
            break;
        }
    }

    if(isThereObject == NO) {
        // MARK :
        [arrayObjects addObject:[dictionary valueForKey:@"job_match_id"]];
        [[NSUserDefaults standardUserDefaults] setObject:arrayObjects forKey:@"jobMatchIds"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION object:nil userInfo:dictionary];
        return YES;
    } else {
        return NO;
    }
}

-(void)showMatchWindowWithObject:(NSDictionary *)dictionary
{
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRACMatchScreen *controller = [mystoryboard instantiateViewControllerWithIdentifier:@"WRACMatchScreenIdentifier"];
    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark Reachability Methods
-(void)configureReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    NetworkStatus remoteHostStatus = [self.internetReachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable) {self.isNetAvailable=NO; }
    else if (remoteHostStatus == ReachableViaWiFi) {self.isNetAvailable=YES;}
    else if (remoteHostStatus == ReachableViaWWAN) {self.isNetAvailable=YES;}
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    self.isNetAvailable=YES;
    switch (netStatus)
    {
        case NotReachable:
        {
            self.isNetAvailable=NO;
            UINavigationController *nav_controller = (UINavigationController *)self.window.rootViewController;
            [CustomAlertView showAlertWithTitle:NETWORK_ERROR_TITLE message:NETWORK_ERROR_MESSAGE OkButton:@"Try Again" delegate:[nav_controller topViewController]];
        }
            break;
        case ReachableViaWWAN:
        {
            self.isNetAvailable=YES;
            break;
        }
        case ReachableViaWiFi:
        {
            self.isNetAvailable=YES;
            break;
        }
        default:
        {
            self.isNetAvailable=NO;
        }
    }
}

@end
