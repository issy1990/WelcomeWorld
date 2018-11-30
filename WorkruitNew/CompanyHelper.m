//
//  CompanyHelper.m
//  workruit
//
//  Created by Admin on 9/30/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CompanyHelper.h"

@implementation CompanyHelper

+(CompanyHelper *)sharedInstance
{
    static CompanyHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CompanyHelper alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveApplicantObject:)
                                                     name:SAVE_LOCAL_OBJECTS_NOTIFICATION
                                                   object:nil];
        
    }
    return self;
}


-(void)saveApplicantObject:(NSNotification *)notification
{
    [Utility saveCompanyObject:self];
}

-(void)setParamsValue:(NSString *)val forKey:(NSString *)key
{
    if(self.params == nil){
        self.params = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self.params setObject:@"ios" forKey:DEVICE_TYPE_KEY];
    }
    if (val) {
     [self.params setObject:val forKey:key];
    }
}

//companyPrefrencesParams
-(void)setPrefrancesParams:(id)val forKey:(NSString *)key
{
    if(self.companyPrefrencesParams == nil){
        self.companyPrefrencesParams = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self.companyPrefrencesParams setObject:@"ios" forKey:DEVICE_TYPE_KEY];
    }
    [self.companyPrefrencesParams setObject:val forKey:key];
}
/*
 -(void)setCreateJobsParamsValue:(NSString *)value Key:(NSString *)Key
 {
 if(self.createJobParams == nil){
 self.createJobParams = [[NSMutableDictionary alloc] initWithCapacity:0];
 [self.createJobParams setObject:@"ios" forKey:DEVICE_TYPE_KEY];
 }
 [self.createJobParams setObject:value forKey:Key];
 }*/

-(NSString *)getEditCompanyValueWithindex:(int)index row:(int)row
{
    NSString *value = @"";
    if(index == 1 && row == 0)
        return [self.params valueForKey:COMPANY_NAME_KEY];
    else if(index == 1 && row == 1)
        return [self.params valueForKey:COMPANY_WEBSITE_KEY];
    else if(index == 1 && row == 2){
        if([self.params valueForKeyPath:@"location.title"])
            return  [self.params valueForKeyPath:@"location.title"];
        else
            return [self.params valueForKey:LOCATION_NAME_KEY];
    }else if(index == 1 && row == 3){
        if([self.params valueForKeyPath:@"size.csTitle"])
            return  [self.params valueForKeyPath:@"size.csTitle"];
        else
            return [self.params valueForKey:COMAPANY_SIZE_KEY];
    }else if(index == 1 && row == 4)
        return [self.params valueForKey:COMPANY_FOUNDED_YEAR_KEY];
    else if(index == 3)
        return [[[self.params valueForKey:COMAPNY_SOCIAL_MEDIA_LINKS_KEY] objectAtIndex:row] valueForKey:@"socialMediaValue"];
    return value;
}


-(NSMutableDictionary *)getParamsObject
{
    return self.params;
}

