//
//  WRSkillsViewController.m
//  workruit
//
//  Created by Admin on 10/13/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRSkillsViewController.h"
#import "WRApplicantEditProfile.h"
#import "WRAddExperianceController.h"

@interface WRSkillsViewController ()<UITextFieldDelegate,WYPopoverControllerDelegate,POPOVER_Delegate,HTTPHelper_Delegate>
{
    NSMutableArray *arraySkills;
    NSMutableArray *tagArray;
    NSMutableArray *removedTagsArray;
    
    PopOverListController *popListController;
   WYPopoverController *autocompleteTableView;
    
    ASJTagsView *tagsViewTemp;
    ASJTagsView *suggestedTagView;

    UITextField *skills_textFiled;
    ConnectionManager *connection_manager;
    NSMutableArray *selectedTagsFromSuggestionsArray;
    
    BOOL isUpdateTags;
    BOOL isSuggestedTagsUpdate;
    IBOutlet UIView * myView;


}
@end

@implementation WRSkillsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isUpdateTags = YES;
    isSuggestedTagsUpdate = YES;
    
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isSuggestedTagsUpdate = YES;
    isUpdateTags = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
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
-(void)loadArray
{
    NSArray *tagArray1 = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"skills"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES];
    tagArray =[[tagArray1 sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
   // tagArray = [[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"skills"] mutableCopy];
    if(tagArray == nil)
        tagArray = [[NSMutableArray alloc] initWithCapacity:0];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isUpdateTags = YES;

    connection_manager = [[ConnectionManager alloc] init];
    connection_manager.delegate = self;

    
//    arraySkills = [CompanyHelper getArrayWithParentKey:@"skills"];
    
    [self performSelector:@selector(loadArray) withObject:nil afterDelay:0.1];
    

    if(self.isCommingFromEditContact)
    {
        [self.save_button setImage:nil forState:UIControlStateNormal];
        [self.save_button setTitle:@"Save" forState:UIControlStateNormal];
    }
   

    removedTagsArray = [[NSMutableArray alloc] initWithCapacity:0];
    selectedTagsFromSuggestionsArray = [[NSMutableArray alloc] initWithCapacity:0];

    
    NSMutableArray *job_function_array = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobfunctions"];
    NSMutableString *job_funcation_string = [[NSMutableString alloc] init];
    
    if([job_function_array count] > 0){
        for (int i = 0; i< [job_function_array count]; i++) {
            if(i != [job_function_array count]-1)
                [job_funcation_string appendFormat:@"%@,",[[job_function_array objectAtIndex:i] valueForKey:@"jobFunctionId"]];
            else
                [job_funcation_string appendFormat:@"%@",[[job_function_array objectAtIndex:i] valueForKey:@"jobFunctionId"]];
        }
        
        [[ApplicantHelper sharedInstance] getSkillsServiceWithDelegate:self requestType:-200 withJobFunction:job_funcation_string];
    }

    
    // Do any additional setup after loading the view.
    //self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.table_view setSeparatorColor:DividerLineColor];
    
    [Utility setThescreensforiPhonex:myView];


}

-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)nextButtonForProcess:(id)sender
{
    for(NSString *string in selectedTagsFromSuggestionsArray)
    {
        if(![tagArray containsObject:string])
        {
            [tagArray addObject:string];
        }
    }
    
    if([tagArray count] <= 2)
    {
        [CustomAlertView showAlertWithTitle:@"Message" message:@"Please enter minimum of 3 skills." OkButton:@"OK" delegate:self];
    }
    else if ([tagArray count] > 30)
    {
        [CustomAlertView showAlertWithTitle:@"Message" message:@"Skills should not be greater than 30." OkButton:@"OK" delegate:self];
    }
    else
    {
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:tagArray forKey:@"skills"];
        //Update skills
        [[ApplicantHelper sharedInstance] updateApplicantSkillsServiceCallWithDelegate:self requestType:100];
        
        if (self.isCommingFromEditContact)
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_ADD_SKILLS];
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(KeyboardStarted:) withObject:nil afterDelay:0.1];
}
-(void)KeyboardStarted:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger i = [sender tag];
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CreateCompanyCustomCell * nextCell = [self.table_view cellForRowAtIndexPath:nextIndexPath];
        if ([nextCell.ValueTF.placeholder = @"Enter your skills" isEqualToString:@"Enter your skills"])
        {
            [nextCell.ValueTF becomeFirstResponder];
        }
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1 && indexPath.section == 0 && tagsViewTemp.tags.count > 0)
    {
        if(tagsViewTemp.contentSize.height > CELL_HEIGHT)
            return tagsViewTemp.contentSize.height + 10;
        else
            return CELL_HEIGHT;
    }
    else if(indexPath.section == 1)
    {
        return suggestedTagView.contentSize.height + 10;
    }
    else
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
            cell.titleLbl.text = @"Enter your skills";
            cell.ValueTF.placeholder = @"Enter your skills";
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
                            _suggestedSkillsArray = [[_suggestedSkillsArray sortedArrayUsingSelector:
                                                      @selector(localizedCaseInsensitiveCompare:)] mutableCopy];
                            
                            [removedTagsArray removeObject:tagText];
                            isTagRemoved = YES;
                            break;
                        }
                    }
                    if(isTagRemoved)
                        [self.table_view reloadData];
                    else{
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
        
        if(isSuggestedTagsUpdate)
        {
            isSuggestedTagsUpdate = NO;
            cell.tagsView.tag = 100;
            cell.tagsView.tagColor = DividerLineColor;
            cell.tagsView.tagTextColor = MainTextColor;
            
            [cell.tagsView setTapBlock:^(NSString *tagText, NSInteger idx){
                isSuggestedTagsUpdate = YES;
                UIView *tagView = [cell.tagsView getTagViewbyIndex:idx];
                if(!tagView.clipsToBounds){
                    tagView.clipsToBounds = YES;
                    [cell.tagsView setTagTextColor:[UIColor whiteColor] backgroundColor:UIColorFromRGB(0x337ab7) withIndex:idx];
                    if(![tagArray containsObject:tagText])
                        [selectedTagsFromSuggestionsArray addObject:tagText];
                }else{
                    tagView.clipsToBounds = NO;
                    [cell.tagsView setTagTextColor:MainTextColor backgroundColor:DividerLineColor withIndex:idx];
                    if([selectedTagsFromSuggestionsArray containsObject:tagText])
                        [selectedTagsFromSuggestionsArray removeObject:tagText];
                }
            }];
        }
        
        [cell.tagsView deleteAllTags];
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
        lable_object.text = @"Suggested Skills";
        lable_object.textAlignment = NSTextAlignmentCenter;
        lable_object.font = [UIFont fontWithName:GlobalFontSemibold size:15];
        return lable_object;
    }
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    /*[self shwoAutoCompleteLocations:textField];
    if([textField.text length] > 0)
        [popListController filterTheArray:textField.text];*/
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    return YES;
}

