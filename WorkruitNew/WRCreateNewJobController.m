//
//  WRCreateNewJobController.m
//  workruit
//
//  Created by Admin on 10/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

#import "WRCreateNewJobController.h"
#import "NewTableViewCell.h"



@interface WRCreateNewJobController ()<UITextFieldDelegate,UITextViewDelegate,TTRangeSliderDelegate,SAVETags_Delegate,AlertViewDelegate_Custom_Delegate>
{
    NSArray *first_section_array;
    NSArray *section_header_title_array;
    
    UILabel *experianceLbl,*salaryLbl;
    
    ASJTagsView *tagsViewTemp;
    CustomTextViewCell *local_text_view_cell;
    CustomTextField *selected_text_field;
    CustomPickerView *picker_object;
    CustomDatePicker *date_picker_object;
    
    BOOL isPickerShown;
    BOOL showIntenshipOptions;
    BOOL unPaidOptions;
    
    BOOL isEditJob;
    
    BOOL isClosedJob;
    BOOL isPendingJob;

    UIView *tagsView;
    
   
    UIScrollView * scrollView;
    NSMutableArray * minExpArray;
    NSMutableArray * maxExpArray;
    NSMutableArray * minsalaryArray;
    NSMutableArray * maxsalaryArray;
    IBOutlet UIView * myView;
}
@end

@implementation WRCreateNewJobController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    tagsView = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [FireBaseAPICalls captureScreenDetails:CREATE_JOB];
    
    scrollView =[[UIScrollView alloc]init];

    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [picker_object hidePicker];
    picker_object = nil;
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height)+64, 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height)+44, 0.0);
    }
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.table_view.contentInset = contentInsets;
        self.table_view.scrollIndicatorInsets = contentInsets;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.table_view.contentInset = UIEdgeInsetsZero;
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}


