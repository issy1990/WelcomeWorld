//
//  CustomConversationsCell.m
//  workruit
//
//  Created by Admin on 10/8/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CustomConversationsCell.h"

@implementation CustomConversationsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    self.profileImage.layer.masksToBounds = YES;
    
    self.count_lbl.layer.cornerRadius = self.count_lbl.frame.size.width/2;
    self.count_lbl.layer.masksToBounds = YES;
    
    [self.userNameLbl setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
    [self.jobTitleLbl setTextColor:[UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1]];
    [self.jobDateLbl setTextColor:[UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1]];
    [self.jobRoleLbl setTextColor:[UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];    
}
@end
