//
//  JobCardDetailExpCell.h
//  Workruit
//
//  Created by Admin on 9/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobCardDetailExpCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *leftOneLbl,*leftTwoLbl;
@property(nonatomic,weak) IBOutlet UILabel *rightOneLbl,*rightTwoLbl;
@property(nonatomic,weak) IBOutlet UILabel *place_holder_lable;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *label_x_constrant,*label_y_constrant , * second_label_y_constant, * second_label_x_constant;

@end
