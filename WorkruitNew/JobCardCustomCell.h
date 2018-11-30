//
//  JobCardCustomCell.h
//  Workruit
//
//  Created by Admin on 9/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobCardCustomCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *expLbl, *roleLbl, *designationLbl,*dateLbl;
@property(nonatomic,weak) IBOutlet UILabel *place_holder;

@end
