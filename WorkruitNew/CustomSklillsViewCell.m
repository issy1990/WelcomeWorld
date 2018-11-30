//
//  CustomSklillsViewCell.m
//  workruit
//
//  Created by Admin on 10/14/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CustomSklillsViewCell.h"

@implementation CustomSklillsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _tagsView.tagColor = UIColorFromRGB(0x337ab7);
    _tagsView.tagFont = [UIFont fontWithName:GlobalFontRegular size:15];
    
    _tagsView.scrollEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
