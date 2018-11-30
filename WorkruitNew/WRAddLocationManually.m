//
//  WRAddLocationManually.m
//  WorkruitNew
//
//  Created by Admin on 9/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "WRAddLocationManually.h"

@interface WRAddLocationManually ()<UITextFieldDelegate,WYPopoverControllerDelegate,POPOVER_Delegate,HTTPHelper_Delegate>
{
    NSMutableArray *arraySkills;
    NSMutableArray *tagArray;
    NSMutableArray *removedTagsArray;
    
    PopOverListController *popListController;
    WYPopoverController *autocompleteTableView;
    
    ASJTagsView *tagsViewTemp;
    UITextField *skills_textFiled;
    
    ConnectionManager *connection_manager;
    UITextField *kills_textFiled;
    
    ASJTagsView *suggestedTagView;
    
    NSMutableArray *selectedTagsFromSuggestionsArray;
    
    BOOL isSuggestedTagViewHidden;
    
    BOOL isUpdateTags;
    BOOL isSuggestedTagsUpdate;
    IBOutlet UIView * myView;

    
}

@end

@implementation WRAddLocationManually

-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)saveButtonAction:(id)sender
{
    [FireBaseAPICalls captureScreenDetails:COMPANY_JOB_PREFERNCES_SAVE];

    if([sender tag] == 5){
        [[CompanyHelper sharedInstance].prefrences_object setObject:@"" forKey:@"customLocations"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if((tagArray.count + selectedTagsFromSuggestionsArray.count) > 3 || (tagArray.count + selectedTagsFromSuggestionsArray.count) <= 0){
        [CustomAlertView showAlertWithTitle:@"Message" message:@"Please select upto 3 cities." OkButton:@"Ok" delegate:self];
        return;
    }
    
    NSMutableString  *stringObject = [[NSMutableString alloc] initWithCapacity:0];
    
    for(NSString *string in tagArray){
        if([string isEqualToString:[tagArray lastObject]] && (selectedTagsFromSuggestionsArray.count <= 0)){
            [stringObject appendString:[NSString stringWithFormat:@"%@",string]];
        }else
            [stringObject appendString:[NSString stringWithFormat:@"%@,",string]];
    }
    
    for(NSString *string in selectedTagsFromSuggestionsArray){
        if([string isEqualToString:[selectedTagsFromSuggestionsArray lastObject]])
            [stringObject appendString:[NSString stringWithFormat:@"%@",string]];
        else
            [stringObject appendString:[NSString stringWithFormat:@"%@,",string]];
    }
    
    [[CompanyHelper sharedInstance].prefrences_object setObject:stringObject forKey:@"customLocations"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    isUpdateTags = YES;
    isSuggestedTagsUpdate = YES;
    
    [super viewWillAppear:animated];
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    isSuggestedTagsUpdate = YES;
    isUpdateTags = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FireBaseAPICalls captureScreenDetails:COMPANY_JOB_PREFERNCES];

    
    isUpdateTags = YES;
    isSuggestedTagViewHidden = YES;
    
    tagArray = [[NSMutableArray alloc] initWithCapacity:0];
    removedTagsArray = [[NSMutableArray alloc] initWithCapacity:0];
    selectedTagsFromSuggestionsArray =  [[NSMutableArray alloc] initWithCapacity:0];
    
    //Setting the table view footer view to zeero
    //self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    isSuggestedTagViewHidden = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        _redefineLocationsArray = [CompanyHelper getAllCities];
        _suggestedSkillsArray = nil;
        _suggestedSkillsArray = [[NSMutableArray alloc] initWithCapacity:0];
        tagArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for(int i = 0; i < 100; i++)
            [_suggestedSkillsArray addObject:[_redefineLocationsArray objectAtIndex:i]];
        
        NSArray *array = nil;
        if([[[CompanyHelper sharedInstance].prefrences_object valueForKey:@"customLocations"] length] > 0)
            array = [[[CompanyHelper sharedInstance].prefrences_object valueForKey:@"customLocations"] componentsSeparatedByString:@","];
        
        _suggestedSkillsArray =[[_suggestedSkillsArray sortedArrayUsingSelector:
                                 @selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        
        for(NSString *cityName in array){
            if([_suggestedSkillsArray containsObject:cityName]){
                [_suggestedSkillsArray removeObject:cityName];
                [removedTagsArray addObject:cityName];
            }
            [tagArray addObject:cityName];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            isSuggestedTagViewHidden = NO;
            [selectedTagsFromSuggestionsArray removeAllObjects];
            [self.table_view reloadData];
            [MBProgressHUD hideHUDForView:self. view animated:YES];
        });
    });
    
    [Utility setThescreensforiPhonex:myView];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1 && indexPath.section == 0 && tagsViewTemp.tags.count > 0){
        if(tagsViewTemp.contentSize.height > CELL_HEIGHT)
            return tagsViewTemp.contentSize.height + 10;
        else return CELL_HEIGHT;
    }else if(indexPath.section == 1){
        return suggestedTagView.contentSize.height + 10;
    }else
        if (tagArray.count == 0)
        {
            if(indexPath.row == 1)
            {
                return 10;
            }
            else
                return CELL_HEIGHT;
        }else
            return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([self.suggestedSkillsArray count] > 0)
        return 2;
    else
        return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 2;
    else return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        
        if(indexPath.row == 0){
            static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
            CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
                cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
            }
            cell.titleLbl.text = @"Enter your cities";
            cell.ValueTF.placeholder = @"Enter your cities";
            cell.ValueTF.delegate = self;
            cell.ValueTF.returnKeyType =  UIReturnKeyDone;
            cell.ValueTF.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            static NSString *cellIdentifier = CUSTOM_SKILLS_VIEW_CELL_IDENTIFIER;
            CustomSklillsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (nil == cell)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SKILLS_VIEW_CELL owner:self options:nil];
                cell = (CustomSklillsViewCell *)[topLevelObjects objectAtIndex:0];
            }
            tagsViewTemp = cell.tagsView;
            cell.tagsView.tag = 101;
            
            if(isUpdateTags)
            {
                isUpdateTags = NO;
                
                [cell.tagsView setTapBlock:^(NSString *tagText, NSInteger idx){
                    isUpdateTags = YES;
                    
                    [cell.tagsView deleteTagAtIndex:idx-300];
                    [tagArray removeObject:tagText];
                    
                    BOOL isTagRemoved = NO;
                    for(NSString *tag_name in removedTagsArray){
                        if([tagText isEqualToString:tag_name]){
                            [_suggestedSkillsArray addObject:tagText];
                            _suggestedSkillsArray =[[_suggestedSkillsArray sortedArrayUsingSelector:
                                                     @selector(localizedCaseInsensitiveCompare:)] mutableCopy];
                            [removedTagsArray removeObject:tagText];
                            isTagRemoved = YES;
                            break;
                        }
                    }
                    
                    if(isTagRemoved){
                        [self.table_view reloadData];
                    }else{
                        NSArray *arrayReload = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
                        [self.table_view  reloadRowsAtIndexPaths:arrayReload withRowAnimation:UITableViewRowAnimationNone];
                        [skills_textFiled becomeFirstResponder];
                        skills_textFiled.returnKeyType = UIReturnKeyDone;
                    }
                }];
            }
        
            [cell.tagsView deleteAllTags];
            [cell.tagsView appendTags:tagArray];
            
            
            [skills_textFiled becomeFirstResponder];
            skills_textFiled.returnKeyType = UIReturnKeyDone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else{
        static NSString *cellIdentifier = CUSTOM_SKILLS_VIEW_CELL_IDENTIFIER;
        CustomSklillsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CUSTOM_SKILLS_VIEW_CELL owner:self options:nil];
            cell = (CustomSklillsViewCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.tagsView.scrollEnabled = NO;
        suggestedTagView = cell.tagsView;
        cell.tagsView.tag = 101;
        cell.tagsView.hidden = isSuggestedTagViewHidden;
        
        cell.tagsView.tagColor = DividerLineColor;
        cell.tagsView.tagTextColor = MainTextColor;
        
        
        if(isSuggestedTagsUpdate)
        {
            isSuggestedTagsUpdate = NO;
            
            [cell.tagsView setTapBlock:^(NSString *tagText, NSInteger idx)
             {
                 isSuggestedTagsUpdate = YES;
                 UIView *tagView = [cell.tagsView getTagViewbyIndex:idx];
                 if(!tagView.clipsToBounds && ((tagArray.count + selectedTagsFromSuggestionsArray.count) < 3)){
                     tagView.clipsToBounds = YES;
                     [cell.tagsView setTagTextColor:[UIColor whiteColor] backgroundColor:UIColorFromRGB(0x337ab7) withIndex:idx];
                     if(![tagArray containsObject:tagText])
                         [selectedTagsFromSuggestionsArray addObject:tagText];
                 }else{
                     
                     if(!tagView.clipsToBounds && ((tagArray.count + selectedTagsFromSuggestionsArray.count) <= 3)){
                         [CustomAlertView showAlertWithTitle:@"Message" message:@"Maximum count is reached." OkButton:@"Ok" delegate:self];
                     }
                     
                     tagView.clipsToBounds = NO;
                     [cell.tagsView setTagTextColor:MainTextColor backgroundColor:DividerLineColor withIndex:idx];
                     if([selectedTagsFromSuggestionsArray containsObject:tagText])
                         [selectedTagsFromSuggestionsArray removeObject:tagText];
                 }
             }];
        }
        
        [cell.tagsView deleteAllTags];
        NSLog(@"anwer %lu",(unsigned long)self.suggestedSkillsArray.count);
        [cell.tagsView appendTags:self.suggestedSkillsArray];
    
        
        
        for(NSString *string in selectedTagsFromSuggestionsArray)
            [cell.tagsView setTagTextColor:[UIColor whiteColor] backgroundColor:UIColorFromRGB(0x337ab7) withIndex:300+[self.suggestedSkillsArray  indexOfObject:string]];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) return 0.0f; else return 30.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return nil;
    else{
        UILabel *lable_object = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        [lable_object setTextColor:MainTextColor];
        [lable_object setBackgroundColor:[UIColor whiteColor]];
        lable_object.text = @"Suggested Cities";
        lable_object.textAlignment = NSTextAlignmentCenter;
        lable_object.font = [UIFont fontWithName:GlobalFontSemibold size:15];
        return lable_object;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    skills_textFiled = textField;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];
    [self searchActionInvoke:completeString];
    
    skills_textFiled = textField;
    return YES;
}


