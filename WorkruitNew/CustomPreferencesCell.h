//
//  CustomPreferencesCell.h
//  workruit
//
//  Created by Admin on 11/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPreferencesCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *titleLbl, *detailLbl;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *width_constrant;
@property(nonatomic,weak) IBOutlet UISwitch * switchStat;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint * bottomConst,* trainlingConst;
@end