-(void)searchActionInvoke:(NSString *)search_str
{
    [connection_manager.dataTask cancel];
    NSString *url = [NSString stringWithFormat:@"%@/skills?page=0&size=20&skillName=%@&jobFunction=",API_BASE_URL,search_str];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    connection_manager.delegate = self;
    [connection_manager startRequestWithURL:url WithParams:nil forRequest:-100 controller:self httpMethod:HTTP_GET];
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

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == -200){
        NSMutableArray *skills_array = [data valueForKey:@"content"];
        self.suggestedSkillsArray = [[NSMutableArray alloc] initWithCapacity:0];

        for(NSMutableDictionary *dictionary in skills_array){
            if(![self checThisSkillAleadyExist:[dictionary valueForKey:@"skillName"]])
                [self.suggestedSkillsArray addObject:[dictionary valueForKey:@"skillName"]];
        }
        _suggestedSkillsArray =[[_suggestedSkillsArray sortedArrayUsingSelector:
                                                   @selector(localizedCaseInsensitiveCompare:)] mutableCopy];
        
      
        
        [self.table_view  reloadData];
        
    }else if(tag == 100){
        if(self.isCommingFromEditContact){
            NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:FIRST_NAME_KEY];
            NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                        valueForKey:APPLICANT_REGISTRATION_ID];
            
            
            NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
            
            
            [Utility getMixpanelData:APPLICANT_SIGNUP_SKILLS setProperties:userName];
           
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        if([[data valueForKey:@"percentage"] floatValue] > 0)
            [ApplicantHelper sharedInstance].profilePercentage = [[data valueForKey:@"percentage"] floatValue];
        
        [ApplicantHelper sharedInstance].halfProfile = [[data valueForKey:@"halfProfile"] boolValue];

        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isFristTimeTutorialDone"];
        [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"chat"] forKey:@"chat"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[data valueForKey:@"chatLimit"] intValue]] forKey:@"chatLimit"];

        [[NSUserDefaults standardUserDefaults] synchronize];
        

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:@"tutorial_data"];
        [defaults synchronize];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        NSString *experienceString = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"totalexperience"];
        
        NSLog(@"my exp%@",experienceString);
        
        if([experienceString isEqualToString:@"0.0" ] || [experienceString isEqualToString:@"0" ]     ){
            
            [[ApplicantHelper sharedInstance] setParamsValue:@"0" forKey:@"totalexperience"];
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
            WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            controller.Flag = 1;
         
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"screen"];
          
            [defaults synchronize];
           
            [self.navigationController pushViewController:controller animated:YES];
        
        }else{
        
        
        WRAddExperianceController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"screen"];
            
            [defaults synchronize];
        [self.navigationController pushViewController:controller animated:YES];
        }

    }else{
        
        [self shwoAutoCompleteLocations:skills_textFiled];
        
        NSMutableArray *skills_array = [data valueForKey:@"content"];

        if(popListController.filterdCountriesArray == nil)
            popListController.filterdCountriesArray = [[NSMutableArray alloc] initWithCapacity:0];
        else
            [popListController.filterdCountriesArray removeAllObjects];
        
        for(NSMutableDictionary *dictionary in skills_array){
            [popListController.filterdCountriesArray addObject:[dictionary valueForKey:@"skillName"]];
        }
        [popListController.tableView reloadData];
    }
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.text.length == 0) || [textField.text isEqualToString:@""]){
        [skills_textFiled becomeFirstResponder];
    }else{
        NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        completeString = [Utility trim:completeString];
        
        completeString= [Utility trim:completeString];
        
        if([completeString length] >= 2){
            
            if([completeString length]%2==0)
            [self searchActionInvoke:completeString];
            
        }else{
            [autocompleteTableView dismissPopoverAnimated:YES];
            [popListController.filterdCountriesArray  removeAllObjects];
            [popListController.tableView reloadData];
            [skills_textFiled becomeFirstResponder];
        }
        skills_textFiled = textField;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[self shwoAutoCompleteLocations:textField];
    //[popListController filterTheArray:completeString];
    return YES;
}

