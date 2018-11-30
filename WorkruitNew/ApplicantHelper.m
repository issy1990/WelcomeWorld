//
//  ApplicantHelper.m
//  workruit
//
//  Created by Admin on 10/14/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ApplicantHelper.h"

@implementation ApplicantHelper

+(ApplicantHelper *)sharedInstance
{
    static ApplicantHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ApplicantHelper alloc] init];
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


-(void)setParamsValue:(NSString *)val forKey:(NSString *)key
{
    if(self.paramsDictionary == nil){
        self.paramsDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self.paramsDictionary setObject:@"ios" forKey:DEVICE_TYPE_KEY];
    }

    [self.paramsDictionary setObject:val forKey:key];
}


-(void)createAccountServiceCallWithDelegate:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *local_params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [local_params setObject:[self.paramsDictionary valueForKey:FIRST_NAME_KEY] forKey:FIRST_NAME_KEY];
    [local_params setObject:[self.paramsDictionary valueForKey:LAST_NAME_KEY] forKey:LAST_NAME_KEY];
    [local_params setObject:[self.paramsDictionary valueForKey:EMAIL_KEY] forKey:EMAIL_KEY];
    [local_params setObject:[self.paramsDictionary valueForKey:TELE_PHONE_KEY] forKey:TELE_PHONE_KEY];
    [local_params setObject:[self.paramsDictionary valueForKey:PASSWORD_KEY] forKey:PASSWORD_KEY];
    [local_params setObject:DEVICE_TYPE_STRING forKey:DEVICE_TYPE_KEY];
    [local_params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID] forKey:REGD_ID_KEY];
    NSString *valueToSave = [self.paramsDictionary valueForKey:EMAIL_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"emailName"];
    NSString *valueToSave1 = [self.paramsDictionary valueForKey:PASSWORD_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave1 forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,@"/signup"] WithParams:[CompanyHelper convertDictionaryToJSONStringWithPassword:local_params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)updateApplicantServiceCallWithDelegate:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *local_params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [local_params setObject:[self.paramsDictionary valueForKey:FIRST_NAME_KEY] forKey:FIRST_NAME_KEY];
    [local_params setObject:[self.paramsDictionary valueForKey:LAST_NAME_KEY] forKey:LAST_NAME_KEY];
    [local_params setObject:[self.paramsDictionary valueForKey:EMAIL_KEY] forKey:EMAIL_KEY];
    [local_params setObject:[self.paramsDictionary valueForKey:TELE_PHONE_KEY] forKey:TELE_PHONE_KEY];
    [local_params setObject:DEVICE_TYPE_STRING forKey:DEVICE_TYPE_KEY];
    [local_params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:PUSH_TOKEN_ID] forKey:REGD_ID_KEY];
    
    if([self.paramsDictionary valueForKey:@"skills"])
        [local_params setObject:[self.paramsDictionary valueForKey:@"skills"] forKey:@"skills"];
    
    NSMutableArray *experienceArray = [self.paramsDictionary valueForKey:@"experience"];
    if(experienceArray == nil)
        experienceArray = [self.paramsDictionary valueForKey:@"userExperienceSet"];
    
    if([experienceArray count] > 0)
        [local_params setObject:experienceArray forKey:@"experience"];
    else
        [local_params setObject:[[NSMutableArray alloc] init] forKey:@"experience"];
    
    NSMutableArray *academicArray = [self.paramsDictionary valueForKey:@"academic"];
    if(academicArray == nil)
        academicArray = [self.paramsDictionary valueForKey:@"userAcademic"];

    if([academicArray count] > 0)
        [local_params setObject:academicArray forKey:@"academic"];
    else
        [local_params setObject:[[NSMutableArray alloc] init] forKey:@"academic"];

    NSMutableArray *educationArray = [self.paramsDictionary valueForKey:@"education"];
    if(educationArray == nil)
        educationArray = [self.paramsDictionary valueForKey:@"userEducationSet"];
    
    if([educationArray count] > 0){
        NSMutableArray *local_array =  [educationArray mutableCopy];
        [local_params setObject:local_array forKey:@"education"];
        NSMutableArray *temp_array = [[NSMutableArray alloc] initWithCapacity:0];
        
        for(NSMutableDictionary *dicObj in local_array)
        {
            NSMutableDictionary *dictioanry_obj = [[NSMutableDictionary alloc] initWithDictionary:dicObj];
            [dictioanry_obj removeObjectForKey:@"degree_short_name"];
            [dictioanry_obj removeObjectForKey:@"degree_name"];
            [temp_array addObject:dictioanry_obj];
        }
        [local_params setObject:temp_array forKey:@"education"];
    }else
        [local_params setObject:[[NSMutableArray alloc] init] forKey:@"education"];

    [local_params setObject:[self.paramsDictionary valueForKey:@"location"] forKey:@"location"];
    [local_params setObject:[NSNumber numberWithInt:[[self.paramsDictionary valueForKey:@"totalexperience"] intValue]] forKey:@"totalexperience"];
    
    NSString *about_text = [self.paramsDictionary valueForKey:@"about"];
    if([about_text length] <= 0)
        about_text = [self.paramsDictionary valueForKey:@"coverLetter"];
    
    if (about_text == nil) {
        [local_params setObject:@"Enter Summary" forKey:@"about"];
        [local_params setObject:@"Enter Summary" forKey:@"coverletter"];
    }else{
        [local_params setObject:about_text forKey:@"about"];
        [local_params setObject:about_text forKey:@"coverletter"];
    }
    
  
    NSString *totalexperiencedisplay =  [self.paramsDictionary valueForKey:@"totalexperiencedisplay"];
    
    if (totalexperiencedisplay == nil)
        totalexperiencedisplay = [NSString stringWithFormat:@"0.0 years"];
        
    [local_params setObject:totalexperiencedisplay forKey:@"totalExperienceDisplay"];
    
    
    
    int currenct_status = [[self.paramsDictionary valueForKey:@"status"] intValue];
    if(currenct_status > 0)
        [local_params setObject:[NSNumber numberWithInt:currenct_status ] forKey:@"currentstatus"];
        else
            [local_params setObject:[NSNumber numberWithInt:1] forKey:@"currentstatus"];
    
    if([[self.paramsDictionary valueForKey:@"title"] length] > 0)
        [local_params setObject:[self.paramsDictionary valueForKey:@"title"] forKey:@"title"];
    else
        [local_params setObject:@"" forKey:@"title"];
    
    NSMutableArray *jobFunctionArray = [self.paramsDictionary valueForKey:@"jobfunctions"];
    if(jobFunctionArray == nil)
        jobFunctionArray = [self.paramsDictionary valueForKey:@"jobFunctions"];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];

    for(NSMutableDictionary *dictionary in jobFunctionArray){
            [array addObject:[dictionary valueForKey:@"jobFunctionId"]];
    }
    [local_params setObject:array forKey:@"jobfunctions"];
    
    if([[self.paramsDictionary valueForKey:@"maxSalaryExp"] intValue] > 0){
        [local_params setObject:[self.paramsDictionary valueForKey:@"maxSalaryExp"] forKey:@"maxSalaryExp"];
        [local_params setObject:[self.paramsDictionary valueForKey:@"minSalaryExp"] forKey:@"minSalaryExp"];
        [local_params setObject:[self.paramsDictionary valueForKey:@"hideSalary"] forKey:@"hideSalary"];
    }
   // [local_params setObject:[NSNumber numberWithInteger:3436] forKey:@"userId"];

    [local_params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID] forKey:@"userId"];

    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@/%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],@"updateProfile"] WithParams:[CompanyHelper convertDictionaryToJSONString:local_params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)updateApplicantSkillsServiceCallWithDelegate:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *local_params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [local_params setObject:[self.paramsDictionary valueForKey:@"skills"] forKey:@"skills"];
    [local_params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID] forKey:@"userId"];

    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@/%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],@"/updateSkills"] WithParams:[CompanyHelper convertDictionaryToJSONString:local_params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}
