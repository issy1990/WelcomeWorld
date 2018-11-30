//
//  JobCardTextViewCell.m
//  Workruit
//
//  Created by Admin on 9/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "JobCardTextViewCell.h"

@implementation JobCardTextViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.text_view.editable = NO;
    self.text_view.scrollEnabled = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