-(void)didSelectWithTags:(NSMutableArray *)array
{
    [self.cjCompanyObject.createJobParams setObject:array forKey:@"skills"];
    [self.table_view reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //wr_more
    self.table_view.sectionHeaderHeight = 0.0;
    self.table_view.sectionFooterHeight = 0.0;

    self.cjCompanyObject = [[CJCompanyHelper alloc] init];
    self.cjCompanyObject.createJobParams = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    
    if([[self.selectedDictionary valueForKey:@"status"] intValue] == 3)
    {
         isClosedJob = YES;
    }
    else if(!self.selectedDictionary || [[self.selectedDictionary valueForKey:@"status"] intValue] == 1)
    {
        isPendingJob = YES;
    }
    
    
    
    //Default Value params
    
    if(self.selectedDictionary)
    {
        if([[self.selectedDictionary valueForKey:@"status"] intValue] == 2)
        {
            [self.save_button setImage:[UIImage imageNamed:@"wr_more"] forState:UIControlStateNormal];
            [self.save_button setTitle:@""  forState:UIControlStateNormal];
            self.save_button.tag = 1000;
        }else
            self.save_button.hidden = YES;
        
        
        self.cjCompanyObject.createJobParams = self.selectedDictionary;
        int jb_id = [[[self.selectedDictionary valueForKey:@"jobFunction"] objectAtIndex:0] intValue];
        NSString *jobFunction_name = [CJCompanyHelper getJobRoleIdWithidx:jb_id parantKey:@"jobFunctions" childKey:@"jobFunctionId" withValueKey:@"jobFunctionName"];
        [self.cjCompanyObject.createJobParams setObject:jobFunction_name forKey:@"jobFunction_name"];
        self.header_lbl.text = @"Edit Job";
        
        unPaidOptions =  [[self.selectedDictionary valueForKey:@"unpaid"] boolValue];
        
        if([[self.selectedDictionary valueForKeyPath:@"jobType.jobTypeTitle"] isEqualToString:@"Internship"])
            showIntenshipOptions = YES;
        else
            showIntenshipOptions = NO;
        
    }else{
        self.header_lbl.text = @"Create Job";
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithInt:0] forKey:@"unpaid"];
        
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithFloat:0] forKey:@"experienceMin"];
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithFloat:5] forKey:@"experienceMax"];
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithFloat:0] forKey:@"salaryMin"];
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithFloat:10] forKey:@"salaryMax"];
        
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithInt:1] forKey:@"status"];
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithInt:0] forKey:@"hideSalary"];
    }
    
    //Setting the table view footer view to zeero
    
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    bgView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.table_view.tableFooterView = bgView;
    
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    first_section_array  =  [[NSArray alloc] initWithObjects:@"Title",@"Job Function",@"Location", nil];
    section_header_title_array = [[NSArray alloc] initWithObjects:@"JOB INFORMATION",@"JOB TYPE",@"EXPERIENCE",@"SALARY",@"JOB DESCRIPTION",@"SKILLS", nil];

    
    minExpArray =[[NSMutableArray alloc]initWithObjects:@"--",@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19", nil];
    
    maxExpArray =[[NSMutableArray alloc]initWithObjects:@"--",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20", nil];

     minsalaryArray =[[NSMutableArray alloc]initWithObjects:@"--",@"0L",@"1L",@"2L",@"3L",@"4L",@"5L",@"6L",@"7L",@"8L",@"9L",@"10L",@"11L",@"12L",@"13L",@"14L",@"15L",@"16L",@"17L",@"18L",@"19L",@"20L",@"21L",@"22L",@"23L",@"24L",@"25L",@"26L",@"27L",@"28L",@"29L",@"30L",@"31L",@"32L",@"33L",@"34L",@"35L",@"36L",@"37L",@"38L",@"39L",@"40L",@"41L",@"42L",@"43L",@"44L",@"45L",@"46L",@"47L",@"48L",@"49L", nil];
    
    maxsalaryArray =[[NSMutableArray alloc]initWithObjects:@"--",@"1L",@"2L",@"3L",@"4L",@"5L",@"6L",@"7L",@"8L",@"9L",@"10L",@"11L",@"12L",@"13L",@"14L",@"15L",@"16L",@"17L",@"18L",@"19L",@"20L",@"21L",@"22L",@"23L",@"24L",@"25L",@"26L",@"27L",@"28L",@"29L",@"30L",@"31L",@"32L",@"33L",@"34L",@"35L",@"36L",@"37L",@"38L",@"39L",@"40L",@"41L",@"42L",@"43L",@"44L",@"45L",@"46L",@"47L",@"48L",@"49L",@"50L", nil];

    
    [self.table_view reloadData];
    
    [Utility setThescreensforiPhonex:myView];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)viewDidAppear:(BOOL)animated
{
    if(self.selectedDictionary == nil)
    {
        [self performSelector:@selector(KeyboardStarted:) withObject:nil afterDelay:0.1];
    }
}
-(void)KeyboardStarted:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger i = [sender tag];
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CreateCompanyCustomCell * nextCell = [self.table_view cellForRowAtIndexPath:nextIndexPath];
        if ([[first_section_array objectAtIndex:i] isEqualToString:@"Title"])
        {
            [nextCell.ValueTF becomeFirstResponder];
        }
    });
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 40.0f;
    else if(section == 2){
        if(showIntenshipOptions)
            return 0.01;
        else
            return 40.0f;
    }else if(section == 3){
        if(unPaidOptions)
            return 0.01;
        else
            return 40.0f;
    }else if (section == 1) {
        if (isPendingJob) {
            return 40.0;
        } else {
            return 40.0;
        }
    } else {
        return 40.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-30, 30)];
    bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    lbl.frame = CGRectMake(15, 5, self.view.frame.size.width-30, 30);
    
    if(section == 0)
        lbl.text = @"JOB INFORMATION";
    else if(section == 1)
        lbl.text = @"JOB TYPE";
    else if(section == 2){
        if(showIntenshipOptions)
        {
            lbl.text = @"";
            return nil;
        }else{
            lbl.text = @"EXPERIENCE";
        }
    }else if(section == 3){
        
        if(unPaidOptions){
            lbl.text = @"";
            return nil;
        }else
            lbl.text = @"SALARY";
        
    }else if(section == 4)
        lbl.text = @"JOB DESCRIPTION";
    else if(section == 5)
        lbl.text = @"SKILLS";
    
    lbl.textColor = UIColorFromRGB(0x6A6A6A);
    bgView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    lbl.font = [UIFont fontWithName:GlobalFontSemibold size:12];
    [bgView addSubview:lbl];
    return bgView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2){
        if(showIntenshipOptions)
            return 0.0f;
        else
            return CELL_HEIGHT;
    }else if(indexPath.section == 3){
        if(unPaidOptions)
            return 0.0f;
        else{
            if(indexPath.row == 0)
                return CELL_HEIGHT;
            else
                return CELL_HEIGHT;
        }
    }else if(indexPath.section == 4)
        return 225.0f;
    else if(indexPath.section == 5){
        NSMutableArray *skillsArray =  [self.cjCompanyObject.createJobParams valueForKey:@"skills"];
          if([skillsArray count] > 0 && indexPath.row == 1)
            return scrollView.contentSize.height+10;
        else
            return CELL_HEIGHT;
    }else if (indexPath.section == 1) {
        if (isPendingJob) {
            return CELL_HEIGHT;
        } else {
            return CELL_HEIGHT;
        }
    } else if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            if (isPendingJob) {
                return CELL_HEIGHT;
            } else {
                return CELL_HEIGHT;
            }
        } else {
            return CELL_HEIGHT;
        }
    } else {
        return CELL_HEIGHT;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return first_section_array.count;
    else if(section == 3)
        return 2;
    else if(section == 5){
        
        NSMutableArray *skillsArray =  [self.cjCompanyObject.createJobParams valueForKey:@"skills"];
        
        if([skillsArray count] > 0)
            return 2;
        else
            return 1;
    }else if(section == 1){
        if(showIntenshipOptions)
            return 4;
        else
            return 1;
    }
    else return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 )
    {
        static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
        CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
            cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        }
        
        cell.backgroundColor = [UIColor whiteColor];
        cell.ValueTF.textColor = MainTextColor;
        cell.userInteractionEnabled = YES;
        
        cell.ValueTF.delegate = self;
        cell.ValueTF.row = indexPath.row;
        cell.ValueTF.section = indexPath.section;
        if(indexPath.section == 0)
        {
            cell.titleLbl.text = [first_section_array objectAtIndex:indexPath.row];
            switch (indexPath.row)
            {
                case 0:
                    cell.ValueTF.text = [self.cjCompanyObject.createJobParams valueForKey:@"title"];
                    cell.ValueTF.placeholder = @"Enter title";
                    cell.ValueTF.enabled  = YES;
                    break;
                case 1:{
                    if(self.selectedDictionary)
                    {
                         if(isPendingJob)
                         {
                             cell.userInteractionEnabled = YES;
                             cell.ValueTF.enabled  = YES;
                             cell.ValueTF.textColor = MainTextColor;
                         }
                         else
                         {
                             cell.userInteractionEnabled = NO;
                             cell.ValueTF.enabled  = NO;
                             cell.ValueTF.textColor = [UIColor lightGrayColor];
                         }
                    }
                    else
                    cell.ValueTF.enabled  = YES;
                    cell.ValueTF.text = [self.cjCompanyObject.createJobParams valueForKey:@"jobFunction_name"];
                    cell.ValueTF.placeholder = @"Select job function";
                }break;
                case 2:
                    cell.ValueTF.text = [[self.cjCompanyObject.createJobParams valueForKey:LOCATION_KEY] valueForKey:@"title"];
                    cell.ValueTF.placeholder = @"Select job location";
                    cell.ValueTF.enabled  = YES;
                    break;
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(isClosedJob){
            cell.userInteractionEnabled = NO;
            cell.ValueTF.textColor = [UIColor lightGrayColor];
        }
    
        return cell;
    }
    else if(indexPath.section == 1)
    {
        
        if(indexPath.row <  3){
            static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
            CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
                cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.ValueTF.delegate = self;
            cell.ValueTF.row = indexPath.row;
            cell.ValueTF.section = indexPath.section;
            cell.ValueTF.textColor = MainTextColor;
            cell.backgroundColor = [UIColor whiteColor];
            cell.userInteractionEnabled = YES;
            
            
            if(self.selectedDictionary){
                if(isPendingJob){
                    cell.userInteractionEnabled = YES;
                    cell.ValueTF.enabled  = YES;
                }else {
                    cell.ValueTF.enabled  = NO;
                    cell.ValueTF.textColor = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                }
            }
            else
                cell.ValueTF.enabled  = YES;
            
            switch (indexPath.row) {
                case 0:{
                    cell.titleLbl.text = @"Type";
                    cell.ValueTF.text = [[self.cjCompanyObject.createJobParams valueForKey:@"jobType"] valueForKey:@"jobTypeTitle"];
                    cell.ValueTF.placeholder = @"Select job type";
                }break;
                case 1:{
                    cell.titleLbl.text = @"Start Date";
                    cell.ValueTF.text = [self.cjCompanyObject.createJobParams valueForKey:@"startDate"];
                    cell.ValueTF.placeholder = @"Select start date";
                }break;
                case 2:{
                    cell.titleLbl.text = @"End Date";
                    cell.ValueTF.text =[self.cjCompanyObject.createJobParams valueForKey:@"endDate"];
                    cell.ValueTF.placeholder = @"Select end date";
                }break;
                default:
                    break;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(isClosedJob){
                cell.userInteractionEnabled = NO;
                cell.ValueTF.textColor = [UIColor lightGrayColor];
            }
            return cell;
        }else{
            static NSString *cellIdentifier = CUSTOM_SWITCH_CELL_IDENTIFIER;
            CustomSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SWITCH_CELL owner:self options:nil];
                cell = (CustomSwitchCell *)[topLevelObjects objectAtIndex:0];
            }
            
            cell.backgroundColor = [UIColor whiteColor];
            cell.userInteractionEnabled = YES;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.titleLbl.text = @"Unpaid";
            cell.valueSwitch.tag = 101;
            [cell.valueSwitch setOn:[[self.cjCompanyObject.createJobParams valueForKey:@"unpaid"] boolValue]];
            [cell.valueSwitch addTarget:self action:@selector(unPaidSalaryStatusUpdate:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if(isClosedJob){
                cell.userInteractionEnabled = NO;
            }
            return cell;
        }
        
    }
    else if(indexPath.section == 2)
    {
        static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
        CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
            cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        }
        
        if(showIntenshipOptions){
            cell.backgroundColor = DividerLineColor;
            cell.userInteractionEnabled = NO;
        }else{
            cell.backgroundColor = [UIColor whiteColor];
            cell.userInteractionEnabled = YES;
        }
        
        cell.ValueTF.delegate = self;
        cell.ValueTF.row = indexPath.row;
        cell.ValueTF.section = indexPath.section;
        cell.ValueTF.textColor = MainTextColor;
        cell.backgroundColor = [UIColor whiteColor];
        cell.userInteractionEnabled = YES;
        cell.titleLbl.text = @"Years";
        cell.ValueTF.placeholder = @"Add your experience";
        
        if ([[self.cjCompanyObject.createJobParams valueForKey:@"experienceMin"]intValue] == 0&&[[self.cjCompanyObject.createJobParams valueForKey:@"experienceMax"]intValue]==5)
        {
            if(self.selectedDictionary){
                cell.ValueTF.text =[NSString stringWithFormat:@"%d  - %d",[[self.cjCompanyObject.createJobParams valueForKey:@"experienceMin"]intValue],[[self.cjCompanyObject.createJobParams valueForKey:@"experienceMax"]intValue]];
            }

        }
        else{
             cell.ValueTF.text = [NSString stringWithFormat:@"%d  - %d",[[self.cjCompanyObject.createJobParams valueForKey:@"experienceMin"]intValue],[[self.cjCompanyObject.createJobParams valueForKey:@"experienceMax"]intValue]];
        }
       
        if(isClosedJob){
            cell.userInteractionEnabled = NO;
            cell.ValueTF.textColor = [UIColor lightGrayColor];
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.hidden = showIntenshipOptions;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        return cell;
    }
    else if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
            CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
                cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.ValueTF.delegate = self;
            cell.ValueTF.row = indexPath.row;
            cell.ValueTF.section = indexPath.section;
            cell.ValueTF.textColor = MainTextColor;
            cell.backgroundColor = [UIColor whiteColor];
            cell.userInteractionEnabled = YES;
            cell.titleLbl.text = @"Salary (per annum)";
            cell.ValueTF.placeholder = @"Enter your salary";
            
            if(unPaidOptions){
                cell.backgroundColor = DividerLineColor;
                cell.userInteractionEnabled = NO;
            }else{
                cell.backgroundColor = [UIColor whiteColor];
                cell.userInteractionEnabled = YES;
            }
            
            if ([[self.cjCompanyObject.createJobParams valueForKey:@"salaryMin"]intValue] == 0.0&&[[self.cjCompanyObject.createJobParams valueForKey:@"salaryMax"]intValue]==10.0){
                if(self.selectedDictionary){
                    cell.ValueTF.text = [NSString stringWithFormat:@"₹ %.1f L - %.1f L",[[self.cjCompanyObject.createJobParams valueForKey:@"salaryMin"] floatValue],[[self.cjCompanyObject.createJobParams valueForKey:@"salaryMax"] floatValue]];
                }
                else{
                    cell.ValueTF.text=@"";
                }
            }
            else
            {
            cell.ValueTF.text = [NSString stringWithFormat:@"₹ %.1f L - %.1f L",[[self.cjCompanyObject.createJobParams valueForKey:@"salaryMin"] floatValue],[[self.cjCompanyObject.createJobParams valueForKey:@"salaryMax"] floatValue]];
            }

            if(isClosedJob){
                cell.userInteractionEnabled = NO;
                cell.ValueTF.textColor = [UIColor lightGrayColor];
                cell.backgroundColor = [UIColor whiteColor];
            }

            cell.hidden = unPaidOptions;
            
            return cell;
        }else{
            static NSString *cellIdentifier = CUSTOM_SWITCH_CELL_IDENTIFIER;
            CustomSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SWITCH_CELL owner:self options:nil];
                cell = (CustomSwitchCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if(unPaidOptions){
                cell.backgroundColor = DividerLineColor;
                cell.userInteractionEnabled = NO;
            }else{
                cell.backgroundColor = [UIColor whiteColor];
                cell.userInteractionEnabled = YES;
            }
            
            [cell.valueSwitch setOn:[[self.cjCompanyObject.createJobParams valueForKey:@"hideSalary"] boolValue]];
            cell.titleLbl.text = @"Hide Salary Range";
            cell.valueSwitch.tag = 100;
            [cell.valueSwitch addTarget:self action:@selector(hideSalaryStatusUpdate:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if(isClosedJob){
                cell.userInteractionEnabled = NO;
                cell.titleLbl.textColor = [UIColor lightGrayColor];
                cell.backgroundColor = [UIColor whiteColor];
            }
            cell.hidden = unPaidOptions;
            return cell;
        }
    }
    else if(indexPath.section == 4){
        static NSString *cellIdentifier = CUSTOM_TEXT_VIEW_CELL_IDENTIFIER;
        CustomTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: CUSTOM_TEXT_VIEW_CELL owner:self options:nil];
            cell = (CustomTextViewCell *)[topLevelObjects objectAtIndex:0];
            local_text_view_cell = cell;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.userInteractionEnabled = YES;
        
        
        cell.wordCount.hidden = YES;
        cell.titleLbl.text = @"Enter a job description";
        if([[self.cjCompanyObject.createJobParams valueForKey:@"description"] length] > 0){
            cell.text_view.text = [self.cjCompanyObject.createJobParams valueForKey:@"description"];
            [cell.text_view setTextColor: MainTextColor];//2f2f2f
        }else{
            [cell.text_view setTextColor:placeHolderColor];
            cell.text_view.text = @"Enter a job description";
        }
        cell.text_view.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(isClosedJob){
            cell.userInteractionEnabled = NO;
            cell.text_view.textColor = [UIColor lightGrayColor];
        }
        
        return cell;
    }
    else{
        if(indexPath.row == 0)
        {
            static NSString *cellIdentifier = CUSTOM_SKILLS_CELL_IDENTIFIER;
            CustomSkillsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SKILLS_CELL owner:self options:nil];
                cell = (CustomSkillsCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.userInteractionEnabled = YES;
            
            cell.titleLbl.textColor = UIColorFromRGB(0x337ab7);
            cell.titleLbl.text = @"  Add Skills";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(isClosedJob){
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            
            NewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell"];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewTableViewCell" owner:self options:nil];
                cell = (NewTableViewCell *)[topLevelObjects objectAtIndex:0];
            }
            [[cell viewWithTag:999] removeFromSuperview];
            
            __block CGFloat containerWidth = SCREEN_WIDTH;
            __block CGFloat padding = _tagSpacing;
            
            if(!tagsView)
            {
                NSArray *tagArray1 = [self.cjCompanyObject.createJobParams valueForKey:@"skills"];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES];
                NSMutableArray *tagArray =[[tagArray1 sortedArrayUsingDescriptors:@[sort]] mutableCopy];
                
                tagsView = [[UIView alloc] initWithFrame:cell.bounds];
                int yCoord=0;
                
                int x,y;
                x=17;y=10;
                for(int i=0; i<tagArray.count; i++)
                {
                    UIButton *button = [[UIButton alloc]init];
                    NSString *myString=[tagArray objectAtIndex:i];
                    [button setTitle:myString forState:UIControlStateNormal];
                    button.titleLabel.font = cell.font;
                    
                    CGSize size = [button systemLayoutSizeFittingSize:UILayoutFittingExpandedSize
                                        withHorizontalFittingPriority:UILayoutPriorityRequired
                                              verticalFittingPriority:UILayoutPriorityDefaultHigh];
                    
                    CGFloat maxWidth = containerWidth - (5 * padding);
                    if (size.width > maxWidth) {
                        size = CGSizeMake(maxWidth, size.height);
                    }
                    CGRect rect = button.frame;
                    rect.origin = CGPointMake(x, y);
                    rect.size = size;
                    button.frame = CGRectMake(x,y,size.width+20, size.height);;
                    x += (size.width + padding+25);
                    
                    if ((x >= containerWidth - padding) && (i > 0))
                    {
                        x = padding+17;
                        y += size.height + padding+5;
                        
                        CGRect rect = button.frame;
                        rect.origin = CGPointMake(x, y);
                        rect.size = size;
                        button.frame = CGRectMake(x,y,size.width+20, size.height);;
                        x += (size.width + padding+25);
                        
                        yCoord += size.height + padding+5;
                        
                    }
                    
                    button.layer.cornerRadius=5.0;
                    button.backgroundColor = UIColorFromRGB(0x337ab7);
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [button setTag:i];
                    tagsView.tag = 999;
                    [tagsView addSubview:button];
                }
                [scrollView setContentSize:CGSizeMake(100, yCoord+55)];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell addSubview:tagsView];
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
    if((indexPath.section == 5 || (indexPath.section == 4 && unPaidOptions)) && indexPath.row == 0){
        
        if(self.selectedDictionary){
            self.save_button.hidden = NO;
            [self.save_button setImage:nil forState:UIControlStateNormal];
            [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
            self.save_button.tag = 1;
        }
        
        isEditJob = YES;
        
        WRAddSkillsViewController *controller = [[WRAddSkillsViewController alloc] initWithNibName:@"WRAddSkillsViewController" bundle:nil];
        controller.cjCompanyObject = self.cjCompanyObject;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}


-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum
{
    if(self.selectedDictionary){
        self.save_button.hidden = NO;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
        self.save_button.tag = 1;
    }
    
    if([sender tag] == 100){
        NSString *experienceMin = [NSString stringWithFormat:@"%d.0",[[NSNumber numberWithFloat:selectedMinimum] intValue]];
        NSString *experienceMax = [NSString stringWithFormat:@"%d.0",[[NSNumber numberWithFloat:selectedMaximum] intValue]];
        
        [self.cjCompanyObject.createJobParams setObject:experienceMin forKey:@"experienceMin"];
        [self.cjCompanyObject.createJobParams setObject:experienceMax forKey:@"experienceMax"];
        
        experianceLbl.text = [NSString stringWithFormat:@"%@ - %@",experienceMin,experienceMax];
    }else if([sender tag] == 200){
        
        NSString *salaryMin = [NSString stringWithFormat:@"%.1f",selectedMinimum];
        NSString *salaryMax = [NSString stringWithFormat:@"%.1f",selectedMaximum];
        
        [self.cjCompanyObject.createJobParams setObject:salaryMin forKey:@"salaryMin"];
        [self.cjCompanyObject.createJobParams setObject:salaryMax forKey:@"salaryMax"];
        
        salaryLbl.text = [NSString stringWithFormat:@"%@ L - %@ L",salaryMin,salaryMax];
    }
    isEditJob = YES;
}
- (void)didEndTouchesInRangeSlider:(TTRangeSlider *)sender
{
    //[self.table_view reloadData];
}

-(void)hideSalaryStatusUpdate:(id)sender
{
    UISwitch *swt = (UISwitch *)sender;
    if(swt.tag != 100)
        return;
    
    if(self.selectedDictionary){
        self.save_button.hidden = NO;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
        self.save_button.tag = 1;
    }
    
    if(swt.isOn)
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithInt:1] forKey:@"hideSalary"];
    else
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithInt:0] forKey:@"hideSalary"];
    
    isEditJob = YES;
}

