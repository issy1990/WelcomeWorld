//
//  WRForgotPasswordController.m
//  workruit
//
//  Created by Admin on 11/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRForgotPasswordController.h"

@interface WRForgotPasswordController ()<UITextFieldDelegate>
{
    UITextField *forgotPasswordTF;
    IBOutlet UIView * myView;

}
@end

@implementation WRForgotPasswordController


-(IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [Mixpanel sharedInstanceWithToken:MIX_PANEL];
    UIView *borderLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    [borderLine1 setBackgroundColor:DividerLineColor];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    UIView *borderLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    [borderLine2 setBackgroundColor:DividerLineColor];
    [footerView addSubview:borderLine2];
    
    /*
     UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 50)];
    lbl.numberOfLines = 3;
    lbl.text = @"Please check your email for the link to \n reset your password.";
    lbl.font = [UIFont fontWithName:GlobalFontRegular size:15.0f];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor lightGrayColor];
    [footerView addSubview:lbl];
     */

    self.table_view.tableHeaderView = borderLine1;
    self.table_view.tableFooterView = footerView;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    [Utility setThescreensforiPhonex:myView];


}
-(void)viewDidAppear:(BOOL)animated
{
    [forgotPasswordTF becomeFirstResponder];
}
-(IBAction)forgotPasswordAction:(id)sender
{
    if([[Utility trim:forgotPasswordTF.text] length] <= 0){
        [CustomAlertView showAlertWithTitle:@"Error" message:@"Please enter email addres." OkButton:@"OK" delegate:self];
        return;
    }
    NSLog(@"%@",forgotPasswordTF.text);
    NSString *forgotPassword = [NSString stringWithFormat:@"%@",forgotPasswordTF.text];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:forgotPassword forKey:@"username"];
    NSLog(@"%@",params);
    [[CompanyHelper sharedInstance] forgotPasswordComapny:self requestType:121212 params:params];

}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 121212 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
 
        if ([Utility isComapany])
            [FireBaseAPICalls captureMixpannelEvent:COMPANY_GENERAL_FORGOTPASSWORD];
        else
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_FORGOT_PASSWORD];
        
    [FireBaseAPICalls captureScreenDetails:@"forgot_password"];
        [CustomAlertView showAlertWithTitle:@"Sucess" message:@"Please check your email, we have sent reset link." OkButton:@"OK" delegate:self];
    }
}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag{}



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
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
    CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
        cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
    }
    
    cell.ValueTF.delegate = self;
    forgotPasswordTF = cell.ValueTF;
    if ([Utility isComapany]) {
        
        cell.titleLbl.text = @"Email Address";
        cell.ValueTF.placeholder = @"Email Address";
        
    }else{
    cell.titleLbl.text = @"Email Address or Phone Number";
    cell.ValueTF.placeholder = @"Email Address or Phone Number";
    }
    cell.ValueTF.secureTextEntry = NO;
    cell.ValueTF.keyboardType =  UIKeyboardTypeEmailAddress;
    cell.ValueTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cell.ValueTF.returnKeyType = UIReturnKeyNext;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
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
