//
//  CustomIntrestedCell.m
//  workruit
//
//  Created by Admin on 10/8/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CustomIntrestedCell.h"

@implementation CustomIntrestedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.hidden = YES;
    
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
