//
//  NewTableViewCell.m
//  WorkruitNew
//
//  Created by Tech on 23-23-2017.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "NewTableViewCell.h"
#import "Constrant.h"

@implementation NewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
   _font = [UIFont fontWithName:GlobalFontRegular size:15];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
