//
//  ProfilePictureHeader.h
//  workruit
//
//  Created by Admin on 10/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
@interface ProfilePictureHeader : UIView
@property(nonatomic,weak) IBOutlet UIImageView *profile_image;
@property(nonatomic,weak) IBOutlet UILabel *nameLbl;
@property(nonatomic,weak) IBOutlet UIButton *editButtonAction;
@end
