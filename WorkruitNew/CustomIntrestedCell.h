//
//  CustomIntrestedCell.h
//  workruit
//
//  Created by Admin on 10/8/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface CustomIntrestedCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIImageView *profileImage;
@property (nonatomic,weak) IBOutlet UILabel *userTitleLbl;
@property (nonatomic,weak) IBOutlet UILabel *jobTitleLbl;
@property (nonatomic,weak) IBOutlet UILabel *jobDateLbl;
@property (nonatomic,weak) IBOutlet UIView *backGroundView;
@property (nonatomic,weak) IBOutlet UILabel *expLabel;

@end
