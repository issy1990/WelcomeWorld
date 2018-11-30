//
//  WRSkillsViewController.h
//  workruit
//
//  Created by Admin on 10/13/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRSkillsViewController : UIViewController
@property(nonatomic, weak) IBOutlet UITableView *table_view;
@property (nonatomic,weak) IBOutlet UILabel *headerLbl;
@property(nonatomic,weak) IBOutlet UIButton *save_button;
@property(nonatomic,readwrite) BOOL isCommingFromEditContact;
@property(nonatomic,strong) NSMutableArray *suggestedSkillsArray;

@end