-(void)getApplicantProfile:(id)delegate requestType:(int)requestType
{
    NSString *url = [NSString stringWithFormat:@"/user/%@/getProfile",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)applicantChangePassword:(id)delegate requestType:(int)requestType param:(NSMutableDictionary *)params
{
    NSString *url = [NSString stringWithFormat:@"/user/%@/updateUserPassword",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:[CompanyHelper convertDictionaryToJSONString:params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)otpServiceCallWithDelegete:(id)delegate requestType:(int)requestType withParams:(NSMutableDictionary *)params withServiceName:(NSString *)service_name
{
    NSString *url = [NSString stringWithFormat:@"/user/%@/%@",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],service_name];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:[CompanyHelper convertDictionaryToJSONString:params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)otpVerifiedServiceCallWithDelegete:(id)delegate requestType:(int)requestType withParams:(NSMutableDictionary *)params
{
    NSString *url = [NSString stringWithFormat:@"/user/%@/validateOTP",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,url] WithParams:[CompanyHelper convertDictionaryToJSONString:params] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)logOutApplicant:(id)delegate requestType:(int)requestType
{
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/%@/logout",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],[[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID]];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:url  WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)getUserJobsForApplicant:(id)delegate requestType:(int)requestType
{
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/jobs",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:url  WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];

}

-(void)updateSwipeActionToServer:(NSMutableDictionary *)params delegate:(id)delegate requestType:(int)requestType withURL:(NSString *)urlStr
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,urlStr] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}
-(void)updateSwipeActionToServer_ExternalJobs:(NSMutableDictionary *)params delegate:(id)delegate requestType:(int)requestType withURL:(NSString *)urlStr
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,urlStr] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)getApplicantJobMatches:(id)delegate requestType:(int)requestType
{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"getApplicantJobMatches"];

    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,[NSString stringWithFormat:@"/user/%@/applicantJobMatches",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]]] WithParams:nil  forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)viewAppliedJobs:(id)delegate requestType:(int)requestType
{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"loadIndi"];

    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,[NSString stringWithFormat:@"/user/%@/viewAppliedJobs",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]]] WithParams:nil  forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}
