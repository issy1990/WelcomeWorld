//
//  WRJobCardDetailsViewController.h
//  workruit
//
//  Created by Admin on 11/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRJobCardDetailsViewController : UIViewController
@property(nonatomic,assign) NSMutableDictionary *profile_dictionary;
@property(nonatomic,weak) IBOutlet UITableView *table_view;
@property(nonatomic,weak) IBOutlet UIView *buttomView;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *buttom_constrant;

@property(nonatomic,readwrite) BOOL hideButtomBar;
@property(nonatomic,strong)NSString *comingFromChat;

//Back button action
-(IBAction)backButtonAction:(id)sender;

@end
