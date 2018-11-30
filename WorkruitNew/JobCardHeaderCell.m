//
//  JobCardHeaderCell.m
//  Workruit
//
//  Created by Admin on 9/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "JobCardHeaderCell.h"
#import "HeaderFiles.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation JobCardHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
  
    self.intrestedBtn.layer.cornerRadius=3.0;
    self.recommededBtn.layer.cornerRadius=3.0;
    self.recommededBtn.hidden = YES;
    
    self.profile_image.layer.cornerRadius = self.profile_image.frame.size.height/2;
    self.profile_image.layer.masksToBounds = YES;

    double rads = DEGREES_TO_RADIANS(-45);
    self.intrestedLbl.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    self.intrestedLbl.transform = transform;
  
     self.nameLbl.textColor = UIColorFromRGB(0x2F2F2F);
     self.jobPostedDateLabel.textColor = UIColorFromRGB(0x2F2F2F);
     self.designationLbl.textColor = UIColorFromRGB(0x6A6A6A);
     self.companyProfileLbl.textColor = UIColorFromRGB(0x6A6A6A);
    
    // Initialization code
    if([Utility isComapany])
    {
        self.jobTypeLbl.hidden = YES;
        self.jobTitleLbl.hidden =  YES;
        self.jobPostedDateLabel.hidden = YES;
        self.datePostedLbl.hidden=YES;
        self.companyProfileLbl.hidden=YES;
        self.jobDateImg.hidden = YES;
    }else{
        self.designationLbl.font = [UIFont fontWithName:GlobalFontRegular size:15];
        self.jobTypeLbl.hidden = NO;
        self.jobTitleLbl.hidden =  NO;
        self.jobPostedDateLabel.hidden = NO;
        self.datePostedLbl.hidden=NO;
        self.companyProfileLbl.hidden=NO;
        self.jobDateImg.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
