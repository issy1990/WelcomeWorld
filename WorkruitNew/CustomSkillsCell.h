//
//  CustomSkillsCell.h
//  workruit
//
//  Created by Admin on 10/7/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSkillsCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *titleLbl;
@property(nonatomic,weak) IBOutlet UIButton *addButton;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *widthConstant, *label_x_constrant, * button_x_constrant;

@end
