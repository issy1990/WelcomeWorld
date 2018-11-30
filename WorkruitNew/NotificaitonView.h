//
//  NotificaitonView.h
//  workruit
//
//  Created by Admin on 12/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStatusBarNotification.h"

@interface NotificaitonView : UIView
@property(nonatomic,weak) IBOutlet UIView *bgView;
@property(nonatomic,weak) IBOutlet UILabel *message;
@property(nonatomic,weak) IBOutlet UILabel *title;
@property(nonatomic,weak) IBOutlet UIImageView *app_icon_img;
@property(nonatomic,strong) NSMutableDictionary *payload;
@property(nonatomic,assign) CWStatusBarNotification *notification_container;

-(IBAction)notificationDidClicked:(id)sender;
@end