-(void)searchActionInvoke:(NSString *)search_str
{
    [popListController filterTheArray:search_str];
    [self shwoAutoCompleteLocations:skills_textFiled];
    [popListController.tableView reloadData];
}

-(BOOL)checThisSkillAleadyExist:(NSString *)skill_name
{
    BOOL value = NO;
    for(NSString  *tag in tagArray){
        if([skill_name isEqualToString:tag]){
            value =  YES;
            [removedTagsArray addObject:skill_name];
            break;
        }
    }
    return value;
}

-(void)allocPopOver
{
    popListController  = [[PopOverListController alloc] initWithNibName:@"PopOverListController" bundle:nil];
    popListController.delegate = self;
    popListController.allCountriesArray = self.redefineLocationsArray;
    
    autocompleteTableView = [[WYPopoverController alloc] initWithContentViewController:popListController];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dismissOnTap = YES;
}


-(void)shwoAutoCompleteLocations:(UITextField *)textField
{
    kills_textFiled = textField;
    if(!autocompleteTableView.isPopoverVisible){
        [self allocPopOver];
        [autocompleteTableView presentPopoverFromRect:textField.bounds inView:textField permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    }
}

-(void)didSelectValue:(NSString *)value forIndex:(int)index
{
    kills_textFiled.text = @"";
    
    if((tagArray.count + selectedTagsFromSuggestionsArray.count) >= 3) return;
    
    for(NSString *tag  in tagArray)
        if([tag isEqualToString:value])
            return;
    
    for(NSString *tag  in selectedTagsFromSuggestionsArray)
        if([tag isEqualToString:value])
            return;
    
    for(NSString *tag  in _suggestedSkillsArray)
        if([tag isEqualToString:value]){
            [removedTagsArray addObject:value];
            [_suggestedSkillsArray removeObject:value];
            break;
        }
    
    
    [tagArray addObject:value];
    [tagsViewTemp addTag:value];
    
    NSArray *arrayReload = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:0 inSection:0], nil];
    [self.table_view  reloadRowsAtIndexPaths:arrayReload withRowAnimation:UITableViewRowAnimationNone];
    
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