-(void)viewAppliedJobs_External:(id)delegate requestType:(int)requestType
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,[NSString stringWithFormat:@"/user/%@/viewAppliedJobsExt",[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID]]] WithParams:nil  forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}
-(void)loginApplicant:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,@"/login"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}


-(void)getUserTotalExperiance:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@%@",API_BASE_URL,@"/yearsOfExperience"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}


-(NSString *)validateRequestParams
{
    NSString *message = SUCESS_STRING;
    if([[Utility trim:[self.paramsDictionary valueForKey:FIRST_NAME_KEY]] length] <= 0)
        message = @"Please enter your first name.";
    else if([[Utility trim:[self.paramsDictionary valueForKey:LAST_NAME_KEY]] length] <= 0)
        message = @"Please enter your last name.";
    else if([[self.paramsDictionary valueForKey:EMAIL_KEY] length] <= 0 || ![CompanyHelper IsValidEmail:[self.paramsDictionary valueForKey:EMAIL_KEY]] || [CompanyHelper checkEmailisWorkEmail:[self.paramsDictionary valueForKey:EMAIL_KEY]])
        message = @"Please enter your email address.";
    else if([[self.paramsDictionary valueForKey:PASSWORD_KEY] length] <= 6)
        message = @"Password must be 8 characters or more.";
    else if([[self.paramsDictionary valueForKey:TELE_PHONE_KEY] length]  != 10 || ![Utility mobileNumberValidation:[self.paramsDictionary valueForKey:TELE_PHONE_KEY]])
        message = @"Please enter valid phone number.";
    else message = SUCESS_STRING;
    return message;
}

