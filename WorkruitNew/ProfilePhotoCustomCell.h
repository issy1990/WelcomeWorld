//
//  ProfilePhotoCustomCell.h
//  workruit
//
//  Created by Admin on 10/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface ProfilePhotoCustomCell : UITableViewCell
@property(nonatomic,weak)  IBOutlet UIImageView *profile_image;
@property(nonatomic,weak) IBOutlet UIButton *buttonAction;
@end
