//
//  CustomSalarySilderCell.h
//  workruit
//
//  Created by Admin on 10/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "TTRangeSlider.h"

@interface CustomSalarySilderCell : UITableViewCell <TTRangeSliderDelegate>
@property(nonatomic,strong) TTRangeSlider *rangeSliderCustom;
@property(nonatomic,weak) IBOutlet UILabel *titleLbl;
@property(nonatomic,weak) IBOutlet UILabel *valueLbl;

@end
