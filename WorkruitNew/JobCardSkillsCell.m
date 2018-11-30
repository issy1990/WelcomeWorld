//
//  JobCardSkillsCell.m
//  workruit
//
//  Created by Admin on 1/21/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "JobCardSkillsCell.h"
#import "HeaderFiles.h"

@implementation JobCardSkillsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.skillsLable.textColor = UIColorFromRGB(0x2F2F2F);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
