//
//  CustomActiveJobsCell.m
//  WorkruitNew
//
//  Created by Chandra on 12/31/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "CustomActiveJobsCell.h"

@implementation CustomActiveJobsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.userTitleLbl setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
    [self.jobTitleLbl setTextColor:[UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1]];
    [self.jobDateLbl setTextColor:[UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1]];
    [self.expLabel setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
