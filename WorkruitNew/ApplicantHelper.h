//
//  ApplicantHelper.h
//  workruit
//
//  Created by Admin on 10/14/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFiles.h"

@interface ApplicantHelper : NSObject
@property(nonatomic,strong) NSMutableDictionary *paramsDictionary;

@property(nonatomic,strong) UIImage *profile_image;
@property(nonatomic,readwrite) BOOL isPartialLogin;
@property(nonatomic,readwrite) float profilePercentage;
@property(nonatomic,readwrite) BOOL halfProfile;

+(ApplicantHelper *)sharedInstance;

-(void)setParamsValue:(NSString *)val forKey:(NSString *)key;

-(NSString *)validateRequestParams;

-(void)createAccountServiceCallWithDelegate:(id)delegate requestType:(int)requestType;

-(void)updateApplicantServiceCallWithDelegate:(id)delegate requestType:(int)requestType;

-(void)updateApplicantSkillsServiceCallWithDelegate:(id)delegate requestType:(int)requestType;

-(void)otpServiceCallWithDelegete:(id)delegate requestType:(int)requestType withParams:(NSMutableDictionary *)params withServiceName:(NSString *)service_name;

-(void)otpVerifiedServiceCallWithDelegete:(id)delegate requestType:(int)requestType withParams:(NSMutableDictionary *)params;

-(NSString *)getParamsKeyWithIndex:(int)index withScreen:(int)screen;

-(NSString *)validateExperianceParams:(NSMutableDictionary *)params;

-(NSString *)validateEducationParams:(NSMutableDictionary *)params;

-(NSString *)validateAcadamicParams:(NSMutableDictionary *)params;

+(NSString *)getJobRolesFromArray:(NSMutableArray *)jobFunction;
+(NSString *)getJobTypesFromArray:(NSMutableArray *)jobTypeTitle;
-(NSMutableArray *)getJobTypesIdFromArray:(NSMutableArray *)jobTypeId;
+(NSString *)getJobRolesFromArrayForEdit:(NSMutableArray *)jobFunction;
-(NSMutableArray *)getSelectedJobTypesIdFromArray:(NSMutableArray *)jobTypeId;


+(NSString *)getJobLocationFromArray:(NSMutableArray *)jobTypeTitle;


-(NSMutableArray *)getLocationTypesIdFromArray:(NSMutableArray *)jobTypeId;

-(NSMutableArray *)getSelectedLocationIdFromArray:(NSMutableArray *)jobTypeId;
-(void)applicantChangePassword:(id)delegate requestType:(int)requestType param:(NSMutableDictionary *)params;

-(void)getApplicantProfile:(id)delegate requestType:(int)requestType;

-(void)logOutApplicant:(id)delegate requestType:(int)requestType;

-(void)getUserJobsForApplicant:(id)delegate requestType:(int)requestType;

-(void)updateSwipeActionToServer:(NSMutableDictionary *)params delegate:(id)delegate requestType:(int)requestType withURL:(NSString *)urlStr;

-(void)getApplicantJobMatches:(id)delegate requestType:(int)requestType;

-(void)viewAppliedJobs:(id)delegate requestType:(int)requestType;
-(void)viewAppliedJobs_External:(id)delegate requestType:(int)requestType;

-(void)loginApplicant:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params;
-(void)updateSwipeActionToServer_ExternalJobs:(NSMutableDictionary *)params delegate:(id)delegate requestType:(int)requestType withURL:(NSString *)urlStr;

-(void)getUserTotalExperiance:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params;

-(void)updateTheDefaultUserSettingsParams;

-(void)updateApplicantPreferences:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params;

-(void)getSkillsServiceWithDelegate:(id)delegate requestType:(int)requestType withJobFunction:(NSString *)jobFunction;

-(void)updateLocationServer:(id)delegate requestType:(int)requestType;

-(void)updateJobFunctionsServer:(id)delegate requestType:(int)requestType;

-(void)updateExperianceToServer:(id)delegate requestType:(int)requestType;

-(void)updateEducationToServer:(id)delegate requestType:(int)requestType;

-(void)updateAboutToServer:(id)delegate requestType:(int)requestType;

- (id)init;

@end
