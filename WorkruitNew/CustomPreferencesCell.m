//
//  CustomPreferencesCell.m
//  workruit
//
//  Created by Admin on 11/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CustomPreferencesCell.h"

@implementation CustomPreferencesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.switchStat.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
