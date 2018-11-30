//
//  WRCheckYourEmail.m
//  workruit
//
//  Created by Admin on 10/1/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRCheckYourEmail.h"

@interface WRCheckYourEmail ()

@end

@implementation WRCheckYourEmail
{
    IBOutlet UIView * myView;

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nextButtonForProcess:)
                                                 name:EMAIL_VERIFICATION_SERVICE_NOTIFIER
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSString *firstname = [[NSUserDefaults standardUserDefaults]
                           valueForKey:FIRST_NAME_KEY];
    NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                valueForKey:RECRUITER_REGISTRATION_ID];
    
    NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
    
    
    [Utility getMixpanelData:COMPANY_VERIFYEMAIL_SCREEN setProperties:userName];
   
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [Utility setThescreensforiPhonex:myView];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:EMAIL_VERIFICATION_SERVICE_NOTIFIER
                                                  object:nil];}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(IBAction)nextButtonForProcess:(id)sender
{
    WRCreateCompanyProfile *company_profile = [[UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil] instantiateViewControllerWithIdentifier:WRCREATE_COMPANY_PROFILE_IDENTIFIER];
    [self.navigationController pushViewController:company_profile animated:YES];
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
