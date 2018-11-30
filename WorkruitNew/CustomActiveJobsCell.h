//
//  CustomActiveJobsCell.h
//  WorkruitNew
//
//  Created by Chandra on 12/31/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomActiveJobsCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *userTitleLbl;
@property (nonatomic,weak) IBOutlet UILabel *jobTitleLbl;
@property (nonatomic,weak) IBOutlet UILabel *jobDateLbl;
@property (nonatomic,weak) IBOutlet UIView *backGroundView;
@property (nonatomic,weak) IBOutlet UILabel *expLabel;
@end
