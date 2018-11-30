//
//  CompanyHelper.h
//  workruit
//
//  Created by Admin on 9/30/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFiles.h"

@interface CompanyHelper : NSObject

@property(nonatomic,readwrite) BOOL isPartialLogin;
@property(nonatomic, readwrite) BOOL isJobPosted;

@property(nonatomic,readwrite) BOOL loadJobCardsWithPrefreceSettings;

+(CompanyHelper *)sharedInstance;

-(void)setParamsValue:(NSString *)val forKey:(NSString *)key;

//-(void)setCreateJobsParamsValue:(NSString *)value Key:(NSString *)Key;

//Create Company
-(void)createAccountServiceCallWithDelegate:(id)delegate requestType:(int)requestType;

//Save Company
-(void)saveComapnyServiceCallWithDelegate:(id)delegate requestType:(int)requestType;

//Update Company
-(void)updateComapnyServiceCallWithDelegate:(id)delegate requestType:(int)requestType;

//Applicant profile Array
-(void)getApplicantProfilesWithDelegate:(id)delegate requestType:(int)requestType;

//updateRecruiterProfile
-(void)updateRecruiterProfilesWithDelegate:(id)delegate requestType:(int)requestType param:(NSMutableDictionary *)params;

//Get recruter Profile dictionary
-(void)getRecruterProfile:(id)delegate requestType:(int)requestType;

//Company change pasword
-(void)companyChangePassword:(id)delegate requestType:(int)requestType param:(NSMutableDictionary *)params;

//UpdateSwipe Action
-(void)updateSwipeActionToServer:(NSMutableDictionary *)params delegate:(id)delegate requestType:(int)requestType withURL:(NSString *)urlStr;

//Get profiles for job
-(void)getProfilesForJob:(id)delegate requestType:(int)requestType;

//Get recruterMatches
-(void)getRecruterMatches:(id)delegate requestType:(int)requestType;

//Login to company
-(void)loginComapny:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params;

//Forgot password
-(void)forgotPasswordComapny:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params;

//LogOut Company service
-(void)logOutCompany:(id)delegate requestType:(int)requestType;

-(void)getShortListedProfiles:(id)delegate requestType:(int)requestType;


-(NSMutableDictionary *)getParamsObject;

+(NSString *)convertDictionaryToJSONString:(NSMutableDictionary *)dictionary;

-(NSString *)validateRequestParams;

-(NSString *)validateCompanyProfileParams;

-(NSString *)validateEditCompanyProfileParams;


+(NSString *)getParamsStringWithIndex:(int)index screenId:(int)screenId;

+(NSMutableArray *)getDropDownArrayWithTittleKey:(NSString *)titleKey parantKey:(NSString *)parantKey;

+(NSMutableArray *)getAllCities;

+(NSString *)getJobRoleIdWithIndex:(int)index parantKey:(NSString *)parantKey childKey:(NSString *)childKey;

+(int)getJobRoleIdWithValue:(NSString *)value parantKey:(NSString *)parantKey childKey:(NSString *)childKey;

+(NSString *)getJobRoleNameWithId:(NSString *)id_value parantKey:(NSString *)parantKey childKey:(NSString *)childKey valueKey: (NSString *)valueKey;

-(void)updatePrefrences:(id)delegate requestType:(int)requestType params:(NSMutableDictionary *)params;

-(void)getCompanyProfile:(id)delegate requestType:(int)requestType;

-(void)getPostedJobsOtherThanClosingWithDelegate:(id)delegate requestType:(int)requestType;


+(NSMutableArray *)getArrayWithParentKey:(NSString *)parant_key;

-(NSString *)getEditCompanyValueWithindex:(int)index row:(int)row;

+(BOOL)checkEmailisWorkEmail:(NSString *)email;

+(BOOL)IsValidEmail:(NSString *)checkString;

+(NSMutableArray *)getYearsArray;

+(NSMutableArray *)getMonthsArray;

+(NSString *)convertDictionaryToJSONStringWithPassword:(NSMutableDictionary *)dictionary;

-(void)setPrefrancesParams:(id)val forKey:(NSString *)key;

//Create Comapany Params
@property(nonatomic,retain) NSMutableDictionary *params;
//Create Jobs Params
@property(nonatomic,strong) NSMutableDictionary *createJobParams;
//prefrences params
@property(nonatomic,strong) NSMutableDictionary *companyPrefrencesParams;

@property(nonatomic,strong) NSMutableArray *companyProfiles;

@property(nonatomic,strong) NSMutableDictionary *prefrences_object;

@property(nonatomic,retain) UIImage *profile_image;


@end
