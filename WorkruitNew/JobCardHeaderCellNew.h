//
//  JobCardHeaderCellNew.h
//  workruit
//
//  Created by Admin on 5/6/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JobCardHeaderCellNew.h"

@interface JobCardHeaderCellNew : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *nameLbl,*designationLbl;
@property(nonatomic,weak) IBOutlet UILabel *yearLbl,*locationLbl,*packageLbl;
@property(nonatomic,weak) IBOutlet UILabel *jobTitleLbl, *jobTypeLbl;
@property(nonatomic,weak) IBOutlet UIImageView *profile_image;
@property(nonatomic,weak) IBOutlet UILabel *intrestedLbl;
@property(nonatomic,weak) IBOutlet UIButton *intrestedBtn,*recommededBtn;
@end
