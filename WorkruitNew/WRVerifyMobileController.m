//
//  WRVerifyMobileController.m
//  workruit
//
//  Created by Admin on 10/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRVerifyMobileController.h"
#import "WRUploadAPicture.h"

@interface WRVerifyMobileController ()<UITextFieldDelegate>
{
    UIButton *resend_button;
    NSTimer *_timer;
    int timeCounter;
    UITextField *text_field;
    
      UILabel *information;
    IBOutlet UIView * myView;

    
}
@end

@implementation WRVerifyMobileController
@synthesize myInformationForDev;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //30 seconds
    timeCounter = 30;
    
    //Setting the table view footer view to zeero
    self.table_view.tableFooterView = [self getFooterView];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    information = [[UILabel alloc] initWithFrame:CGRectMake(100,100, self.view.frame.size.width, 50)];
    information.text = @"";
    information.font = [UIFont fontWithName:GlobalFontRegular size:18.0f];
    information.textColor = [UIColor blackColor];
    information.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:information];
    
    if(self.isFromAccountScreen == 100)
    {
          NSString *urlString = [NSString stringWithFormat:@"%@",API_BASE_URL];
        if ([urlString isEqualToString:@"https://devsecureapi.workruit.com/api"]) {
            information.hidden = NO;
            information.text = self.myInformationForDev;
        }
        else{
            information.hidden = YES;
        }
    }
    else
    {
        NSMutableDictionary *params_dic = [[NSMutableDictionary alloc] initWithCapacity:0];
        if ([ApplicantHelper sharedInstance].paramsDictionary !=nil) {
            [params_dic setObject:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:TELE_PHONE_KEY] forKey:TELE_PHONE_KEY];
            [[ApplicantHelper sharedInstance] otpServiceCallWithDelegete:self requestType:102 withParams:params_dic withServiceName:@"sendOTP"];
        }
        else
        {
        }
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@",API_BASE_URL];
    
    if ([urlString isEqualToString:@"https://devsecureapi.workruit.com/api"]) {
        
        information.hidden = NO;
    }
    else{
        information.hidden = YES;
    }
    
    [Utility setThescreensforiPhonex:myView];

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
        if ([nextCell.titleLbl.text = @"Verification Code" isEqualToString:@"Verification Code"])
        {
            [nextCell.ValueTF becomeFirstResponder];
        }
    });
}

-(void)hideLabel
{
    [information setHidden:YES];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [_timer invalidate];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER;
    CreateCompanyCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CREATE_COMPANY_CUSTOM_CELL owner:self options:nil];
        cell = (CreateCompanyCustomCell *)[topLevelObjects objectAtIndex:0];
        cell.ValueTF.delegate = self;
        [cell.ValueTF addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];

    }
    cell.titleLbl.text = @"Verification Code";
    cell.ValueTF.secureTextEntry = YES;
    cell.ValueTF.keyboardType = UIKeyboardTypeNumberPad;
    cell.ValueTF.placeholder = @"* * * *";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSString * completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

