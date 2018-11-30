//
//  WRPrefrenceListController.h
//  workruit
//
//  Created by Admin on 11/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "CustomPreferencesCell.h"


@interface WRPrefrenceListController : UIViewController
@property(nonatomic,weak) IBOutlet UILabel *headerTitleLbl;
@property(nonatomic,weak) IBOutlet UITableView *table_view;
@property(nonatomic,weak) IBOutlet UIView *no_jobs_view;
@property(nonatomic,weak) IBOutlet UIButton *save_button;
@property(nonatomic,readwrite) int flag;
@property(nonatomic,strong) NSString *wrlocation_jobString;

@end
