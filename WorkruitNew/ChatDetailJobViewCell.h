//
//  ChatDetailJobViewCell.h
//  workruit
//
//  Created by Teja on 9/8/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatDetailJobViewCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *nameLbl,*designationLbl,*mainLbl;
@property(nonatomic,weak) IBOutlet UILabel *yearLbl,*locationLbl,*packageLbl,*titleLbl;
@property(nonatomic,weak) IBOutlet UILabel *jobTitleLbl, *jobTypeLbl;
@property(nonatomic,weak) IBOutlet UIImageView *profile_image;
@property(nonatomic,weak) IBOutlet UILabel *intrestedLbl;
@property(nonatomic,weak) IBOutlet UILabel *jobPostedDateLabel;


@end
