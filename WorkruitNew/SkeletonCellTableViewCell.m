//
//  SkeletonCellTableViewCell.m
//  SampleApp
//
//  Created by Chandra on 12/31/17.
//  Copyright © 2017 Chandra. All rights reserved.
//

#import "SkeletonCellTableViewCell.h"

@implementation SkeletonCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imagePlaceholderView.layer.cornerRadius = self.imagePlaceholderView.frame.size.width/2;
    self.imagePlaceholderView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
