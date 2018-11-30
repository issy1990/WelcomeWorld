//
//  CustomConversationsCell.h
//  workruit
//
//  Created by Admin on 10/8/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"


@interface CustomConversationsCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIImageView *profileImage;
@property (nonatomic,weak) IBOutlet UILabel *userNameLbl;
@property (nonatomic,weak) IBOutlet UILabel *jobTitleLbl;
@property (nonatomic,weak) IBOutlet UILabel *jobRoleLbl;
@property (nonatomic,weak) IBOutlet UILabel *jobDateLbl;
@property(nonatomic,weak) IBOutlet UIView *backGroundView;
@property (nonatomic,weak) IBOutlet UILabel *count_lbl;

@end
