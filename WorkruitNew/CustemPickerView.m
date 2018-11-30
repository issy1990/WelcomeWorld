//
//  CustemPickerView.m
//  slog
//
//  Created by Jayprakash Kumar on 4/20/16.
//  Copyright © 2016 Jayprakash Kumar. All rights reserved.
//

#import "CustemPickerView.h"

// Identifiers of components
#define MONTH ( 0 )
#define YEAR ( 1 )

// Identifies for component views
#define LABEL_TAG 43
@interface CustemPickerView() {
    NSString *monthString;
    NSString *yearString;
    NSArray *fontName;
}

@property (nonatomic, strong) NSIndexPath *todayIndexPath,*selectedIndexPath;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;


-(NSArray *)nameOfYears;
-(NSArray *)nameOfMonths;
-(CGFloat)componentWidth;

-(UILabel *)labelForComponent:(NSInteger)component selected:(BOOL)selected;
-(NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component;
-(NSIndexPath *)todayPath;
-(NSInteger)bigRowMonthCount;
-(NSInteger)bigRowYearCount;
-(NSString *)currentMonthName;
-(NSString *)currentYearName;

@end

@implementation CustemPickerView

const NSInteger bigRowCount = 1000;
const NSInteger minYear = 1990;
NSInteger maxYear;
const CGFloat rowHeight = 44.f;
const NSInteger numberOfComponents = 2;

@synthesize todayIndexPath;
@synthesize months;
@synthesize years = _years;
@synthesize selectedDelegate;

-(id)init
{
    self = [super init];
    if (self)
    {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        
        [df setDateFormat:@"yyyy"];
        maxYear = [[df stringFromDate:[NSDate date]] integerValue];
        
        fontName = [UIFont fontNamesForFamilyName:@"Source Sans Pro"];
        self.months = [self nameOfMonths];
        self.years = [self nameOfYears];
        // self.todayIndexPath = [self todayPath];
        
        self.delegate = self;
        self.dataSource = self;
        [self setBackgroundColor:[UIColor whiteColor]];
        
        //[self selectToday];
        
    }
    
    return self;
}
-(NSDate *)date
{
    NSInteger monthCount = [self.months count];
    NSString *month = [self.months objectAtIndex:([self selectedRowInComponent:MONTH] % monthCount)];
    
    NSInteger yearCount = [self.years count];
    NSString *year = [self.years objectAtIndex:([self selectedRowInComponent:YEAR] % yearCount)];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; [formatter setDateFormat:@"MMM:yyyy"];
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%@:%@", month, year]];
    return date;
}

#pragma mark - UIPickerViewDelegate
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return [self componentWidth];
}

-(UIView *)pickerView: (UIPickerView *)pickerView
           viewForRow: (NSInteger)row
         forComponent: (NSInteger)component
          reusingView: (UIView *)view
{
    BOOL selected = NO;
    if(component == MONTH)
    {
        NSInteger monthCount = [self.months count];
        NSString *monthName = [self.months objectAtIndex:(row % monthCount)];
        NSString *currentMonthName = [self currentMonthName];
        if([monthName isEqualToString:currentMonthName] == YES)
        {
            selected = YES;
        }
    }
    else
    {
        NSInteger yearCount = [self.years count];
        NSString *yearName = [self.years objectAtIndex:(row % yearCount)];
        NSString *currenrYearName  = [self currentYearName];
        if([yearName isEqualToString:currenrYearName] == YES)
        {
            selected = YES;
        }
    }
    
    UILabel *returnView = nil;
    if(view.tag == LABEL_TAG)
    {
        returnView = (UILabel *)view;
    }
    else
    {
        returnView = [self labelForComponent: component selected: selected];
    }
    
    returnView.textColor = selected ? [UIColor blackColor] : [UIColor blackColor];
    returnView.text = [self titleForRow:row forComponent:component];
    return returnView;
}
#pragma mark- Picker View Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    
    
    if (component == MONTH)
    {
        NSInteger monthCount = [self.months count];
        monthString = [self.months objectAtIndex:(row % monthCount)];
    }
    else
    {
        NSInteger yearCount = [self.years count];
        yearString = [self.years objectAtIndex:(row % yearCount)];
    }
    NSString *finalString = [NSString stringWithFormat:@"%@ %@",monthString,yearString];
    [self.selectedDelegate selectedDate:finalString withView:self];
    
    
    
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return rowHeight;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return numberOfComponents;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == MONTH)
    {
        return 12;
    }
    return [self.years count];
}

