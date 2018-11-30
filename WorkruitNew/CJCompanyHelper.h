//
//  CJCompanyHelper.h
//  workruit
//
//  Created by Admin on 10/23/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFiles.h"

@interface CJCompanyHelper : NSObject
//Create Jobs Params
@property(nonatomic,strong) NSMutableDictionary *createJobParams;

-(void)setCreateJobsParamsValue:(NSString *)value Key:(NSString *)Key;

-(NSString *)validateCreateJobParams:(BOOL)flag;

-(void)createJobServiceCallWithDelegate:(id)delegate requestType:(int)requestType;

+(NSString *)getJobRoleIdWithidx:(int)idx parantKey:(NSString *)parantKey childKey:(NSString *)childKey withValueKey:(NSString *)valueKey;


-(void)getSkillsServiceWithDelegate:(id)delegate requestType:(int)requestType withJobFunction:(NSString *)jobFunction;

-(void)closeJobServiceCallWithDelegate:(id)delegate requestType:(int)requestType jobId:(NSString *)jobId;
@end
