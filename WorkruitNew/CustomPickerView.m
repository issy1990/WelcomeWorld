//
//  CustomPickerView.m
//  workruit
//
//  Created by Admin on 1/8/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "CustomPickerView.h"
#import "HeaderFiles.h"

@implementation CustomPickerView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//Cancel button clicked
-(IBAction)cancelClicked:(id)sender
{
    [self hidePicker];
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didSelectPickerWithDoneClicked:forTag:)]) {
        [self.delegate didSelectPickerWithDoneClicked:nil forTag:-1];
        self.delegate=nil;
    }
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didSelectPickerWithDoneClicked:withSubRow:forTag:)]){
        [self.delegate didSelectPickerWithDoneClicked:nil withSubRow:nil forTag:-1];
        self.delegate=nil;
    }
}

//Done button clicked
-(IBAction)doneClicked:(id)sender
{
    if (self.numberOfComponents == 1)
    {
        if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didSelectPickerWithDoneClicked:forTag:)])
        {
            [self.delegate didSelectPickerWithDoneClicked:[self.objectsArray objectAtIndex:[self.picker_view selectedRowInComponent:0]] forTag:(int)[self.picker_view selectedRowInComponent:0]];
            self.delegate=nil;
        }
    }
    else{
        
        if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didSelectPickerWithDoneClicked:withSubRow:forTag:)]){
            
            NSString *componentOne = [self.objectsArray objectAtIndex:[self.picker_view selectedRowInComponent:0]];
            
            NSString *componentTwo = self.subObjectsArray.count > 0 ? [self.subObjectsArray objectAtIndex:[self.picker_view selectedRowInComponent:1]]:@"";
            
            [self.delegate didSelectPickerWithDoneClicked:componentOne withSubRow:componentTwo forTag:(int)[self.picker_view selectedRowInComponent:0]];
            self.delegate=nil;
        }
        
    }
     [self hidePicker];
}

-(void)showPicker
{
    [UIView animateWithDuration:0.15 animations:^{
        [self setFrame:CGRectMake(0, self.view_height-257, self.frame.size.width, 257)];
        
    } completion:^(BOOL finished) {
    }];
}
-(void)hidePicker
{
    [UIView animateWithDuration:0.15 animations:^{
        [self setFrame:CGRectMake(0, self.view_height, self.frame.size.width, 257)];

    } completion:^(BOOL finished) {
    }];

}
-(void)awakeFromNib
{
    [super awakeFromNib];

    if(self.isNextButtonVisible == 1)
            [self.done_button setTitle:@"Next" forState:UIControlStateNormal];
        
    self.divider.frame = CGRectMake(0, 0, self.frame.size.width, 0.5);
    
    self.numberOfComponents = 1;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.numberOfComponents;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return component == 0?_objectsArray.count:_subObjectsArray.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    _selected_index = 0;
    return component == 0?[_objectsArray objectAtIndex:row]:[_subObjectsArray objectAtIndex:row];
}


//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
//{
//    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 150, 40)];
//    lbl.text = [_objectsArray objectAtIndex:row];
//    lbl.textAlignment = NSTextAlignmentCenter;
//    lbl.font = [UIFont fontWithName:GlobalFontSemibold size:22.0f];
//    return lbl;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selected_index = (int)row;
}

@end
