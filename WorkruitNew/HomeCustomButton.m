//
//  HomeCustomButton.m
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "HomeCustomButton.h"

@implementation HomeCustomButton

-(void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.masksToBounds = YES;
}

@end
