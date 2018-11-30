//
//  CustomPickerView.h
//  workruit
//
//  Created by Admin on 1/8/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomPickerViewDelegate;
@protocol CustomPickerViewDelegate <NSObject>
@optional
-(void)didSelectPickerWithDoneClicked:(NSString *)value forTag:(int)tag;
-(void)didSelectPickerWithDoneClicked:(NSString *)value withSubRow:(NSString *)subValue forTag:(int)tag;
@end

@interface CustomPickerView : UIView<UIPickerViewDelegate>
@property(nonatomic,weak) IBOutlet UIPickerView *picker_view;
@property(nonatomic,weak) IBOutlet UIView *divider;
@property(nonatomic,strong) NSMutableArray *objectsArray;
@property(nonatomic,strong) NSMutableArray *subObjectsArray;
@property(nonatomic,readwrite) int isNextButtonVisible;
@property(nonatomic,readwrite) int selectedIndex;
@property(nonatomic,weak) IBOutlet UIButton *done_button, *cancel_button;
@property(nonatomic,readwrite) int view_height;
@property(nonatomic,assign)  id delegate;
@property(nonatomic,readwrite) int selected_index;
@property(nonatomic,readwrite) int numberOfComponents;

-(void)showPicker;
-(void)hidePicker;

-(IBAction)cancelClicked:(id)sender;
-(IBAction)doneClicked:(id)sender;
@end
