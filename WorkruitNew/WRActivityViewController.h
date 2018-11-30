//
//  WRActivityViewController.h
//  workruit
//
//  Created by Admin on 10/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRActivityViewController : UIViewController
{}
@property(nonatomic,strong) IBOutlet UITableView *table_view;
@property(nonatomic,strong) IBOutlet UISegmentedControl *segmentController;
@property(nonatomic,readwrite) BOOL isConversationFlag;
@property(nonatomic,weak) IBOutlet UIImageView *skeleton_Image;

@property(nonatomic,weak) IBOutlet UIView *message_view;
@property(nonatomic,weak) IBOutlet UILabel *titleLbl, *messageLbl;

-(void)navigateToConverstaionScreenOnReciveMatch:(NSMutableDictionary *)dictionary;

-(IBAction)onClickNotificationChange:(int)flag;

-(void)onFCMNotificationClicked:(NSDictionary *)notification;

@end
