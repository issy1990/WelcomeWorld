//
//  FireBaseAPICalls.m
//  workruit
//
//  Created by Admin on 3/4/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "FireBaseAPICalls.h"

@implementation FireBaseAPICalls


+(void)captureScreenDetails:(NSString *)title
{
    if([API_BASE_URL isEqualToString:@"https://apiv2.workruit.com/api"]){
        [FIRAnalytics logEventWithName:kFIREventSelectContent
                        parameters:@{
                                     kFIRParameterItemID:[NSString stringWithFormat:@"id-%@", title],
                                     kFIRParameterItemName:title,
                                     kFIRParameterContentType:title
                                     }];
        
    }
}

+(void)captureMixpannelEvent:(NSString *)title{
    if([API_BASE_URL isEqualToString:@"https://apiv2.workruit.com/api"]){
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                           valueForKey:FIRST_NAME_KEY];
        
        NSString *registrationId = [Utility isComapany]?[[NSUserDefaults standardUserDefaults] valueForKey:RECRUITER_REGISTRATION_ID]:[[NSUserDefaults standardUserDefaults] valueForKey:APPLICANT_REGISTRATION_ID];
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        [Utility getMixpanelData:title setProperties:userName];
    }
}


@end
