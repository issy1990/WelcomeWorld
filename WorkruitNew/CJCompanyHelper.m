//
//  CJCompanyHelper.m
//  workruit
//
//  Created by Admin on 10/23/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CJCompanyHelper.h"

@implementation CJCompanyHelper

-(void)setCreateJobsParamsValue:(NSString *)value Key:(NSString *)Key
{
    if(self.createJobParams == nil){
        self.createJobParams = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self.createJobParams setObject:@"ios" forKey:DEVICE_TYPE_KEY];
    }
    [self.createJobParams setObject:value forKey:Key];
}

-(NSString *)validateCreateJobParams:(BOOL)flag
{
    NSDate *start_date = [Utility getDateWithStringDate:[self.createJobParams valueForKey:@"startDate"] withFormat:@"MMM yyyy"];
    NSDate *end_date = [Utility getDateWithStringDate:[self.createJobParams valueForKey:@"endDate"] withFormat:@"MMM yyyy"];

    NSString *discriptions = [[self.createJobParams valueForKey:@"description"] stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceCharacterSet]];
    
    discriptions = [[self.createJobParams valueForKey:@"description"] stringByTrimmingCharactersInSet:
                    [NSCharacterSet newlineCharacterSet]];
    
    
    NSString *message = SUCESS_STRING;
    if([[Utility trim:[self.createJobParams valueForKey:@"title"]] length] <= 0)
        message = @"Please enter title";
    else if(![self.createJobParams valueForKey:@"jobFunction"])
        message = @"Please select job function";
    else if(![self.createJobParams valueForKey:@"location"])
        message = @"Please select job location";
    else if(![self.createJobParams valueForKey:@"jobType"])
        message = @"Please select job type";
    else if([[Utility trim:discriptions] length] <= 0)
        message = @"Please enter job description";
    else if([[self.createJobParams valueForKey:@"skills"] count] <= 2)
        message = @"Please select minimum three skills";
    else if([[self.createJobParams valueForKey:@"startDate"] length] <= 0 && flag)
        message = @"Please enter all the fields.";
    else if([[self.createJobParams valueForKey:@"endDate"] length] <= 0 && flag)
        message = @"Please enter all the fields.";
    else if([start_date compare:end_date]  == NSOrderedDescending && flag)
        message = @"End date cannot be before your Start date.";
    else if([start_date compare:end_date]  == NSOrderedSame && flag)
        message = @"Start date and End date cannot be from the same month.";
    return message;
}

-(void)createJobServiceCallWithDelegate:(id)delegate requestType:(int)requestType
{
    NSMutableDictionary *local_dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"title"] forKey:@"title"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"experienceMin"] forKey:@"experienceMin"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"experienceMax"] forKey:@"experienceMax"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"salaryMin"] forKey:@"salaryMin"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"salaryMax"] forKey:@"salaryMax"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"description"] forKey:@"description"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"location"] forKey:@"location"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"jobType"] forKey:@"jobType"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"jobFunction"] forKey:@"jobFunction"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"skills"] forKey:@"skills"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"hideSalary"] forKey:@"hideSalary"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"status"] forKey:@"status"];
    
    [local_dictionary setObject:[self.createJobParams valueForKey:@"endDate"] forKey:@"endDate"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"startDate"] forKey:@"startDate"];
    [local_dictionary setObject:[self.createJobParams valueForKey:@"unpaid"] forKey:@"unpaid"];
    
    
    if([[self.createJobParams valueForKey:@"jobPostId"] intValue] > 0)
            [local_dictionary setObject:[self.createJobParams valueForKey:@"jobPostId"] forKey:@"jobPostId"];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/user/%@/postjob",API_BASE_URL,[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]] WithParams:[CompanyHelper convertDictionaryToJSONString:local_dictionary] forRequest:requestType controller:delegate httpMethod:HTTP_POST];
}

-(void)closeJobServiceCallWithDelegate:(id)delegate requestType:(int)requestType jobId:(NSString *)jobId
{
    //https://devapi.workruit.com/api/job/98/jobStatus
    NSMutableDictionary *local_dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    [local_dictionary setObject:[NSNumber numberWithInt:3] forKey:@"status"];
    
    ConnectionManager *manager = [[ConnectionManager alloc] init];
    manager.delegate = delegate;
    [manager startRequestWithURL:[NSString stringWithFormat:@"%@/job/%@/jobStatus",API_BASE_URL,jobId] WithParams:[CompanyHelper convertDictionaryToJSONString:local_dictionary] forRequest:requestType controller:delegate httpMethod:HTTP_POST];

}


+(NSString *)getJobRoleIdWithidx:(int)idx parantKey:(NSString *)parantKey childKey:(NSString *)childKey withValueKey:(NSString *)valueKey
{
    NSMutableArray *jobRolesArray = [[[NSUserDefaults standardUserDefaults] valueForKey:@"MasterData"] valueForKey:parantKey];
    for(NSMutableArray *dic in jobRolesArray){
        if([[dic valueForKey:childKey] intValue] == idx){
            return [dic valueForKey:valueKey];
            break;
        }
    }
    return @"";
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


@end
