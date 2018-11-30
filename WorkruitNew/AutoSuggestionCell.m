//
//  AutoSuggestionCell.m
//  workruit
//
//  Created by Admin on 10/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "AutoSuggestionCell.h"

@implementation AutoSuggestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.ValueTF.autocorrectionType = UITextAutocorrectionTypeNo;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
