//
//  Utility.h
//  workruit
//
//  Created by Admin on 10/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFiles.h"

@interface Utility : NSObject
+(void)setIsCompany:(BOOL)value;
+(void)getMixpanelData:(NSString *)track setProperties:(NSString *)properties;
+(BOOL)isComapany;
+(UIView *)borderLineWithWidth:(float)wdith;
+(NSString *)getCurrentCityName:(NSString *)locationString;
+(NSArray *)getListOfCities;
+(CGSize)getCardHeight;
+(UIImage *)resizeImage:(UIImage*)selectedImage;
+(void)saveToDefaultsWithKey:(NSString *)key value:(NSString *)value;
+(NSString *)formateTheDateWithString:(NSString *)date;
+(NSString *)getStringWithDate:(NSDate *)date withFormat:(NSString *)format;
+(NSString *)getStringWithDate:(NSString *)dateStr withOldFormat:(NSString *)oldFormat newFormat:(NSString *)newFormat;
+(NSDate *)getDateWithStringDate:(NSString *)date withFormat:(NSString *)format;
+(NSDate *)getDateWithStringDate1:(NSString *)date withFormat:(NSString *)format;
+(float)getHeightForText:(NSString*) text withFont:(UIFont*) font andWidth:(float) width;
+(BOOL)isNullValueCheck:(NSString *)value;
+(void)saveCompanyObject:(CompanyHelper *)companyObject;
+(void)saveApplicantObject:(ApplicantHelper *)applicantObject;
+(NSMutableArray *)sortTheArray:(NSMutableArray *)array;
+(UIView *)getConversationTitleViewWithTitle:(NSString *)title subTitle:(NSString *)subTitle;
+(NSMutableDictionary *)getDictionaryFromString:(NSString *)string_dictionary;
+(NSString *)convertDictionaryToJSONString:(NSMutableDictionary *)dictionary;
+(NSDate *)getDate:(NSDate *)date1 withFromat:(NSString *)format;
+(NSString *)getChannelName:(NSMutableDictionary *)dictionary;
+(NSMutableDictionary *)removeNullRecursive:(NSMutableDictionary *)dictionary;
+(NSString *)removeNullFromObject:(NSString *)value;
+(BOOL)mobileNumberValidation:(NSString *)mobileNumber;
+(void)checkForPermission;
+(NSString *)getAppVersionNumber;
+(BOOL)notificationServicesEnabled;
+(float)converVersionToFloat:(NSString *)version;
+(NSString *)getJobFunctions:(NSArray *)jobFunctions;
+(NSString *)convertToGMTTimeZone:(NSDate *)date withFormat:(NSString *)format;
+(NSString*)getAgoTimeIntervalInString:(NSDate *) dateObject;
+ (NSString*)encodeStringTo64:(NSString*)fromString;
+(NSMutableDictionary *)getDefaultUpdateProfileNotificationObject:(NSString *)title;
+(NSMutableArray *)sortEducationArray:(NSMutableArray *)array;
+(NSString *)getFormatedURL:(NSString *)url;
+(void)setThescreensforiPhonex:(UIView *)myView;
+(NSString *)convertLocaltoGMTTimeConversion:(NSDate *)date withformat:(NSString *)localDateStr;
+(NSString *)getStringWithDate1:(NSString *)dateStr;
+(NSString *)getStringWithDate_Compamny:(NSString *)dateStr;
+(NSString *)getStringWithDate_Compamny_Conversation:(NSString *)dateStr;
+(NSString *)trim:(NSString *)string;
@end

