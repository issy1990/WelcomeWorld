//
//  SettingCustomCell.h
//  workruit
//
//  Created by Admin on 10/9/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingCustomCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *titleLbl;
@property(nonatomic,weak) IBOutlet UIButton *mail_button, *mobile_button;
@end