-(void)allocPopOver
{
    popListController  = [[PopOverListController alloc] initWithNibName:@"PopOverListController" bundle:nil];
    //popListController.filterdCountriesArray = [CompanyHelper getDropDownArrayWithTittleKey:@"skillName" parantKey:@"skills"];
    //popListController.allCountriesArray = [CompanyHelper getDropDownArrayWithTittleKey:@"skillName" parantKey:@"skills"];
    popListController.delegate = self;
    
    autocompleteTableView = [[WYPopoverController alloc] initWithContentViewController:popListController];
    autocompleteTableView.delegate = self;
    autocompleteTableView.dismissOnTap = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    
    
}


-(void)shwoAutoCompleteLocations:(UITextField *)textField
{
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    skills_textFiled = textField;
    
    if(!autocompleteTableView.isPopoverVisible){
        [self allocPopOver];
        [autocompleteTableView presentPopoverFromRect:textField.bounds inView:textField permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
}

-(void)didSelectValue:(NSString *)value forIndex:(int)index
{
  //  dispatch_async(dispatch_get_main_queue(), ^{
     //   [self.view endEditing:YES];
    //});
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    skills_textFiled.text = @"";
   
      [skills_textFiled becomeFirstResponder];
    if([tagArray count] == 20)
        return;
    
    NSLog(@"%@  %d",value,index);
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
    
//    NSArray *arrayReload = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
   // [self.table_view  reloadRowsAtIndexPaths:arrayReload withRowAnimation:UITableViewRowAnimationNone];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
      [skills_textFiled becomeFirstResponder];
    [self.table_view reloadData];
   
}

-(void)textChanged:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