-(NSString *)getParamsKeyWithIndex:(int)index withScreen:(int)screen
{
    if(screen == 0){
        switch (index) {
            case 1:
                return @"jobTitle";
                break;
            case 2:
                return @"company";
                break;
            case 3:
                return @"location";
                break;
            case 4:
                return @"startDate";
                break;
            case 5:
                return @"endDate";
                break;
            default:
                return @"test";
                break;

        }
    }else if(screen == 1){
        switch (index) {
            case 1:
                return @"institution";
                break;
            case 2:
                return @"degree_name";
                break;
            case 3:
                return @"fieldOfStudy";
                break;
            case 4:
                return @"location";
                break;
            case 5:
                return @"startDate";
                break;
            case 6:
                return @"endDate";
                break;
            default:
                return @"test";
                break;
        }
    }else{
        switch (index) {
            case 1:
                return @"role";
                break;
            case 2:
                return @"projectTitle";
                break;
            case 3:
                return @"institution";
                break;
            case 4:
                return @"location";
                break;
            case 5:
                return @"startDate";
                break;
            case 6:
                return @"endDate";
                break;
            default:
                return @"test";
                break;

        }
    }
    return @"test";
}

-(NSString *)validateExperianceParams:(NSMutableDictionary *)params
{
    NSDate *start_date = [Utility getDateWithStringDate:[params valueForKey:@"startDate"] withFormat:@"MMM yyyy"];
    NSDate *end_date = [Utility getDateWithStringDate:[params valueForKey:@"endDate"] withFormat:@"MMM yyyy"];
    

    NSDate *custom_end_date = (NSDate *)[params valueForKey:@"endDateVal"];
    custom_end_date =  [Utility getDate:custom_end_date withFromat:@"MM-dd-yyyy"];
    
    if(end_date == nil || [[params valueForKey:@"isPresent"] boolValue]){
        end_date = [NSDate date];
        end_date = [end_date dateByAddingTimeInterval:3600 * 24 * 31];
    }
    
    NSString *message = SUCESS_STRING;
    NSLog(@"%@",[params valueForKey:@"location"]);
    if([[Utility trim:[params valueForKey:@"jobTitle"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"company"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"location"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"location"]] isEqualToString:@""] )
        message = @"Please enter all the fields.";
    else if([[params valueForKey:@"startDate"] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[params valueForKey:@"endDate"] length] <= 0)
        message = @"Please enter all the fields.";
    else if([start_date compare:end_date]  == NSOrderedDescending)
        message = @"End date cannot be before your Start date.";
    else if([start_date compare:end_date]  == NSOrderedSame)
        message = @"Start date and End date cannot be from the same month.";
    return message;
}


-(NSString *)validateEducationParams:(NSMutableDictionary *)params
{
    NSDate *start_date = [Utility getDateWithStringDate:[params valueForKey:@"startDate"] withFormat:@"MMM yyyy"];
    NSDate *end_date = [Utility getDateWithStringDate:[params valueForKey:@"endDate"] withFormat:@"MMM yyyy"];

    NSDate *custom_end_date = (NSDate *)[params valueForKey:@"endDateVal"];
    custom_end_date =  [Utility getDate:custom_end_date withFromat:@"MM-dd-yyyy"];

    if(end_date == nil || [[params valueForKey:@"isPresent"] boolValue]){
        end_date = [NSDate date];
        end_date = [end_date dateByAddingTimeInterval:3600 * 24 * 31];
    }

    NSString *message = SUCESS_STRING;
    if([[Utility trim:[params valueForKey:@"institution"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"degree_name"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"fieldOfStudy"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"location"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"location"]] isEqualToString:@""] )
        message = @"Please enter all the fields.";
    else if([[params valueForKey:@"startDate"] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[params valueForKey:@"endDate"] length] <= 0)
        message = @"Please enter all the fields.";
    else if([start_date compare:end_date]  == NSOrderedDescending && ![[params valueForKey:@"endDate"] isEqualToString:@"Present"])
        message = @"End date cannot be before your Start date.";
    else if([start_date compare:end_date]  == NSOrderedSame)
        message = @"Start date and End date cannot be from the same month.";
    return message;
}

