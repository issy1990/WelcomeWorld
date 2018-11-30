//
//  ApplicantEditProfileMessageView.m
//  WorkruitNew
//
//  Created by Apple on 04/11/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "ApplicantEditProfileMessageView.h"

@implementation ApplicantEditProfileMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.completeButton.layer.cornerRadius = 5.0f;
    self.completeButton.layer.masksToBounds = YES;
    
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
}

@end
