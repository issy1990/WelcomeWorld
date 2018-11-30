//
//  GetLocationTableViewCell.h
//  workruit
//
//  Created by Teja on 8/2/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
@interface GetLocationTableViewCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *titleLbl;
@property(nonatomic,weak) IBOutlet CustomTextField *ValueTF;

@property(nonatomic,weak) IBOutlet UIButton *cureentLocation;

@end
