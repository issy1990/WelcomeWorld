//
//  CustomSalarySilderCell.m
//  workruit
//
//  Created by Admin on 10/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CustomSalarySilderCell.h"

@implementation CustomSalarySilderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    //custom number formatter range slider
    self.rangeSliderCustom = [[TTRangeSlider alloc]initWithFrame:CGRectMake(15, 40, self.frame.size.width-40, 40)];
    self.rangeSliderCustom.delegate = self;
    self.rangeSliderCustom.minValue = 0;
    self.rangeSliderCustom.maxValue = 40;
    self.rangeSliderCustom.minDistance = 1;
    self.rangeSliderCustom.selectedMinimum = 0;
    self.rangeSliderCustom.selectedMaximum = 40;
    self.rangeSliderCustom.hideLabels = YES;
    self.rangeSliderCustom.handleImage = [UIImage imageNamed:@"sliderbutton"];
    self.rangeSliderCustom.selectedHandleDiameterMultiplier = 1;
    self.rangeSliderCustom.tintColorBetweenHandles = [UIColor colorWithRed:51.0/255.0 green:122.0/255.0 blue:183.0/255.0 alpha:1.0];
    self.rangeSliderCustom.tintColor = UIColorFromRGB(0xB5B5B5);
    self.rangeSliderCustom.lineHeight = 2;
    [self addSubview:self.rangeSliderCustom];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum
{
     self.valueLbl.text = [NSString stringWithFormat:@"%f - %f",selectedMinimum,selectedMaximum];
}


@end