-(void)createAccountServiceCallWithDelegate:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *local_params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [local_params setObject:[self.params valueForKey:FIRST_NAME_KEY]  forKey:FIRST_NAME_KEY];
    [local_params setObject:[self.params valueForKey:LAST_NAME_KEY]  forKey:LAST_NAME_KEY];
    [local_params setObject:[self.params valueForKey:EMAIL_KEY]  forKey:EMAIL_KEY];
    [local_params setObject:[self.params valueForKey:TELE_PHONE_KEY]  forKey:TELE_PHONE_KEY];
    
    [local_params setObject:[self.params valueForKey:PASSWORD_KEY] forKey:PASSWORD_KEY];
    [local_params setObject:[self.params valueForKey:RECRUITER_COMPANY_NAME_KEY]  forKey:RECRUITER_COMPANY_NAME_KEY];
    [local_params setObject:[self.params valueForKey:JOB_ROLE_ID_KEY] forKey:JOB_ROLE_ID_KEY];
    [local_params setObject:DEVICE_TYPE_STRING forKey:DEVICE_TYPE_KEY];
    [local_params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID] forKey:REGD_ID_KEY];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,RECRUITER_SIGNUP_API] WithParams:[CompanyHelper convertDictionaryToJSONStringWithPassword:local_params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)saveComapnyServiceCallWithDelegate:(id)delegate requestType:(int)requestType
{
    NSString *recruiter_id = [[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID];
    
    NSMutableDictionary *local_params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [local_params setObject:[self.params valueForKey:COMPANY_NAME_KEY] forKey:COMPANY_NAME_KEY];
    [local_params setObject:[self.params valueForKey:COMPANY_WEBSITE_KEY] forKey:COMPANY_WEBSITE_KEY];
    [local_params setObject:[NSNumber numberWithInt:[recruiter_id intValue]]  forKey:USER_ID_KEY];
    [local_params setObject:[self.params valueForKey:USER_JOB_ROLE_KEY] forKey:USER_JOB_ROLE_KEY];
    [local_params setObject:[self.params valueForKey:SIZE_KEY] forKey:SIZE_KEY];
    [local_params setObject:[self.params valueForKey:LOCATION_KEY] forKey:LOCATION_KEY];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,SAVE_COMAPNY_API] WithParams:[CompanyHelper convertDictionaryToJSONString:local_params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)updateComapnyServiceCallWithDelegate:(id)delegate requestType:(int)requestType
{
    NSString *recruiter_id = [[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID];
    
    
    NSMutableDictionary *local_params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [local_params setObject:[self.params valueForKey:COMPANY_NAME_KEY] forKey:COMPANY_NAME_KEY];
    [local_params setObject:[self.params valueForKey:COMPANY_WEBSITE_KEY] forKey:COMPANY_WEBSITE_KEY];
    //[local_params setObject:[self.params valueForKey:USER_JOB_ROLE_KEY] forKey:USER_JOB_ROLE_KEY];
    [local_params setObject:[self.params valueForKey:SIZE_KEY] forKey:SIZE_KEY];
    [local_params setObject:[self.params valueForKey:LOCATION_KEY] forKey:LOCATION_KEY];
    [local_params setObject:[self.params valueForKey:COMAPNY_INDUSTRIES_SET_KEY] forKey:COMAPNY_INDUSTRIES_SET_KEY];
    [local_params setObject:[self.params valueForKey:COMAPNY_SOCIAL_MEDIA_LINKS_KEY] forKey:COMAPNY_SOCIAL_MEDIA_LINKS_KEY];
    [local_params setObject:[self.params valueForKey:COMPANY_DESCRIPTION] forKey:COMPANY_DESCRIPTION];
    
    if([self.params valueForKey:COMPANY_FOUNDED_YEAR_KEY])
        [local_params setObject:[self.params valueForKey:COMPANY_FOUNDED_YEAR_KEY] forKey:COMPANY_FOUNDED_YEAR_KEY];
    
    if([[self.params valueForKey:@"pic"] length] > 0)
        [local_params setObject:[self.params valueForKey:@"pic"] forKey:@"pic"];
    
    [local_params setObject:[NSNumber numberWithInt:[recruiter_id intValue]] forKey:USER_ID_KEY];
    [local_params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:SAVE_COMPANY_ID] forKey:@"companyId"];
    
    NSMutableArray *industryArray = [self.params valueForKey:COMAPNY_INDUSTRIES_SET_KEY];
    NSMutableArray *formatedArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(NSMutableDictionary *dictionary in industryArray){
        NSMutableDictionary *industry_object = [[NSMutableDictionary alloc] initWithCapacity:0];
        [industry_object setObject:[dictionary valueForKey:@"industryId"] forKey:@"industryId"];
        NSMutableDictionary *new_object = [[NSMutableDictionary alloc] initWithCapacity:0];
        [new_object setObject:industry_object forKey:@"industry"];
        [formatedArray addObject:new_object];
    }
    
    [local_params  setObject:formatedArray forKey:COMAPNY_INDUSTRIES_SET_KEY];
    [local_params  setObject:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:SAVE_COMPANY_ID]] forKey:@"companyId"];
    [local_params  setObject:[NSNumber numberWithInt:[recruiter_id intValue]] forKey:@"userId"];
    
    
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,SAVE_COMAPNY_API] WithParams:[CompanyHelper convertDictionaryToJSONString:local_params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)getApplicantProfilesWithDelegate:(id)delegate requestType:(int)requestType
{    
    NSString *url = [NSString stringWithFormat:@"/user/%@/viewPostedJobs",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]];
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)getPostedJobsOtherThanClosingWithDelegate:(id)delegate requestType:(int)requestType
{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"loadIndi1"];

    NSString *url = [NSString stringWithFormat:@"/user/%@/postedJobsOtherThanClosing",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]];
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)getRecruterProfile:(id)delegate requestType:(int)requestType
{
    NSString *url = [NSString stringWithFormat:@"/user/%@/getRecruiterProfile",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)getCompanyProfile:(id)delegate requestType:(int)requestType
{
    NSString *url = [NSString stringWithFormat:@"/%@/getCompanyProfile",[[NSUserDefaults standardUserDefaults] valueForKey:SAVE_COMPANY_ID]];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)updateRecruiterProfilesWithDelegate:(id)delegate requestType:(int)requestType param:(NSMutableDictionary *)params
{
    NSString *url = [NSString stringWithFormat:@"/user/%@/updateRecruiterProfile",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:[CompanyHelper convertDictionaryToJSONString:params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}
-(void)companyChangePassword:(id)delegate requestType:(int)requestType param:(NSMutableDictionary *)params
{
    NSString *url = [NSString stringWithFormat:@"/user/%@/updateUserPassword",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:[CompanyHelper convertDictionaryToJSONString:params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)getProfilesForJob:(id)delegate requestType:(int)requestType
{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"loadIndi"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"/job/%@/profiles",[defaults valueForKey:@"lastCreatedJobId"]];
    
    NSLog(@"****** %@ *********",url);
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)updateSwipeActionToServer:(NSMutableDictionary *)params delegate:(id)delegate requestType:(int)requestType withURL:(NSString *)urlStr
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,urlStr] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)getRecruterMatches:(id)delegate requestType:(int)requestType
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,[NSString stringWithFormat:@"/user/%@/recruiterApplicantMatches",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]]] WithParams:nil  forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)getShortListedProfiles:(id)delegate requestType:(int)requestType
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    // [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,[NSString stringWithFormat:@"/job/%@/viewShortListedProfiles",[[NSUserDefaults standardUserDefaults] valueForKey:LAST_CREATED_JOB_ID]]] WithParams:nil  forRequest:requestType controller:delegate httpMethod:HTTP_GET];
    //user/112/recruiterInterestedProfiles
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,[NSString stringWithFormat:@"/user/%@/recruiterInterestedProfiles",[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]]] WithParams:nil  forRequest:requestType controller:delegate httpMethod:HTTP_GET];
    
}

