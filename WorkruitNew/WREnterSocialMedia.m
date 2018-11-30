//
//  WREnterSocialMedia.m
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WREnterSocialMedia.h"

@interface WREnterSocialMedia ()<UITextFieldDelegate>
{
    NSArray *titleArray;
    IBOutlet UIView * myView;

}
@end

@implementation WREnterSocialMedia
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"params %@",[CompanyHelper sharedInstance]);
    
    // Do any additional setup after loading the view.
    titleArray = [[NSArray alloc] initWithObjects:@"Facebook",@"LinkedIn",@"Twitter", nil];
    
    //Setting the table view footer view to zeero
    self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    [Utility setThescreensforiPhonex:myView];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
    CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
        cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
    }
    cell.titleLbl.text = [titleArray objectAtIndex:indexPath.row];
    cell.ValueTF.tag = indexPath.row + 1;
    cell.ValueTF.delegate = self;
    cell.ValueTF.autocorrectionType = UITextAutocorrectionTypeNo;
    NSLog(@"%ld",(long)cell.ValueTF.tag);
    
    if(indexPath.row == 0){
        cell.ValueTF.placeholder = @"https://facebook.com/";
    }else if(indexPath.row == 1){
        cell.ValueTF.placeholder = @"https://linkedin.com/";
    }else{
        cell.ValueTF.placeholder = @"https://twitter.com/";
    }
    cell.ValueTF.keyboardType = UIKeyboardTypeURL;
    cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(IBAction)nextButtonForProcess:(id)sender
{
    NSMutableArray *socialMediaArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i = 0; i < 3; i++){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        if(i == 0){
            [dictionary setObject:@"Facebook" forKey:@"socialMediaName"];
            if([[[CompanyHelper sharedInstance].params valueForKey:FACEBOOK_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:FACEBOOK_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://facebook.com/" forKey:@"socialMediaValue"];
        }else if(i == 1){
            [dictionary setObject:@"LinkedIn" forKey:@"socialMediaName"];
            if([[[CompanyHelper sharedInstance].params valueForKey:LINKEDIN_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:LINKEDIN_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://linkedin.com/" forKey:@"socialMediaValue"];
                
        }else if(i == 2){
            [dictionary setObject:@"Twitter" forKey:@"socialMediaName"];
            
            if([[[CompanyHelper sharedInstance].params valueForKey:TWITTER_URL] length] > 0)
                [dictionary setObject:[[CompanyHelper sharedInstance].params valueForKey:TWITTER_URL] forKey:@"socialMediaValue"];
            else
                [dictionary setObject:@"https://twitter.com/" forKey:@"socialMediaValue"];
        }
        [socialMediaArray addObject:dictionary];
    }
    
    [[CompanyHelper sharedInstance].params setObject:socialMediaArray forKey:COMAPNY_SOCIAL_MEDIA_LINKS_KEY];
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
    WREditCompanyProfile *edit_profile_controller = [mystoryboard instantiateViewControllerWithIdentifier:WREDIT_COMPANY_PROFILE_IDENTIFIER];
    [self.navigationController pushViewController:edit_profile_controller animated:YES];
}


-(IBAction)previousButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1 && [textField.text isEqualToString:@""])
        textField.text = @"https://facebook.com/";
    else if(textField.tag == 2 && [textField.text isEqualToString:@""])
        textField.text = @"https://linkedin.com/";
    else if(textField.tag == 3 && [textField.text isEqualToString:@""])
        textField.text = @"https://twitter.com/";
    return  YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];
    if(textField.tag == 1)
        [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:FACEBOOK_URL];
    else if(textField.tag == 2)
        [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:LINKEDIN_URL];
    else if(textField.tag == 3)
        [[CompanyHelper sharedInstance] setParamsValue:completeString forKey:TWITTER_URL];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    CreateCompanyCustomCell * currentCell = (CreateCompanyCustomCell *) textField.superview.superview;
    NSIndexPath * currentIndexPath = [self.table_view indexPathForCell:currentCell];
    
    if (currentIndexPath.row != [titleArray count] - 1) {
        NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:0];
        CreateCompanyCustomCell * nextCell = (CreateCompanyCustomCell *) [self.table_view cellForRowAtIndexPath:nextIndexPath];
        [self.table_view scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [nextCell.ValueTF becomeFirstResponder];
    }
    return YES;
}

-(IBAction)skipButtonAction:(id)sender
{
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
    WREditCompanyProfile *edit_profile_controller = [mystoryboard instantiateViewControllerWithIdentifier:WREDIT_COMPANY_PROFILE_IDENTIFIER];
    edit_profile_controller.isCommingFromFlag = 200;
    [self.navigationController pushViewController:edit_profile_controller animated:YES];

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
