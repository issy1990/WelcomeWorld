//
//  WRACMatchScreen.m
//  workruit
//
//  Created by Admin on 1/7/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "WRACMatchScreen.h"
#import "HeaderFiles.h"

@interface WRACMatchScreen ()<HTTPHelper_Delegate>
{
    
    BOOL isConversationStarted;
}
@end

@implementation WRACMatchScreen

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([Utility isComapany])
        [FireBaseAPICalls captureScreenDetails:COMPANY_MATCH];
    else
        [FireBaseAPICalls captureScreenDetails:APPLICANT_MATCH];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    if ([Utility isComapany]) {

        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];

        [Utility getMixpanelData:COMPANY_MATCH_SCREEN setProperties:userName];

    }else{
    
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        [Utility getMixpanelData:APPLICANT_MATCHSCREEN setProperties:userName];
    }

    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    //self.backgroundView.layer.cornerRadius = 10.0f;
    //self.backgroundView.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view.
    if(self.notification_payload == nil)
        return;
        
    self.image_view.layer.cornerRadius = self.image_view.frame.size.width/2;
    self.image_view.layer.masksToBounds = YES;
    
    NSString *url;
    if([Utility isComapany]){
        url = [NSString stringWithFormat:@"%@/user/%@/recruiterApplicantMatches",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]];
    }else{
        url = [NSString stringWithFormat:@"%@/user/%@/applicantJobMatches",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
    }
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = self;
    [manager startRequestWithURL:url  WithParams:nil forRequest:100 controller:self httpMethod:HTTP_GET];
    
    if([Utility isComapany]){
        [self.image_view sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.notification_payload valueForKey:@"applicant_photo"]]]
                           placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]
                                    options:SDWebImageRefreshCached];
        
        self.lable_1.text = [NSString stringWithFormat:@"You've matched with %@ %@ for %@ role!",[self.notification_payload valueForKey:@"applicant_first_name"],[self.notification_payload valueForKey:@"applicant_last_name"],[self.notification_payload valueForKey:@"job_post_title"]];
    }
    else
    {
        
        NSLog(@"%@",[self.notification_payload valueForKeyPath:@"recruiter_name"]);
        NSInteger nWords = 2;
        NSRange wordRange = NSMakeRange(0, nWords);
        
        NSString *totalName = [NSString stringWithFormat:@"%@",[self.notification_payload valueForKeyPath:@"recruiter_name"] ];
        NSArray *firstWords = [[totalName componentsSeparatedByString:@" "] subarrayWithRange:wordRange];
        NSString *result = [firstWords componentsJoinedByString:@" "];
        [self.image_view sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.notification_payload valueForKey:@"company_logo"]]]
                           placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                    options:SDWebImageRefreshCached];
       // NSLog(@"%@",result);
        
        
        
        if ([[self.notification_payload valueForKeyPath:@"recruiter_name"] isEqualToString:@"Manikanth Challa (Founder)"]&&[[self.notification_payload valueForKeyPath:@"job_post_title"]isEqualToString:@"Hello from Workruit"])
        {
            
               self.lable_1.text = [NSString stringWithFormat:@"You've matched with Manikanth Challa for %@ role at %@.",[self.notification_payload valueForKeyPath:@"job_post_title"],[self.notification_payload valueForKeyPath:@"company_name"]];
            [self.chat_with_button setTitle:@"View Message" forState:UIControlStateNormal];
        }
        else
        {
            self.lable_1.text = [NSString stringWithFormat:@"You've matched with %@ for %@ role at %@.",result,[self.notification_payload valueForKeyPath:@"job_post_title"],[self.notification_payload valueForKeyPath:@"company_name"]];
        }
    }
}

-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 100){
        if([Utility isComapany]){
            
            NSString *payloadChannel = self.notification_payload[@"channel"];
            NSMutableArray *arrayObjects = [data valueForKey:@"data"];
            for (NSUInteger i = 0; i < arrayObjects.count; i++) {
                NSMutableDictionary *jobInfo = [arrayObjects[i] mutableCopy];
                NSString *channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[jobInfo valueForKeyPath:@"jobPostId.jobPostId"],[jobInfo valueForKeyPath:@"userId.userId"]];
                if ([channel_name isEqualToString:payloadChannel]) {
                    self.dictionary_global = jobInfo;
                    break;
                }

            }
//            if([arrayObjects count] > 0)
//                self.dictionary_global = [arrayObjects objectAtIndex:0];
            
        }else{
            
            NSString *payloadChannel = self.notification_payload[@"channel"];
            NSMutableArray *arrayObjects = [data valueForKey:@"data"];
            for (NSUInteger i = 0; i < arrayObjects.count; i++) {
                NSMutableDictionary *jobInfo = [arrayObjects[i] mutableCopy];
                NSString *channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[jobInfo valueForKeyPath:@"jobPostId"],[[NSUserDefaults standardUserDefaults] valueForKeyPath:APPLICANT_REGISTRATION_ID]];
                if ([channel_name isEqualToString:payloadChannel]) {
                    self.dictionary_global = jobInfo;
                    break;                    
                }
                
            }
//            if([arrayObjects count] > 0)
//                self.dictionary_global = [arrayObjects objectAtIndex:0];
        }

        NSMutableDictionary *params_dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [params_dictionary setObject:[self.notification_payload valueForKey:@"job_match_id"] forKey:@"jobMatchId"];
        [params_dictionary setObject:[Utility isComapany]?[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID] forKey:@"userId"];
        
        ConnectionManager *manager1 = [[ConnectionManager alloc] init];
        manager1.delegate = self;
        [manager1 startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,@"/push/acknowledge"]  WithParams:[CompanyHelper convertDictionaryToJSONString:params_dictionary] forRequest:-101 controller:self httpMethod:HTTP_POST];
    }else{}
}

-(void)didFailedWithError:(NSError *)error forTag:(int)tag
{
    
}

-(IBAction)keepLookingButtonClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:0] forKey:FIRSTTIMECALLCONVERSATIONS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)startConversation
{
    if ([Utility isComapany]) {
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:RECRUITER_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        [Utility getMixpanelData:COMPANY_STARTACONVERSATION setProperties:userName];

    }else{
    
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        [Utility getMixpanelData:APPLICANT_STARTACONVERSATION setProperties:userName];
    }

    
    if ([[self.notification_payload valueForKeyPath:@"recruiter_name"] isEqualToString:@"Manikanth Challa (Founder)"]&&[[self.notification_payload valueForKeyPath:@"job_post_title"]isEqualToString:@"Hello from Workruit"])
    {
        NSString *valueToSave = @"View Message";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"ChatMessagesd"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:[NSString stringWithFormat:@"%@_SendMessageViaServer",[self.notification_payload valueForKey:@"channel"]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(isConversationStarted)
            return;
        
        isConversationStarted = YES;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:STARTCONVERSATION_NOTIFICATION object:nil userInfo:[self.dictionary_global mutableCopy]];
    }
    else
    {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:[NSString stringWithFormat:@"%@_SendMessageViaServer",[self.notification_payload valueForKey:@"channel"]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(isConversationStarted)
        return;

    isConversationStarted = YES;

    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:STARTCONVERSATION_NOTIFICATION object:nil userInfo:[self.dictionary_global mutableCopy]];
    }
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
