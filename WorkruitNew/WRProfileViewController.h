//
//  WRProfileViewController.h
//  workruit
//
//  Created by Admin on 10/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"


@interface WRProfileViewController : UIViewController
@property(nonatomic,strong) IBOutlet UITableView *table_view;
-(void)moveToPrefrencesScreen:(int )index;
-(void)moveToScreenByScreenId:(int)screen_id;
-(void)editButtonActionOnClick:(id)sender;
@end