-(void)loginComapny:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,@"/login"] WithParams:[CompanyHelper convertDictionaryToJSONStringWithPassword:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)forgotPasswordComapny:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,@"/resetPasswordLinkToEmail"] WithParams:[CompanyHelper convertDictionaryToJSONStringWithPassword:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)logOutCompany:(id)delegate requestType:(int)requestType
{
    NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    
    if([session_id length] > 10){
        
        session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    }
    else{
        session_id = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"sessionName"];
        
        
    }
    
    
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/%@/logout",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID],session_id];
    
    NSLog(@" logout url %@",url);
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:url  WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)updatePrefrences:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params
{
    ///job/6/recruiterPreferences
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/job/%@%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:@"lastCreatedJobId"],@"/recruiterPreferences"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}


+(NSString *)convertDictionaryToJSONString:(NSMutableDictionary *)dictionary
{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    NSString *requestParams =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    if([session_id length] > 10){
        
        session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
    }
    else{
        session_id = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"sessionName"];
        
        
    }
    requestParams = [AESCrypt encrypt:requestParams password:session_id];
    return  requestParams;
}
+(NSString *)convertDictionaryToJSONStringWithPassword:(NSMutableDictionary *)dictionary
{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    NSString *requestParams =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    requestParams = [AESCrypt encrypt:requestParams password:@"password"];
    return  requestParams;
}

+(BOOL)IsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    stricterFilter = [emailTest evaluateWithObject:checkString];
    return stricterFilter;
}

