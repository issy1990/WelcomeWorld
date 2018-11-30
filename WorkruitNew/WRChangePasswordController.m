//
//  WRChangePasswordController.m
//  workruit
//
//  Created by Admin on 10/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRChangePasswordController.h"

@interface WRChangePasswordController () <UITextFieldDelegate>
{
    NSMutableDictionary *json_data;
    CustomTextField *oldPasswordTF,*newPasswordTF,*conformPasswordTF;
    IBOutlet UIView * myView;

}
@end

@implementation WRChangePasswordController

-(IBAction)backButtonAction:(id)sender
{
    if(!_save_button.isHidden){
        [CustomAlertView showAlertWithTitle:@"Message" message:@"Do you want to discard this changes?" OkButton:@"No" cancelButton:@"Yes" delegate:self withTag:100];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag
{
    if(tag == 100 && buttonIndex == 2)
        [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)saveButtonAction:(id)sender
{
   /* NSString *validation_message = @"";
    if([[json_data valueForKey:@"oldPassword"] length] <= 0){
        validation_message = @"Old Password field should not be empty.";
    }else if([[json_data valueForKey:@"newPassword"] length] <= 0){
        validation_message = @"New Password field should not be empty.";
    }else if([[json_data valueForKey:@"reenterNewPassword"] length] <= 0){
        validation_message = @"Re-Enter Password field should not be empty.";
    }else if(![[json_data valueForKey:@"newPassword"] isEqualToString:[json_data valueForKey:@"reenterNewPassword"]]){
                    validation_message = @"New Password and Re-Enter password should not match.";
    }
    
    if([validation_message length] > 1){
        [CustomAlertView showAlertWithTitle:@"Error" message:validation_message OkButton:@"Ok" delegate:self];
        return;
    }*/
    
    [json_data setObject:oldPasswordTF.text forKey:@"oldPassword"];
    [json_data setObject:newPasswordTF.text forKey:@"newPassword"];
    [json_data setObject:conformPasswordTF.text forKey:@"reenterNewPassword"];
    
    //Call service
    if([Utility isComapany])
        [[CompanyHelper sharedInstance] companyChangePassword:self requestType:100 param:json_data];
    else
        [[ApplicantHelper sharedInstance] applicantChangePassword:self requestType:100 param:json_data];
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if([[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY])
    {
        [self.navigationController popViewControllerAnimated:YES];
        if ([Utility isComapany]) {
            [FireBaseAPICalls captureMixpannelEvent:COMPANY_PASSWORD_CHANGE];
        }else{
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_PASSWORD_CHANGE];
        }
        
    }else{
        [CustomAlertView showAlertWithTitle:[data valueForKey:@"status"] message:[data valueForKey:@"msg"] OkButton:@"Ok" delegate:self];
    }
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.save_button.hidden = YES;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //Alloc the json data dictionary
    json_data = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
 
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.table_view setSeparatorColor:DividerLineColor];
    
    [Utility setThescreensforiPhonex:myView];

}

-(void)viewDidAppear:(BOOL)animated
{
    [oldPasswordTF becomeFirstResponder];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 40.0f;
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
        return 3.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        CustomTextField *text_field = [[CustomTextField alloc] initWithFrame:CGRectMake(15, 0, tableView.frame.size.width-30, CELL_HEIGHT)];
        text_field.tag = 10;
        text_field.font = [UIFont fontWithName:GlobalFontRegular size:16.0f];
        text_field.delegate = self;
        text_field.returnKeyType = UIReturnKeyDone;
        text_field.secureTextEntry = YES;
        [cell addSubview:text_field];
    }
    CustomTextField *text_field = (CustomTextField *)[cell viewWithTag:10];
    text_field.row = indexPath.row;
    text_field.section = indexPath.section;
    
    switch (indexPath.row) {
        case 0:
            oldPasswordTF = text_field;
            text_field.placeholder = @"Old Password";
            break;
        case 1:
            newPasswordTF = text_field;
            text_field.placeholder = @"New Password";
            break;
        case 2:
            conformPasswordTF = text_field;
            text_field.placeholder = @"Verify Passwrod";
            break;
    }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.save_button.hidden = NO;
    CustomTextField *text_field = (CustomTextField *)textField;
    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    completeString = [Utility trim:completeString];
    [json_data setObject:completeString forKey:[self getKeyForIndex:(int)text_field.row]];
    return YES;
}

-(NSString *)getKeyForIndex:(int)row
{
    NSString *key = @"";
    switch (row) {
        case 0:
            key = @"oldPassword";
            break;
        case 1:
            key = @"newPassword";
            break;
        case 2:
                key = @"reenterNewPassword";
            break;
    }
    return key;
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
