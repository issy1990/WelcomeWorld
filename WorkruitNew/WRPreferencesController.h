//
//  WRPreferencesController.h
//  workruit
//
//  Created by Admin on 11/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "CustomPreferencesCell.h"

@interface WRPreferencesController : UIViewController
@property(nonatomic,readwrite) int flag;
@property(nonatomic,weak) IBOutlet UIButton *save_button;

@property(nonatomic,weak) IBOutlet UITableView *table_view;

@property(nonatomic,strong) IBOutlet NSMutableArray *jobsArray;
@end
