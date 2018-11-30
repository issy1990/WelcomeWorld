//
//  WRAddExperianceController.h
//  workruit
//
//  Created by Admin on 10/13/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRAddExperianceController : UIViewController
@property(nonatomic,strong) NSMutableArray *titleArray;;
@property(nonatomic, weak) IBOutlet UITableView *table_view;
@property (nonatomic,weak) IBOutlet UILabel *headerLbl;
@property(nonatomic, readwrite) int Flag;
@property(nonatomic, readwrite) BOOL isFirstTime;
@property(nonatomic,strong) NSMutableDictionary *selectedDictionary;
@property(nonatomic,weak) IBOutlet UIButton *save_button;
@property(nonatomic,readwrite) int index;
@property(nonatomic,weak) IBOutlet UIButton *delete_button;
@property(nonatomic,readwrite) int screen_id;
@property(nonatomic,weak) IBOutlet UIView *footer_view;
@property(nonatomic,weak) IBOutlet UIButton *skipButton;
@property(nonatomic,readwrite) int commingfromeditprofile;


@end