-(void)unPaidSalaryStatusUpdate:(id)sender
{
    UISwitch *swt = (UISwitch *)sender;
    
    if(swt.tag != 101)
        return;
    
    if(self.selectedDictionary){
        self.save_button.hidden = NO;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
        self.save_button.tag = 1;
    }
    
    if(swt.isOn){
        unPaidOptions = YES;
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithInt:1] forKey:@"unpaid"];
    }else{
        unPaidOptions = NO;
        [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithInt:0] forKey:@"unpaid"];
    }
    
    [self.table_view reloadData];
    isEditJob = YES;
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Enter a job description"])
    {
        [textView setTextColor:placeHolderColor];
        [textView setText:@""];
    }
    
    NSIndexPath *index_path =  unPaidOptions?[NSIndexPath indexPathForRow:0 inSection:3]:[NSIndexPath indexPathForRow:0 inSection:4];
    [self.table_view scrollToRowAtIndexPath:index_path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0 || [textView.text isEqualToString:@"Enter a job description"]) {
        [textView setTextColor: MainTextColor];//2f2f2f
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(self.selectedDictionary){
        self.save_button.hidden = NO;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
        self.save_button.tag = 1;
    }
    
    [textView setTextColor: MainTextColor];//2f2f2f
    
    /*  if ([text isEqualToString:@"\n"]) {
     [textView resignFirstResponder];
     return NO;
     }*/
    //
    NSString * completeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [self.cjCompanyObject setCreateJobsParamsValue:completeString Key:@"description"];
    isEditJob = YES;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CustomTextField *text_field = (CustomTextField *)textField;
    
    
    if(text_field.section == 0 && text_field.row == 1){
        [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }else if(text_field.section == 0 && text_field.row == 2){
        [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }else if(text_field.section == 1 && text_field.row == 0){
        [self performSelector:@selector(showPickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }else if(text_field.section == 1 && text_field.row == 1){
        [self performSelector:@selector(showMonthYearPickerViewController:) withObject:textField afterDelay:0.2];
        return NO;
    }
    else if(text_field.section == 1 && text_field.row == 2)
    {
        [self performSelector:@selector(showMonthYearPickerViewController:) withObject:textField afterDelay:0.2];
        return NO;
    }
    else if(text_field.section == 2 && text_field.row == 0)
    {
        [self performSelector:@selector(showExperincePickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }
    else if(text_field.section == 3 && text_field.row == 0)
    {
        [self performSelector:@selector(showExperincePickerViewController:) withObject:textField afterDelay:0.3];
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(self.selectedDictionary){
        self.save_button.hidden = NO;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
        self.save_button.tag = 1;
    }
    
    
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];
    CustomTextField *text_field = (CustomTextField *)textField;
    
    if(text_field.section == 0 && text_field.row == 0)
        [self.cjCompanyObject setCreateJobsParamsValue:completeString Key:@"title"];
    else
        [self.cjCompanyObject setCreateJobsParamsValue:completeString Key:@"title"];
    
    isEditJob = YES;
    return YES;
}
-(void)showMonthYearPickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    selected_text_field = (CustomTextField *)sender;
    
    
    [UIView animateWithDuration:0.25f animations:^{
        self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0);
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0);
    }];
    
    [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    if(!date_picker_object){
        date_picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomDatePicker" owner:self options:nil] objectAtIndex:0];
        
        if(self.tabBarController)
            [self.tabBarController.view addSubview:date_picker_object];
        else
            [self.view addSubview:date_picker_object];
    }
    
    NSDate *date_c = nil;
    if(selected_text_field.section == 1 && selected_text_field.row == 1){
        
        NSString *string_date = [self.cjCompanyObject.createJobParams valueForKey:@"startDate"];
        date_c = [Utility getDateWithStringDate:string_date withFormat:@"MMM yyyy"];
        [date_picker_object.done_button setTitle:@"Next" forState:UIControlStateNormal];
    }else{
        
        NSString *string_date = [self.cjCompanyObject.createJobParams valueForKey:@"endDate"];
        date_c = [Utility getDateWithStringDate:string_date withFormat:@"MMM yyyy"];
        [date_picker_object.done_button setTitle:@"Done" forState:UIControlStateNormal];
    }
    
    if(date_c == nil)
        date_c = [NSDate date];
    
    date_picker_object.view_height = self.view.frame.size.height;
    date_picker_object.delegate = self;
    [date_picker_object.date_picker setDate:date_c];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:30];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    [date_picker_object.date_picker setMinimumDate:[NSDate date]];
    [date_picker_object.date_picker setMaximumDate:maxDate];
    date_picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
    [date_picker_object showPicker];
    
    isPickerShown = YES;
}

-(void)didSelectDateWithDoneClicked:(NSString *)value forTag:(NSDate *)date
{
    if([date_picker_object.done_button.titleLabel.text isEqualToString:@"Done"]){
        if(![self validateStartDateWithEndDate:date])
            return;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.table_view.contentInset = UIEdgeInsetsZero;
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
        }];
    }
    
    isPickerShown = NO;
    
    if(date == nil)
        return;
    
    if(selected_text_field.section == 1 && selected_text_field.row == 1){
        [self.cjCompanyObject.createJobParams setObject:[Utility getStringWithDate:date withFormat:@"MMM yyyy"]  forKey:@"startDate"];
        
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:selected_text_field.row+1 inSection:1];
        CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
        [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [nextCell.ValueTF becomeFirstResponder];
        
    }else{
        
        [self.cjCompanyObject.createJobParams setObject:[Utility getStringWithDate:date withFormat:@"MMM yyyy"]  forKey:@"endDate"];
        [self.cjCompanyObject.createJobParams setObject:date  forKey:@"endDateVal"];
    }
    selected_text_field.text = [Utility getStringWithDate:date withFormat:@"MMM yyyy"];
    [self.table_view reloadData];
    isEditJob = YES;
}

-(void)showPickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
    if(isPickerShown)
        return;
    
    selected_text_field = (CustomTextField *)sender;
    NSString *titleString = @"";
    NSMutableArray *tempArray = nil;
    int idx = 0;
    
    if(selected_text_field.section == 0 && selected_text_field.row == 1){
        titleString = @"Select job function";
        tempArray = [CompanyHelper getDropDownArrayWithTittleKey:@"jobFunctionName" parantKey:@"jobFunctions"];
        idx = [CompanyHelper getJobRoleIdWithValue:[self.cjCompanyObject.createJobParams valueForKey:@"jobFunction_name"] parantKey:@"jobFunctions" childKey:@"jobFunctionName"];
        
    }else if(selected_text_field.section == 0 && selected_text_field.row == 2){
        
        titleString = @"Comapny Location";
        tempArray = [CompanyHelper getDropDownArrayWithTittleKey:@"title" parantKey:@"locations"];
        
        idx = [CompanyHelper getJobRoleIdWithValue:[[self.cjCompanyObject.createJobParams valueForKey:LOCATION_KEY]  valueForKey:@"title"] parantKey:@"locations" childKey:@"title"];
        
    }else if(selected_text_field.section == 1 && selected_text_field.row == 0){
        
        titleString = @"Select job type";
        tempArray = [CompanyHelper getDropDownArrayWithTittleKey:@"jobTypeTitle" parantKey:@"jobTypes"];
        
        idx = [CompanyHelper getJobRoleIdWithValue:[[self.cjCompanyObject.createJobParams valueForKey:@"jobType"]  valueForKey:@"jobTypeTitle"] parantKey:@"jobTypes" childKey:@"jobTypeTitle"];
        
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        }];
        
        [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        
        selected_text_field = (CustomTextField *)sender;
        if(!picker_object){
            picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
            if(self.tabBarController)
                [self.tabBarController.view addSubview:picker_object];
            else
                [self.view addSubview:picker_object];
        }
        
        if(selected_text_field.section == 1)
            [picker_object.done_button setTitle:@"Next" forState:UIControlStateNormal];
        else
            [picker_object.done_button setTitle:@"Next" forState:UIControlStateNormal];
        picker_object.view_height = self.view.frame.size.height;
        picker_object.delegate = self;
        picker_object.objectsArray = tempArray;
        picker_object.numberOfComponents = 1;
        [picker_object.picker_view reloadAllComponents];
        [picker_object.picker_view selectRow:idx inComponent:0 animated:YES];

        picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
        [picker_object showPicker];
    });
    
    isPickerShown = YES;
}
-(void)didSelectPickerWithDoneClicked:(NSString *)value forTag:(int)tag
{
    isPickerShown = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.table_view.contentInset = UIEdgeInsetsZero;
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
    
    if(tag == -1) //For cancel
        return;
    
    if(self.selectedDictionary){
        self.save_button.hidden = NO;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
        self.save_button.tag = 1;
    }
    
    if(selected_text_field.section == 0 && selected_text_field.row == 1)
    {
        [self.cjCompanyObject setCreateJobsParamsValue:value Key:@"jobFunction_name"];
        NSString *jobFunction = [CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"jobFunctions" childKey:@"jobFunctionId"];
        [self.cjCompanyObject.createJobParams setObject:[[NSMutableArray alloc] initWithObjects:jobFunction, nil] forKey:@"jobFunction"];
        
        //Move to next filed
        [self MoveToNextField:(int)selected_text_field.section  row:(int)selected_text_field.row+1];
        
    }else if(selected_text_field.section == 0 && selected_text_field.row == 2){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictionary setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"locations" childKey:@"locationId"] forKey:LOCATION_ID_KEY];
        [dictionary setObject:value forKey:@"title"];
        [self.cjCompanyObject.createJobParams setObject:dictionary forKey:LOCATION_KEY];
        
        //Move to next filed
        [self MoveToNextField:(int)selected_text_field.section+1  row:0];
        
    }else if(selected_text_field.section == 1 && selected_text_field.row == 0){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dictionary setObject:[CompanyHelper getJobRoleIdWithIndex:(int)tag parantKey:@"jobTypes" childKey:@"jobTypeId"] forKey:@"jobTypeId"];
        [dictionary setObject:value forKey:@"jobTypeTitle"];
        [self.cjCompanyObject.createJobParams setObject:dictionary forKey:@"jobType"];
        
        if([value isEqualToString:@"Internship"]){
            showIntenshipOptions = YES;
        }else{
            showIntenshipOptions = NO;
            unPaidOptions = NO;
            [self.cjCompanyObject.createJobParams setObject:[NSNumber numberWithInt:0] forKey:@"unpaid"];
            [self.cjCompanyObject.createJobParams setObject:@"" forKey:@"startDate"];
            [self.cjCompanyObject.createJobParams setObject:@"" forKey:@"endDate"];
        }
        if([value isEqualToString:@"Internship"]){
        }
        else{
            //Move to next filed
            [self MoveToNextField:(int)selected_text_field.section+1  row:0];
        }
    }
    [self.table_view reloadData];

    selected_text_field.text = value;
    isEditJob = YES;
}