-(NSString *)validateAcadamicParams:(NSMutableDictionary *)params
{
    NSDate *start_date = [Utility getDateWithStringDate:[params valueForKey:@"startDate"] withFormat:@"MMM yyyy"];
    NSDate *end_date = [Utility getDateWithStringDate:[params valueForKey:@"endDate"] withFormat:@"MMM yyyy"];
    
    NSDate *custom_end_date = (NSDate *)[params valueForKey:@"endDateVal"];
    custom_end_date =  [Utility getDate:custom_end_date withFromat:@"MM-dd-yyyy"];
    
    if(end_date == nil || [[params valueForKey:@"isPresent"] boolValue]){
        end_date = [NSDate date];
        end_date = [end_date dateByAddingTimeInterval:3600 * 24 * 31];
    }
    
    NSString *message = SUCESS_STRING;
    if([[params valueForKey:@"role"] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"projectTitle"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"institution"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[Utility trim:[params valueForKey:@"location"]] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[params valueForKey:@"startDate"] length] <= 0)
        message = @"Please enter all the fields.";
    else if([[params valueForKey:@"endDate"] length] <= 0)
        message = @"Please enter all the fields.";
    else if(([start_date compare:end_date]  == NSOrderedDescending) && ![[params valueForKey:@"endDate"] isEqualToString:@"Present"])
        message = @"End date cannot be before your Start date.";
    else if([start_date compare:end_date]  == NSOrderedSame)
        message = @"Start date and End date cannot be from the same month.";
    return message;
}

+(NSString *)getJobRolesFromArray:(NSMutableArray *)jobFunction
{
    if (jobFunction.count == 1) {
        
        NSMutableString *string_job = [[NSMutableString alloc] initWithCapacity:0];
        for (NSMutableDictionary *dictionary in jobFunction) {
            if([[jobFunction lastObject] isEqual:dictionary]){
                [string_job appendString:[dictionary valueForKey:@"jobFunctionName"]];
            }else{
                [string_job appendFormat:@"%@, ",[dictionary valueForKey:@"jobFunctionName"]];
            }
        }
        return [NSString stringWithFormat:@"%@ role.",string_job];
        
        
    }
    else{
    NSMutableString *string_job = [[NSMutableString alloc] initWithCapacity:0];
    for (NSMutableDictionary *dictionary in jobFunction) {
        if([[jobFunction lastObject] isEqual:dictionary]){
            [string_job appendString:[dictionary valueForKey:@"jobFunctionName"]];
        }else{
            [string_job appendFormat:@"%@, ",[dictionary valueForKey:@"jobFunctionName"]];
        }
    }
        return [NSString stringWithFormat:@"%@ roles.",string_job];
    }
}




