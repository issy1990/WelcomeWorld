//
//  AppDelegate.h
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "CWStatusBarNotification.h"
#import "Reachability.h"
#import "ApplicantHelper.h"
#import "LNNotificationsUI.h"

@import Firebase;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,strong) CWStatusBarNotification *notification_container;
@property(assign,nonatomic) BOOL isNetAvailable;
@property (nonatomic,strong) Reachability *internetReachability;
@property(nonatomic,strong) NSString *current_channel;
@property(nonatomic,strong) NSString *current_user_id;
@property(nonatomic,strong) NSString *current_regId;
@property(nonatomic,readwrite) BOOL isCommingFromNotification;
@property(nonatomic,readwrite) NSInteger unreadConversationCount;

-(void)confrigrationPushNotification;
-(void)showMessage:(NSString *)message withPayLoad:(NSMutableDictionary *)payLoad;
-(void)clearAllNotifications;
-(void)getLoginStatusFromServer;
-(void)updateUnreadCount;

@end

