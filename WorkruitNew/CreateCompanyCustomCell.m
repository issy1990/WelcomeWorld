//
//  CreateCompanyCustomCell.m
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CreateCompanyCustomCell.h"


@implementation CreateCompanyCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.ValueTF.font = [UIFont fontWithName:GlobalFontRegular size:16.0f];
    self.ValueTF.autocorrectionType = UITextAutocorrectionTypeNo;
    
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

}

@end