+(NSString *)getJobRolesFromArrayForEdit:(NSMutableArray *)jobFunction
{
    
        NSMutableString *string_job = [[NSMutableString alloc] initWithCapacity:0];
        for (NSMutableDictionary *dictionary in jobFunction) {
            if([[jobFunction lastObject] isEqual:dictionary]){
                [string_job appendString:[dictionary valueForKey:@"jobFunctionName"]];
            }else{
                [string_job appendFormat:@"%@, ",[dictionary valueForKey:@"jobFunctionName"]];
            }
        }
        return [NSString stringWithFormat:@"%@",string_job];
    
}
+(NSString *)getJobTypesFromArray:(NSMutableArray *)jobTypeTitle{
    
    
   
    NSMutableString *string_job = [[NSMutableString alloc] initWithCapacity:0];
    for (NSMutableDictionary *dictionary in jobTypeTitle) {
        NSLog(@"%@",jobTypeTitle);
        
        if([[jobTypeTitle lastObject] isEqual:dictionary]){
            [string_job appendString:[dictionary valueForKey:@"jobTypeTitle"]];
        }else{
            [string_job appendFormat:@"%@, ",[dictionary valueForKey:@"jobTypeTitle"]];
        }
    }
    return (NSString *)string_job;
    
    


}
-(NSMutableArray *)getJobTypesIdFromArray:(NSMutableArray *)jobTypeId{

  
    
    NSMutableArray *temp_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i = 0; i < [jobTypeId count]; i++){
        NSMutableDictionary *dictionary = [[jobTypeId objectAtIndex:i] mutableCopy];
      
        
        
        
        [temp_array addObject:[dictionary valueForKey:@"jobTypeId"]];
    }
    

    NSLog(@"my temp array%@",temp_array);
    return (NSMutableArray *)temp_array;
    




}
-(NSMutableArray *)getSelectedJobTypesIdFromArray:(NSMutableArray *)jobTypeId{

    NSMutableArray *temp_array = [[NSMutableArray alloc] initWithArray:jobTypeId];
    
    
    
    NSLog(@"my temp array%@",temp_array);
    return (NSMutableArray *)temp_array;
    

}

+(NSString *)getJobLocationFromArray:(NSMutableArray *)jobTypeTitle{
    
    
    NSMutableString *string_job = [[NSMutableString alloc] initWithCapacity:0];
    for (NSMutableDictionary *dictionary in jobTypeTitle) {
        if([[jobTypeTitle lastObject] isEqual:dictionary]){
            [string_job appendString:[dictionary valueForKey:@"title"]];
        }else{
            [string_job appendFormat:@"%@, ",[dictionary valueForKey:@"title"]];
        }
    }
    return (NSString *)string_job;


}
-(NSMutableArray *)getLocationTypesIdFromArray:(NSMutableArray *)jobTypeId{
    
    NSMutableArray *temp_array = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i = 0; i < [jobTypeId count]; i++){
        NSMutableDictionary *dictionary = [[jobTypeId objectAtIndex:i] mutableCopy];
        [temp_array addObject:[dictionary valueForKey:@"locationId"]];
    }
    
    
    NSLog(@"my temp array%@",temp_array);
    return (NSMutableArray *)temp_array;


}

-(NSMutableArray *)getSelectedLocationIdFromArray:(NSMutableArray *)jobTypeId{
    
    
    
    NSMutableArray *temp_array = [[NSMutableArray alloc] initWithArray:jobTypeId];
    
    
    
    NSLog(@"my temp array%@",temp_array);
    return (NSMutableArray *)temp_array;



}


-(void)updateTheDefaultUserSettingsParams
{
    NSMutableDictionary *userSettings = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableDictionary *newJobs   = [[NSMutableDictionary alloc] initWithCapacity:0];
    [newJobs setObject:[NSNumber numberWithInt:1] forKey:@"email"];
    [newJobs setObject:[NSNumber numberWithInt:1] forKey:@"mobile"];
    [userSettings setObject:newJobs forKey:@"newJobs"];
    
    NSMutableDictionary *newMatch   = [[NSMutableDictionary alloc] initWithCapacity:0];
    [newMatch setObject:[NSNumber numberWithInt:1] forKey:@"email"];
    [newMatch setObject:[NSNumber numberWithInt:1] forKey:@"mobile"];
    [userSettings setObject:newMatch forKey:@"newMatch"];

    NSMutableDictionary *someoneInterested   = [[NSMutableDictionary alloc] initWithCapacity:0];
    [someoneInterested setObject:[NSNumber numberWithInt:1] forKey:@"email"];
    [someoneInterested setObject:[NSNumber numberWithInt:1] forKey:@"mobile"];
    [userSettings setObject:someoneInterested forKey:@"someoneInterested"];
    
    [self.paramsDictionary setObject:userSettings forKey:@"userSettings"];
}

