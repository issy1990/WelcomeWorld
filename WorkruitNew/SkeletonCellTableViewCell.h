//
//  SkeletonCellTableViewCell.h
//  SampleApp
//
//  Created by Chandra on 12/31/17.
//  Copyright © 2017 Chandra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SkeletonCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imagePlaceholderView;
@property (weak, nonatomic) IBOutlet UIView *titlePlaceholderView;
@property (weak, nonatomic) IBOutlet UIView *subtitlePlaceholderView;

@end
