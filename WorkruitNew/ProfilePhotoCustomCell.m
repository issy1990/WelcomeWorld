//
//  ProfilePhotoCustomCell.m
//  workruit
//
//  Created by Admin on 10/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ProfilePhotoCustomCell.h"

@implementation ProfilePhotoCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.profile_image.layer.cornerRadius = self.profile_image.frame.size.width/2;
    self.profile_image.layer.masksToBounds = YES;
    
    if([Utility isComapany]){
        //      self.profile_image.placeholderImage = [UIImage imageNamed:@"company_placeholder"];
           self.profile_image.image = [UIImage imageNamed:@"company_placeholder"];
    }else{
        //self.profile_image.placeholderImage = [UIImage imageNamed:@"aplicant_placeholder"];
        self.profile_image.image = [UIImage imageNamed:@"aplicant_placeholder"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