+(BOOL)checkEmailisWorkEmail:(NSString *)email
{
    return NO;
    
    /*if([email containsString:@"gmail"] || [email containsString:@"yahoo"] || [email containsString:@"hotmail"])
     return YES;
     else
     return NO;*/
}

-(NSString *)validateRequestParams
{
    NSString *message = SUCESS_STRING;
    if([[Utility trim:[self.params valueForKey:FIRST_NAME_KEY]] length] <= 0)
        message = @"Please enter your first name.";
    else if([[Utility trim:[self.params valueForKey:LAST_NAME_KEY]] length] <= 0)
        message = @"Please enter your last name.";
    else if([[self.params valueForKey:EMAIL_KEY] length] <= 0 || ![CompanyHelper IsValidEmail:[self.params valueForKey:EMAIL_KEY]] || [CompanyHelper checkEmailisWorkEmail:[self.params valueForKey:EMAIL_KEY]])
        message = @"Please enter your email address.";
    else if([[self.params valueForKey:PASSWORD_KEY] length] <= 6)
        message = @"Password must be 8 characters or more.";
    else if([[self.params valueForKey:TELE_PHONE_KEY] length]  < 8 || [[self.params valueForKey:TELE_PHONE_KEY] length] > 11)
        message = @"Please enter valid phone number.";
    else if([[Utility trim:[self.params valueForKey:RECRUITER_COMPANY_NAME_KEY]] length] <= 0 )
        message = @"Please enter company name.";
    else if([[self.params valueForKey:JOB_ROLE_ID_KEY] intValue]  <= 0)
        message = @"Please select your role.";
    else message = SUCESS_STRING;
    return message;
}

-(NSString *)validateCompanyProfileParams
{
    NSString *message = SUCESS_STRING;
    if([[Utility trim:[self.params valueForKey:COMPANY_WEBSITE_KEY]] length] <= 0)
    {
        
        message = @"Please enter company website link";
    }
    else if(![self.params valueForKey:SIZE_KEY] )
        message = @"Please select company size";
    else if(![self.params valueForKey:LOCATION_KEY])
        message = @"Please select company location";
    return message;
}

- (void)validateFoundedYearandCompanyDescription:(NSString **)message {
    //*******************COMPANY_FOUNDED_YEAR_KEY*******************
    NSString *foundYear = [NSString stringWithFormat:@"%@",[self.params valueForKey:COMPANY_FOUNDED_YEAR_KEY]];
    NSString *foundYearValidateString = [Utility trim:foundYear];
    
    //*******************COMPANY_DESCRIPTION*******************
    NSString *cmpStr = [NSString stringWithFormat:@"%@",[self.params valueForKey:COMPANY_DESCRIPTION]];
    NSString *validateString = [Utility trim:cmpStr];
    
    if([foundYearValidateString length] == 0 || [foundYearValidateString isEqualToString:@""]) {
        *message = @"Please enter founded date of your company.";
    } else if([validateString length] == 0 || [validateString isEqualToString:@""]) {
        *message = @"Please enter description about your company.";
    }
}

-(NSString *)validateEditCompanyProfileParams {
    NSString *message = SUCESS_STRING;
    [self validateFoundedYearandCompanyDescription:&message];
    return message;
}

+(NSString *)getParamsStringWithIndex:(int)index screenId:(int)screenId
{
    if(screenId == 1){
        switch (index) { // Create company
            case 1:
                return FIRST_NAME_KEY;
                break;
            case 2:
                return LAST_NAME_KEY;
                break;
            case 3:
                return EMAIL_KEY;
                break;
            case 4:
                return  PASSWORD_KEY;
                break;
            case 5:
                return  TELE_PHONE_KEY;
                break;
            case 6:
                return RECRUITER_COMPANY_NAME_KEY;
                break;
            case 7:
                return  JOB_ROLE_KEY;
                break;
            default:
                return FIRST_NAME_KEY;
                break;
        }
    }else if(screenId == 2){  //Edit Profile
        switch (index) {
            case -1:
                return JOB_ROLE_KEY;
                break;
            case 1:
                return RECRUITER_COMPANY_NAME_KEY;
                break;
            case 2:
                return COMPANY_WEBSITE_KEY;
                break;
            case 3:
                return  COMAPANY_SIZE_KEY;
                break;
            case 4:
                return  LOCATION_KEY;
                break;
            default:
                return FIRST_NAME_KEY;
                break;
        }
    }else if(screenId == 3){ //Edit company
        switch (index) {
            case 0:
                return COMPANY_NAME_KEY;
                break;
            case 1:
                return COMPANY_WEBSITE_KEY;
                break;
            case 2:
                return LOCATION_NAME_KEY;
                break;
            case 3:
                return  COMAPANY_SIZE_KEY;
                break;
            case 4:
                return  COMPANY_FOUNDED_YEAR_KEY;
                break;
            default:
                return COMPANY_DESCRIPTION;
                break;
        }
    }else{
        return @"";
    }
}