-(void)showExperincePickerViewController:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
    });
    
    if(isPickerShown)
        return;
   
    
    selected_text_field = (CustomTextField *)sender;
    NSString *fname;
    NSString *lname;
    
    if (selected_text_field.text.length != 0)
    {
        if(selected_text_field.section == 2 && selected_text_field.row == 0)
        {
            NSRange range = [selected_text_field.text rangeOfString:@"-"];
            fname = [selected_text_field.text substringToIndex:range.location];
            lname = [selected_text_field.text substringFromIndex:range.location+1];
        }
        else
        {
            NSString * str = [selected_text_field.text stringByReplacingOccurrencesOfString:@"₹" withString:@""];
            NSRange range = [str rangeOfString:@"-"];
            fname = [str substringToIndex:range.location];
            lname = [str substringFromIndex:range.location+1];
        }
    }
    
    
    NSString *titleString = @"";
    NSMutableArray * tempArray;
    NSMutableArray * tempArray1;

    int numberOfComponents = 0;
    //int idx = 0;
    
    numberOfComponents = 2;
    
    titleString = @"Select experience";
    
    if(selected_text_field.section == 2 && selected_text_field.row == 0)
    {
        tempArray = minExpArray;
        tempArray1 = maxExpArray;
    }
    else{
        tempArray = minsalaryArray;
        tempArray1 = maxsalaryArray;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.table_view.contentInset = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
            self.table_view.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 257, 0.0);
        }];
        
        [self.table_view scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selected_text_field.row inSection:selected_text_field.section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

        selected_text_field = (CustomTextField *)sender;
        if(!picker_object){
            picker_object = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
            if(self.tabBarController)
                [self.tabBarController.view addSubview:picker_object];
            else
                [self.view addSubview:picker_object];
        }
        
        
        if(selected_text_field.section == 2 && selected_text_field.row == 0)
        {
            [picker_object.done_button setTitle:@"Next" forState:UIControlStateNormal];
        }
        else{
            [picker_object.done_button setTitle:@"Done" forState:UIControlStateNormal];
        }
        
        picker_object.view_height = self.view.frame.size.height;
        picker_object.delegate = self;
        picker_object.objectsArray = tempArray;
        picker_object.subObjectsArray = tempArray1;
        picker_object.numberOfComponents = numberOfComponents;
        [picker_object.picker_view reloadAllComponents];
        picker_object.center = self.view.center;

        if(selected_text_field.section == 2 && selected_text_field.row == 0)
        {
            if (selected_text_field.text.length == 0) {
                [picker_object.picker_view selectRow:[fname integerValue] inComponent:0 animated:YES];
                [picker_object.picker_view selectRow:[lname integerValue] inComponent:1 animated:YES];
            }
            else{
                [picker_object.picker_view selectRow:[fname integerValue]+1 inComponent:0 animated:YES];
                [picker_object.picker_view selectRow:[lname integerValue] inComponent:1 animated:YES];
            }
        }
        else{
            if (selected_text_field.text.length == 0) {
                [picker_object.picker_view selectRow:[fname integerValue] inComponent:0 animated:YES];
                [picker_object.picker_view selectRow:[lname integerValue] inComponent:1 animated:YES];
            }
            else
            {
                [picker_object.picker_view selectRow:[fname integerValue]+1 inComponent:0 animated:YES];
                [picker_object.picker_view selectRow:[lname integerValue] inComponent:1 animated:YES];
            }
        }
        
        picker_object.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 257);
        [picker_object showPicker];
    });
    isPickerShown = YES;
}

