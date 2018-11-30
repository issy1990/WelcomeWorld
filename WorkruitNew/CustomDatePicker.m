//
//  CustomDatePicker.m
//  workruit
//
//  Created by Admin on 1/11/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "CustomDatePicker.h"
#import "HeaderFiles.h"

@implementation CustomDatePicker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(IBAction)cancelClicked:(id)sender
{
    [self hidePicker];
    
    self.isPickerShown = NO;
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didSelectDateWithDoneClicked:forTag:)]) {
        [self.delegate didSelectDateWithDoneClicked:nil forTag:nil];
        self.delegate=nil;
    }
}

//Done button clicked
-(IBAction)doneClicked:(id)sender
{
    self.isPickerShown = NO;
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didSelectDateWithDoneClicked:forTag:)]) {
        [self.delegate didSelectDateWithDoneClicked:[Utility getStringWithDate:self.date_picker.date withFormat:@"MMM yyyy"] forTag:self.date_picker.date];
        self.delegate=nil;
    }
    
    if([self.done_button.titleLabel.text isEqualToString:@"Done"])
        [self hidePicker];
}

-(void)showPicker
{
    self.isPickerShown = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setFrame:CGRectMake(0, self.view_height-257, self.frame.size.width, 257)];
        
    } completion:^(BOOL finished) {
    }];
}
-(void)hidePicker
{
    self.isPickerShown = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setFrame:CGRectMake(0, self.view_height, self.frame.size.width, 257)];
        
    } completion:^(BOOL finished) {
    }];
    
}



-(void)awakeFromNib
{
    [super awakeFromNib];
    
    if(self.isNextButtonVisible == 1)
        [self.done_button setTitle:@"Next" forState:UIControlStateNormal];
    
    self.date_picker.maximumDate = [NSDate date];
    self.divider.frame = CGRectMake(0, 0, self.frame.size.width, 0.5);
}

@end