-(void)saveApplicantObject:(NSNotification *)notification
{
    [Utility saveApplicantObject:self];
}

-(void)updateApplicantPreferences:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params
{
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],@"/updatePreferences"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)getSkillsServiceWithDelegate:(id)delegate requestType:(int)requestType withJobFunction:(NSString *)jobFunction
{
    ConnectionManager *connection_manager = [[ConnectionManager alloc] init];
    connection_manager.delegate = delegate;
    //get top suggested sckills based on job function
    NSString *url  = [NSString stringWithFormat:@"%@/skills?page=0&size=100&skillName=&jobFunction=%@",API_BASE_URL,jobFunction];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [connection_manager startRequestWithURL:url WithParams:nil forRequest:requestType controller:delegate httpMethod:HTTP_GET];
}

-(void)updateLocationServer:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    if([[self.paramsDictionary valueForKeyPath:@"location"] length] > 0)
        [params setObject:[self.paramsDictionary valueForKeyPath:@"location"] forKey:@"location"];
    else
        [params setObject:@"" forKey:@"location"];
    
    if([[self.paramsDictionary valueForKeyPath:@"totalexperience"] length] > 0)
        [params setObject:[self.paramsDictionary valueForKeyPath:@"totalexperience"] forKey:@"totalExperience"];
    else
        [params setObject:@"" forKey:@"totalExperience"];
    
    NSMutableArray  *tempArray = nil;
    
    if([[self.paramsDictionary valueForKey:@"userPreferences"] isKindOfClass:[NSDictionary class]])
        tempArray =   [[self.paramsDictionary valueForKeyPath:@"userPreferences.jobTypes"] mutableCopy];
    else
        tempArray =   [[self.paramsDictionary valueForKeyPath:@"jobTypes"] mutableCopy];
    
    
    if (tempArray.count == 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
      tempArray = [userDefaults objectForKey:@"tableViewDataText"];
    }
    
         [params setObject:[self getJobTypesIdFromArray:tempArray ]forKey:@"jobTypeId"];
    
    [params setObject:[self.paramsDictionary valueForKey:@"status"] forKey:@"currentstatus"];
    
    /*
    if([self.paramsDictionary valueForKeyPath:@"jobTypeId"]  > 0)
        [params setObject:[NSArray arrayWithObjects:[self.paramsDictionary valueForKeyPath:@"jobTypeId"], nil] forKey:@"jobTypeId"];
    else
        [params setObject:@"" forKey:@"jobTypeId"]; */
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],@"/location"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)updateJobFunctionsServer:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray *arrayObjects = [self.paramsDictionary valueForKeyPath:@"jobfunctions"];
    NSMutableArray *objectArray = [[NSMutableArray alloc] initWithCapacity:0];
    for(NSMutableDictionary *dictionary in arrayObjects){
        [objectArray addObject:[dictionary valueForKeyPath:@"jobFunctionId"]];
    }
    [params setObject:objectArray forKey:@"jobfunctions"];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],@"/jobFunction"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)updateExperianceToServer:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *params = [self.paramsDictionary valueForKeyPath:@"experience"];
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],@"/updateExperience"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)updateEducationToServer:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *params = [self.paramsDictionary valueForKeyPath:@"education"];
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],@"/updateEducationDetails"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)updateAboutToServer:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    if([[self.paramsDictionary valueForKey:@"about"] length] > 0)
        [params setObject:[self.paramsDictionary valueForKey:@"about"] forKey:@"coverletter"];
    else
        [params setObject:@"" forKey:@"coverletter"];
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@%@",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID],@"/about"] WithParams:[CompanyHelper convertDictionaryToJSONString:params]  forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}
@end