-(void)didSelectPickerWithDoneClicked:(NSString *)value withSubRow:(NSString *)subValue forTag:(int)tag
{
    isPickerShown = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.table_view.contentInset = UIEdgeInsetsZero;
        self.table_view.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
    
    if(tag == -1) //For cancel
        return;
    
    
    if(self.selectedDictionary){
        self.save_button.hidden = NO;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
        self.save_button.tag = 1;
    }
    
    NSString *years = [[value componentsSeparatedByString:@" "] objectAtIndex:0];
    NSString *months = [[subValue componentsSeparatedByString:@" "] objectAtIndex:0];
    
    if([years integerValue] > 0)
        selected_text_field.text = [NSString stringWithFormat:@"%@ - %@",years,months];
    else
        if ([years isEqualToString:@"--"]) {
            selected_text_field.text = [NSString stringWithFormat:@"%@ - %@",@"0",months];
            
        }else{
            selected_text_field.text = [NSString stringWithFormat:@"%@ - %@",years,months];
        }
    
    if(selected_text_field.section == 2 && selected_text_field.row == 0)
    {
        NSString *experienceMin;

        if ([years isEqualToString:@"--"])
        {
            experienceMin = [NSString stringWithFormat:@"0"];
        }
        else{
            experienceMin = [NSString stringWithFormat:@"%@.0",years];
        }
        NSString *experienceMax = [NSString stringWithFormat:@"%@.0",months];
        
        int a = [experienceMin intValue];
        int b = [experienceMax intValue];
        
         if(a>b||a==b)
         {
            selected_text_field.text =@"";
            [CustomAlertView showAlertWithTitle:@"" message:@"Minimum experience cannot be greater than or equal to the Maximum experience" OkButton:@"Ok" delegate:self];
            return;
         }
        else
        {
            [self.cjCompanyObject.createJobParams setObject:experienceMin forKey:@"experienceMin"];
            [self.cjCompanyObject.createJobParams setObject:experienceMax forKey:@"experienceMax"];
            
            [self MoveToNextField:(int)selected_text_field.section+1  row:(int)selected_text_field.row];
        }
    }
    else
    {
        NSString *salaryMin;
        if ([years isEqualToString:@"--"])
        {
            salaryMin = [NSString stringWithFormat:@"0"];
        }
        else{
            salaryMin = [NSString stringWithFormat:@"%@.0",years];
        }
        
        
        NSString *salaryMax = [NSString stringWithFormat:@"%@",months];
        
        NSString*compMin = [salaryMin stringByReplacingOccurrencesOfString:@"L" withString:@""];
        NSString*compMax = [salaryMax stringByReplacingOccurrencesOfString:@"L" withString:@""];

        int a = [compMin intValue];
        int b = [compMax intValue];
        
        if(a>b||a==b)
        {
            selected_text_field.text =@"";
            [CustomAlertView showAlertWithTitle:@"" message:@"Minimum salary cannot be greater than or equal to the Maximum salary" OkButton:@"Ok" delegate:self];
            return;
        }
        else
        {
            [self.cjCompanyObject.createJobParams setObject:compMin forKey:@"salaryMin"];
            [self.cjCompanyObject.createJobParams setObject:compMax forKey:@"salaryMax"];
        }
   }
    [self.table_view reloadData];
    
    isEditJob = YES;

}

