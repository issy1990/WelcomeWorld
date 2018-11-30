//
//  CardDetailsViewController.h
//  Workruit
//
//  Created by Admin on 9/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRCardDetailsViewController : UIViewController
@property(nonatomic,strong) NSMutableDictionary *profile_dictionary;
@property(nonatomic,weak)IBOutlet UILabel *header_title;
@property(nonatomic,weak) IBOutlet UIView *buttomView;
@property(nonatomic,weak) IBOutlet UITableView *table_view;
@property(nonatomic,readwrite) BOOL hideButtomBar;
@property(nonatomic,assign) NSMutableArray *profileListArray;
@property(nonatomic,strong)NSString *comingFromChat;
@property(nonatomic,assign)BOOL viewingInterestedProfileDetail;

@property(nonatomic,strong)NSString *chatObjectDataComing;

@property(nonatomic,weak) IBOutlet NSLayoutConstraint *buttom_constrant;

//Back button action
-(IBAction)backButtonAction:(id)sender;

//Like or pass button action
-(IBAction)likeORpassAction:(id)sender;
@end
