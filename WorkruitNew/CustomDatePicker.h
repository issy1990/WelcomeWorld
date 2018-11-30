//
//  CustomDatePicker.h
//  workruit
//
//  Created by Admin on 1/11/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomDateViewDelegate;
@protocol CustomDateViewDelegate <NSObject>
@optional
-(void)didSelectDateWithDoneClicked:(NSString *)value forTag:(NSDate *)date;
@end
@interface CustomDatePicker : UIView
@property(nonatomic,weak) IBOutlet UIDatePicker *date_picker;
@property(nonatomic,readwrite) int isNextButtonVisible;
@property(nonatomic,readwrite) int selectedIndex;
@property(nonatomic,weak) IBOutlet UIButton *done_button, *cancel_button;
@property(nonatomic,readwrite) int view_height;
@property(nonatomic,assign)  id delegate;
@property(nonatomic,readwrite)  BOOL isPickerShown;
@property(nonatomic,weak) IBOutlet UIView *divider;


-(void)showPicker;
-(void)hidePicker;

-(IBAction)cancelClicked:(id)sender;
-(IBAction)doneClicked:(id)sender;

@end
