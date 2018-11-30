//
//  WRApplicantEditProfile.h
//  workruit
//
//  Created by Admin on 10/13/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "YLProgressBar.h"

@interface WRApplicantEditProfile : UIViewController
@property(nonatomic, weak) IBOutlet UITableView *table_view;
@property(nonatomic,readwrite) int isCommingFromWhere;
@property(nonatomic,weak) IBOutlet UIButton *save_button;
@property(nonatomic,weak) IBOutlet UIButton *back_button;
@property (assign, nonatomic) IBInspectable CGFloat tagSpacing;



@end