-(void)textChanged:(UITextField *)textField
{
    if([textField.text length] >= 4)
    {
        text_field = textField;
        NSMutableDictionary *parmas = [[NSMutableDictionary alloc] initWithCapacity:0];
        [parmas setObject:[NSString stringWithFormat:@"%@",textField.text] forKey:@"otpNumber"];
        [[ApplicantHelper sharedInstance] otpVerifiedServiceCallWithDelegete:self requestType:100 withParams:parmas];
    }
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if(tag == 100 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                                valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:APPLICANT_SIGNUP_OTP setProperties:userName];
      
        
        if([self.old_phone_number length] > 0){
            //Need to call delegate
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(mobileNumberDidChangeWithTag:)]) {
                [self.delegate mobileNumberDidChangeWithTag:1];
                self.delegate=nil;
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        if([[data valueForKey:@"percentage"] floatValue] > 0)
            [ApplicantHelper sharedInstance].profilePercentage = [[data valueForKey:@"percentage"] floatValue];
        
        [ApplicantHelper sharedInstance].halfProfile = [[data valueForKey:@"halfProfile"] boolValue];
         // information.text = [NSString stringWithFormat:@"OTP for Dev:%@", [data valueForKey:@"data"]];
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRLocationViewController *controller = [mystoryboard instantiateViewControllerWithIdentifier:WR_LOCATION_VIEW_CONTROLLER_IDENTIFIER];
        controller.isComingFromSignUpProcess = 100;
        NSString *valueToSave = @"location";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"screen"];
         ;
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [Utility saveApplicantObject:[ApplicantHelper sharedInstance]];
        
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if(tag == 101 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
        
        timeCounter = 30;
        [resend_button setTitle:[NSString stringWithFormat:@"0:%02d",timeCounter] forState:UIControlStateNormal];
        
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                      target:self
                                                    selector:@selector(_timerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        [resend_button removeTarget:self action:@selector(reSendCodeAction:) forControlEvents:UIControlEventTouchUpInside];
 
        
    }else if(tag == 102 && [[data valueForKey:STATUS_KEY] isEqualToString:SUCCESS_KEY]){
        
        
        information.text = [NSString stringWithFormat:@"OTP for Dev:%@", [data valueForKey:@"data"]];
        
        
    }else{
        [CustomAlertView showAlertWithTitle:@"Error" message:@"Incorrect OTP you have enterd." OkButton:@"OK" delegate:self];
        text_field.text = @"";
    }

}
-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{}


-(IBAction)previousButtonAction:(id)sender
{
    if([self.old_phone_number length] > 0){
        [self.json_data_dictionary setObject:self.old_phone_number forKey:TELE_PHONE_KEY];
    }
    if(self.isFromAccountScreen == 100){
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self.navigationController popViewControllerAnimated:YES]; //exit(0);
    }
}

-(UIView *)getFooterView
{
    UIView *footer_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    [footer_view addSubview:[Utility borderLineWithWidth:self.view.frame.size.width]];
    
    UILabel *messagelbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 50)];
    messagelbl.numberOfLines = 2;
        if(self.isFromAccountScreen == 100)
            messagelbl.text = [NSString stringWithFormat:@"We've sent an SMS to your phone number \n (%@) with a PIN.",[self.json_data_dictionary valueForKey:TELE_PHONE_KEY]];
        else
            messagelbl.text = [NSString stringWithFormat:@"We've sent an SMS to your phone number \n (%@) with a PIN.",[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:TELE_PHONE_KEY]];
    messagelbl.textAlignment = NSTextAlignmentCenter;
    messagelbl.font = [UIFont fontWithName:GlobalFontRegular size:14.0f];
    messagelbl.textColor = UIColorFromRGB(0x2F2F2F);
    [footer_view addSubview:messagelbl];
    
    resend_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [resend_button setFrame:CGRectMake(0, 70, self.view.frame.size.width, 30)];
    [resend_button setTitle:@"0:30" forState:UIControlStateNormal];
    resend_button.titleLabel.font = [UIFont fontWithName:GlobalFontSemibold size:13.0f];
    [resend_button setTitleColor:UIColorFromRGB(0x337ab7) forState:UIControlStateNormal];
    [footer_view addSubview:resend_button];

    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(_timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    }


    return footer_view;
}
-(void)_timerFired:(id)sender
{
    timeCounter -- ;
    [resend_button setTitle:[NSString stringWithFormat:@"0:%02d",timeCounter] forState:UIControlStateNormal];
    
    if(timeCounter == 0){
            [_timer invalidate];
            _timer= nil;
        [resend_button setTitle:[NSString stringWithFormat:@"Resend Code"] forState:UIControlStateNormal];
        [resend_button addTarget:self action:@selector(reSendCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)reSendCodeAction:(id)sender
{
    NSMutableDictionary *parmas = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if(self.isFromAccountScreen == 100)
            [parmas setObject:[self.json_data_dictionary valueForKey:TELE_PHONE_KEY] forKey:TELE_PHONE_KEY];
        else
            [parmas setObject:[[ApplicantHelper sharedInstance].paramsDictionary valueForKey:TELE_PHONE_KEY] forKey:TELE_PHONE_KEY];
    
    [[ApplicantHelper sharedInstance] otpServiceCallWithDelegete:self requestType:101 withParams:parmas withServiceName:@"reSendOTP"];
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