+(NSMutableArray *)getDropDownArrayWithTittleKey:(NSString *)titleKey parantKey:(NSString *)parantKey
{
    
    NSMutableArray *jobRolesArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"MasterData"]valueForKey:parantKey];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *dictionary in jobRolesArray)
        [array addObject:[dictionary valueForKey:titleKey]];
    
    return array;
}


+(NSMutableArray *)getYearsArray
{
    NSMutableArray *arrayObjects = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0 ; i  < 30; i++){
        if(i > 1)
            [arrayObjects addObject:[NSString stringWithFormat:@"%d years",i]];
        else
            [arrayObjects addObject:[NSString stringWithFormat:@"%d year",i]];
    }
    
    return arrayObjects;
}

+(NSMutableArray *)getMonthsArray
{
    NSMutableArray *arrayObjects = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0 ; i  < 12; i++){
        
        if(i == 0 || i == 1){
            
            [arrayObjects addObject:[NSString stringWithFormat:@"%d month",i]];
        }
        else{
            
            [arrayObjects addObject:[NSString stringWithFormat:@"%d months",i]];
            
            
        }
        
        
        
    }
    
    return arrayObjects;
    
}

+(NSMutableArray *)getAllCities
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSError *error =  nil;
    NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *dictionary in jsonDataArray)
        [array addObject:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"name"]]];
    
    return array;
}

+(NSString *)getJobRoleIdWithIndex:(int)index parantKey:(NSString *)parantKey childKey:(NSString *)childKey
{
    NSMutableArray *jobRolesArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"MasterData"] valueForKey:parantKey];
    return [[jobRolesArray objectAtIndex:index] valueForKey:childKey];
}

+(int)getJobRoleIdWithValue:(NSString *)value parantKey:(NSString *)parantKey childKey:(NSString *)childKey
{
    int idx = 0;
    NSMutableArray *jobRolesArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"MasterData"] valueForKey:parantKey];
    for (int i  = 0; i < [jobRolesArray count]; i++){
        NSMutableDictionary *dictionary = [jobRolesArray objectAtIndex:i];
        if([[NSString stringWithFormat:@"%@",[dictionary valueForKey:childKey]] isEqualToString:[NSString stringWithFormat:@"%@",value]]){
            idx = i;
            break;
        }
    }
    return idx;
}

+(NSString *)getJobRoleNameWithId:(NSString *)id_value parantKey:(NSString *)parantKey childKey:(NSString *)childKey valueKey: (NSString *)valueKey
{
    NSString *final_value = @"";
    NSMutableArray *jobRolesArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"MasterData"] valueForKey:parantKey];
    for (int i  = 0; i < [jobRolesArray count]; i++){
        NSMutableDictionary *dictionary = [jobRolesArray objectAtIndex:i];
        if([[dictionary valueForKey:childKey] intValue]==  [id_value intValue]){
            final_value = [dictionary valueForKey:valueKey];
            break;
        }
    }
    return final_value;
}

+(NSMutableArray *)getArrayWithParentKey:(NSString *)parant_key
{
    NSLog(@"my data %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"MasterData"] );
    
    NSMutableArray *array_objects = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dic in [[[NSUserDefaults standardUserDefaults] valueForKey:@"MasterData"] valueForKey:parant_key] ) {
        NSMutableDictionary* oldTemplates = [NSMutableDictionary dictionaryWithDictionary:dic];
        [array_objects addObject:oldTemplates];
    }
    return array_objects;
}
@end
