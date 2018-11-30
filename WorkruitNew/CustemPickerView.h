//
//  CustemPickerView.h
//  slog
//
//  Created by Jayprakash Kumar on 4/20/16.
//  Copyright © 2016 Jayprakash Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol selectedDate <NSObject>

-(void)selectedDate:(NSString*)str withView:(UIPickerView*)picker;

@end

@interface CustemPickerView : UIPickerView <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic) id <selectedDate> selectedDelegate;

-(id)init;
-(void)selectedDate:(NSIndexPath *)selectedIndex;
-(NSIndexPath *)selectedPath:(NSString *)month1 Year:(NSString *)year1;
-(NSIndexPath *)todayPath;
-(void)selectToday:(NSIndexPath *)todayIndex;

@end