#pragma mark - Util
-(NSInteger)bigRowMonthCount
{
    return [self.months count]  * bigRowCount;
}

-(NSInteger)bigRowYearCount
{
    return [self.years count]  * bigRowCount;
}

-(CGFloat)componentWidth
{
    return self.bounds.size.width / numberOfComponents;
}

-(NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == MONTH)
    {
        NSInteger monthCount = [self.months count];
        monthString = [self.months objectAtIndex:(row % monthCount)];
        return monthString;
    }
    NSInteger yearCount = [self.years count];
    yearString = [self.years objectAtIndex:(row % yearCount)];
    return yearString;
}

-(UILabel *)labelForComponent:(NSInteger)component selected:(BOOL)selected
{
    CGRect frame = CGRectMake(0.f, 0.f, [self componentWidth],rowHeight);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = selected ? [UIColor blackColor] : [UIColor blackColor];
    label.font = [UIFont fontWithName:[fontName lastObject] size:16.0];
    label.userInteractionEnabled = NO;
    
    label.tag = LABEL_TAG;
    
    return label;
}

-(NSArray *)nameOfMonths
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    return [dateFormatter shortMonthSymbols];
}

-(NSArray *)nameOfYears
{
    NSMutableArray *years = [NSMutableArray array];
    
    for(NSInteger year = minYear; year <= maxYear; year++)
    {
        NSString *yearStr = [NSString stringWithFormat:@"%li", (long)year];
        [years addObject:yearStr];
    }
    return years;
}

-(void)selectedDate:(NSIndexPath *)selectedIndex
{
    [self selectRow: selectedIndex.row
        inComponent: MONTH
           animated: NO];
    
    [self selectRow: selectedIndex.section
        inComponent: YEAR
           animated: NO];
}

-(NSIndexPath *)selectedPath:(NSString *)month1 Year:(NSString *)year1 // row - month ; section - year
{
    CGFloat row = 0.f;
    CGFloat section = 0.f;
    
    NSString *month = month1;
    NSString *year  = year1;
    
    //set table on the middle
    for(NSString *cellMonth in self.months)
    {
        if([cellMonth isEqualToString:month])
        {
            row = [self.months indexOfObject:cellMonth];
            // row = row + [self bigRowMonthCount] / 2;
            break;
        }
    }
    
    for(NSString *cellYear in self.years)
    {
        if([cellYear isEqualToString:year])
        {
            section = [self.years indexOfObject:cellYear];
            // section = section + [self bigRowYearCount] / 2;
            break;
        }
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}


-(void)selectToday:(NSIndexPath *)todayIndex
{
    [self selectRow: todayIndex.row
        inComponent: MONTH
           animated: NO];
    
    [self selectRow: todayIndex.section
        inComponent: YEAR
           animated: NO];
}

-(NSIndexPath *)todayPath // row - month ; section - year
{
    CGFloat row = 0.f;
    CGFloat section = 0.f;
    
    NSString *month = [self currentMonthName];
    NSString *year  = [self currentYearName];
    
    //set table on the middle
    for(NSString *cellMonth in self.months)
    {
        if([cellMonth isEqualToString:month])
        {
            row = [self.months indexOfObject:cellMonth];
            // row = row + [self bigRowMonthCount] / 2;
            break;
        }
    }
    
    for(NSString *cellYear in self.years)
    {
        if([cellYear isEqualToString:year])
        {
            section = [self.years indexOfObject:cellYear];
            // section = section + [self bigRowYearCount] / 2;
            break;
        }
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

-(NSString *)currentMonthName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM"];
    return [formatter stringFromDate:[NSDate date]];
}

-(NSString *)currentYearName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}

@end

