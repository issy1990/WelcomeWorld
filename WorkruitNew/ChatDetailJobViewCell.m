//
//  ChatDetailJobViewCell.m
//  workruit
//
//  Created by Teja on 9/8/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "ChatDetailJobViewCell.h"
#import "HeaderFiles.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@implementation ChatDetailJobViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.profile_image.layer.cornerRadius = self.profile_image.frame.size.height/2;
    self.profile_image.layer.masksToBounds = YES;
    
    double rads = DEGREES_TO_RADIANS(-45);
    self.intrestedLbl.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    self.intrestedLbl.transform = transform;
    
    // Initialization code
    if([Utility isComapany]){
        self.jobTypeLbl.hidden = YES;
        self.jobTitleLbl.hidden =  YES;
        self.profile_image.image = [UIImage imageNamed:@"aplicant_placeholder"];
    }else{
        self.jobTypeLbl.hidden = NO;
        self.jobTitleLbl.hidden =  NO;
        self.profile_image.image = [UIImage imageNamed:@"company_placeholder"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
