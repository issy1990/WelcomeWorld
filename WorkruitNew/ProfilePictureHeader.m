//
//  ProfilePictureHeader.m
//  workruit
//
//  Created by Admin on 10/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ProfilePictureHeader.h"

@implementation ProfilePictureHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    if([Utility isComapany]){
        [self.editButtonAction setTitle:@"Edit Company Profile" forState:UIControlStateNormal];
        self.profile_image.image = [UIImage imageNamed:@"company_placeholder"];
    }
    else{
        [self.editButtonAction setTitle:@"Edit Profile" forState:UIControlStateNormal];
        self.profile_image.image = [UIImage imageNamed:@"aplicant_placeholder"];
    }
}

@end