-(void)MoveToNextField:(int)section row:(int)row
{
    NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
    [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [nextCell.ValueTF becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if(self.selectedDictionary){
        self.save_button.hidden = NO;
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save"  forState:UIControlStateNormal];
        self.save_button.tag = 1;
    }
    
    CreateCompanyCustomCell * currentCell = (CreateCompanyCustomCell *) textField.superview.superview;
    NSIndexPath * currentIndexPath = [self.table_view indexPathForCell:currentCell];
    
    if (currentIndexPath.row != 2 && currentIndexPath.section == 0) {
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:0];
        CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
        [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [nextCell.ValueTF becomeFirstResponder];
    }
    return YES;
}

-(BOOL)validateStartDateWithEndDate:(NSDate *)endDate
{
    NSString *end_date_str =  [Utility getStringWithDate:endDate withFormat:@"MMM yyyy"];
    NSString *start_date_string = [self.cjCompanyObject.createJobParams valueForKey:@"startDate"];
    NSDate *start_date = [Utility getDateWithStringDate:start_date_string withFormat:@"MMM yyyy"];
    
    NSDate *end_date = [Utility getDateWithStringDate:end_date_str withFormat:@"MMM yyyy"];
    
    NSString *message = @"";
    if(start_date == nil)
        message = @"Please select start date!";
    else if([start_date compare:end_date]  == NSOrderedDescending)
        message = @"End date cannot be before your Start date.";
    else if([start_date compare:end_date]  == NSOrderedSame)
        message = @"Start date and End date cannot be from the same month.";
    
    if([message length] > 0){
        [CustomAlertView showAlertWithTitle:@"Error" message:message OkButton:@"Ok" delegate:self];
        return NO;
    }else return YES;
}
-(IBAction)createJobAction:(id)sender
{
    if(self.save_button.tag == 1000)
    {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
        {
            [self dismissViewControllerAnimated:YES completion:^{
        }];
     }]];
     [actionSheet addAction:[UIAlertAction actionWithTitle:@"Close Job" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
     {
         [CustomAlertView showAlertWithTitle:@"Are you sure?" message:@"Are you sure you want to close this job?" OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:300];
         return;
      }]];
     
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    
    NSString *validation_message =  [self.cjCompanyObject validateCreateJobParams:showIntenshipOptions];
    if([validation_message isEqualToString:SUCESS_STRING])
    {
        NSString *message = @"Are you sure you want to post this job?";
        NSString *title  = @"Are you sure?";
        
        if(self.selectedDictionary)
            message = @"Are you sure you want to edit this job?";
        else
            message = @"Are you sure you want to post this job?";
        
        [CustomAlertView showAlertWithTitle:title message:message OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:200];
    }
    else
        [CustomAlertView showAlertWithTitle:@"Error" message:validation_message OkButton:@"Ok" delegate:self];
}

-(IBAction)backButtonAction:(id)sender
{
    if(isEditJob){
        [CustomAlertView showAlertWithTitle:@"Are you sure?" message:@"You have unsaved changes. Are you sure you want to cancel?" OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:100];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    if(tag == 100 && buttonIndex == 2)
        [self.navigationController popViewControllerAnimated:YES];
    else if(tag == 200 && buttonIndex == 2)
        [self.cjCompanyObject createJobServiceCallWithDelegate:self requestType:400];
    else if(tag == 300 && buttonIndex == 2)
        [self.cjCompanyObject closeJobServiceCallWithDelegate:self requestType:300 jobId:[self.selectedDictionary valueForKey:@"jobPostId"]];
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 300){
        [self.delegate didSucessfullyClosedJob:self.selectedDictionary forTag:tag];
        [self.navigationController popViewControllerAnimated:YES];
        [FireBaseAPICalls captureScreenDetails:JOB_CLOSED];
        return;
    }
    
    
    if(self.selectedDictionary){
        [FireBaseAPICalls captureScreenDetails:@"job_update"];
        
        switch ([[self.selectedDictionary valueForKey:@"status"] intValue]) {
            case 1:
                [FireBaseAPICalls captureMixpannelEvent:COMPANY_JOB_EDITACTIVE];
                break;
            case 2:
                [FireBaseAPICalls captureMixpannelEvent:COMPANY_JOB_EDITPENDING];
                break;
            default:
                [FireBaseAPICalls captureMixpannelEvent:COMPANY_JOB_EDITACTIVE];
                break;
        }
        
    }else{
        [FireBaseAPICalls captureScreenDetails:@"jop_posted"];
        [CompanyHelper sharedInstance].isJobPosted = YES;
    }
    
    [CompanyHelper sharedInstance].loadJobCardsWithPrefreceSettings = NO;
    [Utility saveToDefaultsWithKey:[data valueForKey:@"data"]  value:LAST_CREATED_JOB_ID];
    
    
    if ([self.header_lbl.text isEqualToString:@"Create Job"])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[data valueForKey:@"data"] forKey:@"lastCreatedJobId"];
        [defaults setObject:[self.cjCompanyObject.createJobParams valueForKey:@"title"] forKey:@"lastCreatedJobName"];
        [defaults setObject:[self.cjCompanyObject.createJobParams valueForKey:@"title"] forKey:@"showJobHeader"];
        
        NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:[self.cjCompanyObject.createJobParams mutableCopy]];
        [defaults setObject:dataArray forKey:@"lastCreatedJobObject"];
        
        [defaults synchronize];
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"lastCreatedJobId"] intValue] == [[self.cjCompanyObject.createJobParams valueForKey:@"jobPostId"] intValue])
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[self.cjCompanyObject.createJobParams valueForKey:@"title"] forKey:@"showJobHeader"];
            [defaults setObject:[self.cjCompanyObject.createJobParams valueForKey:@"title"] forKey:@"lastCreatedJobName"];
        }
    }
    
    self.selectedDictionary = self.cjCompanyObject.createJobParams;
    [CompanyHelper sharedInstance].prefrences_object = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag{
    
}
-(void)showActionSheetWithOptions
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"More" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [actionSheet dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Close Job" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
        
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

