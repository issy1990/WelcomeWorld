//
//  WRAccountsViewController.h
//  workruit
//
//  Created by Admin on 10/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"



@interface WRAccountsViewController : UIViewController

@property(nonatomic,strong) IBOutlet UITableView *table_view;
//Save button
@property(nonatomic,weak) IBOutlet UIButton *save_button;
@end
