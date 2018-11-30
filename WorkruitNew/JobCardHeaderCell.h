//
//  JobCardHeaderCell.h
//  Workruit
//
//  Created by Admin on 9/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobCardHeaderCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *nameLbl,*designationLbl;
@property(nonatomic,weak) IBOutlet UILabel *yearLbl,*locationLbl,*packageLbl;
@property(nonatomic,weak) IBOutlet UILabel *jobTitleLbl, *jobTypeLbl;
@property(nonatomic,weak) IBOutlet UIImageView *profile_image;
@property(nonatomic,weak) IBOutlet UILabel *intrestedLbl;
@property(nonatomic,weak) IBOutlet UILabel *jobPostedDateLabel;
@property(nonatomic,weak) IBOutlet UIButton *intrestedBtn,*recommededBtn;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *label_constrant, *dateLabel_constant;
@property(nonatomic,weak) IBOutlet UILabel *companyProfileLbl, * datePostedLbl;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *view_constrant, *view_contsrtant1;
@property(nonatomic,weak) IBOutlet UIView * backView;
@property(nonatomic,weak) IBOutlet UIImageView *jobDateImg;
@property(nonatomic,weak) IBOutlet UILabel * jobsite;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint * company_contstant, *company_constant1;
@end
