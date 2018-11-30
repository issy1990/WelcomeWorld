//
//  JobCardHeaderCellNew.m
//  workruit
//
//  Created by Admin on 5/6/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "JobCardHeaderCellNew.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation JobCardHeaderCellNew

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    double rads = DEGREES_TO_RADIANS(-45);
    self.intrestedLbl.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    self.intrestedLbl.transform = transform;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
