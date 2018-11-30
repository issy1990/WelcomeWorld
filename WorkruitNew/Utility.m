//
//  Utility.m
//  workruit
//
//  Created by Admin on 10/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Utility.h"

@implementation Utility
static BOOL isComapany;

+(NSString *)trim:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(void)setIsCompany:(BOOL)value
{
    isComapany = value;
}

+(BOOL)isComapany
{
    return isComapany;
}

+(void)setThescreensforiPhonex:(UIView *)myView
{
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIScreen.mainScreen.nativeBounds.size.height == 2436)
    {
        myView.translatesAutoresizingMaskIntoConstraints =YES;
        myView.frame = CGRectMake(0, 0, 375, 88);
    }
}

+(UIView *)borderLineWithWidth:(float)wdith
{
    UIView *borderLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wdith, 0.5)];
    [borderLine2 setBackgroundColor:DividerLineColor];
    return borderLine2;
    
}

+(NSString *)getCurrentCityName:(NSString *)locationString
{
    if (locationString==nil) {
        return nil;
    }
    NSData *data = [locationString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSDictionary *dic = [[json objectForKey:@"results"] objectAtIndex:0];
    NSArray* arr = [dic objectForKey:@"address_components"];
    //Iterate each result of address components - find locality and country
    NSString *cityName;
    NSString *countryName;
    for (NSDictionary* d in arr)
    {
        NSArray* typesArr = [d objectForKey:@"types"];
        if( typesArr.count>0){
            NSString* firstType = [typesArr objectAtIndex:0];
            
            if([firstType isEqualToString:@"locality"])
            cityName = [d objectForKey:@"long_name"];
            if([firstType isEqualToString:@"country"])
            countryName = [d objectForKey:@"long_name"];
        }
        
    }
    
    NSString* locationFinal = [NSString stringWithFormat:@"%@,%@",cityName,countryName];
    NSLog(@"locationFinal: %@",locationFinal);
    return  locationFinal;
}

+(NSArray *)getListOfCities
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSError *error =  nil;
    return [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
}
+(CGSize)getCardHeight
{
    int screenHeight =[UIScreen mainScreen].bounds.size.height;
    int cardHight = 0;
    int cardWidth = 0;
    switch ((int)screenHeight) {
            case 480:
            cardHight = 680/2;
            cardWidth = 600/2;
            break;
            case 568:
            cardHight = 820/2;
            cardWidth = 600/2;
            break;
            case 667:
            cardHight = 860/2;
            cardWidth = 700/2;
            break;
            case 736:
            cardHight = 900/2;
            cardWidth = 760/2;
            break;
            case 812:
            cardHight = 900/2;
            cardWidth = 700/2;
            break;
    }
    return CGSizeMake(cardWidth, cardHight);
}

+(UIImage *)resizeImage:(UIImage*)selectedImage
{
    NSData *imgData = UIImageJPEGRepresentation(selectedImage, 1); //1 it represents the quality of the image.
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imgData length]);
    
    
    float actualHeight = selectedImage.size.height;
    float actualWidth = selectedImage.size.width;
    float maxHeight = 800.0; //new max. height for image
    float maxWidth = 600.0; //new max. width for image
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.2; //50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    NSLog(@"Actual height : %f and Width : %f",actualHeight,actualWidth);
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [selectedImage drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    imgData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1); //1 it represents the quality of the image.
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imgData length]);
    
    return [UIImage imageWithData:imageData];
}

+(void)saveToDefaultsWithKey:(NSString *)key value:(NSString *)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

+(void)saveCompanyObject:(CompanyHelper *)companyObject
{
    if (!companyObject.params)
    return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[Utility removeNullRecursive:[companyObject.params mutableCopy]] forKey:COMPANY_OBJECT_PARAMS];
    [defaults synchronize];
}

+(void)saveApplicantObject:(ApplicantHelper *)applicantObject
{
    if (!applicantObject.paramsDictionary)
    return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[applicantObject.paramsDictionary mutableCopy] forKey:APPLICANT_OBJECT_PARAMS];
    [defaults synchronize];
}

+(NSString *)formateTheDateWithString:(NSString *)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM yyyy dd HH:mm a";
    NSDate *yourDate = [dateFormatter dateFromString:date];
    dateFormatter.dateFormat = @"MMM dd";
    
    return [dateFormatter stringFromDate:yourDate];
}

+(NSString *)getStringWithDate:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}
+(NSString *)convertLocaltoGMTTimeConversion:(NSDate *)date withformat:(NSString *)localDateStr
{
    NSString *str=@"2012-01-15 06:27:42";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFromString = [dateFormatter dateFromString:str];
    NSDate* sourceDate = dateFromString;
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    
    return localDateStr;
}


+(NSString *)convertToGMTTimeZone:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GSK"]];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}


+(NSDate *)getDateWithStringDate:(NSString *)date withFormat:(NSString *)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.dateFormat = format;
    return [dateFormatter dateFromString:date];
}

//+5:30
+(NSDate *)getDateWithStringDate1:(NSString *)date withFormat:(NSString *)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = format;
    NSDate *utcDate = [dateFormatter dateFromString:date];
    
    NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:format];
    NSString * str = [dateFormatter1 stringFromDate:utcDate];
    NSLog(@"%@",str);

    
    return [dateFormatter dateFromString:date]; 
}

+(NSString *)getStringWithDate:(NSString *)dateStr withOldFormat:(NSString *)oldFormat newFormat:(NSString *)newFormat
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = oldFormat;
    NSDate *date = [dateFormatter dateFromString:dateStr];
    dateFormatter.dateFormat = newFormat;
    
    return [dateFormatter stringFromDate:date];
}

+(NSString *)getStringWithDate1:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.dateFormat = @"MMM yyyy dd hh:mm:ss.000 a";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter1 setTimeZone:gmt];
    NSDate *timeStamp1 = [dateFormatter1 dateFromString:dateStr];
    
    int daysToAdd = 0;
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    [components setMinute:daysToAdd];
    NSDate *futureDate = [gregorian dateByAddingComponents:components toDate:timeStamp1 options:0];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy hh:mm:ss"];
    NSString * str = [dateFormatter stringFromDate:futureDate];
    
    return str;
}
+(NSString *)getStringWithDate_Compamny:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.dateFormat = @"MMM yyyy dd hh:mm a";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter1 setTimeZone:gmt];
    NSDate *timeStamp1 = [dateFormatter1 dateFromString:dateStr];
    
    int daysToAdd = 0;
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    [components setMinute:daysToAdd];
    NSDate *futureDate = [gregorian dateByAddingComponents:components toDate:timeStamp1 options:0];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy hh:mm"];
    NSString * str = [dateFormatter stringFromDate:futureDate];
    
    return str;
}



+(NSDate *)getDate:(NSDate *)date1 withFromat:(NSString *)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter dateFromString:[dateFormatter stringFromDate:date1]];
}

+(float)getHeightForText:(NSString*) text withFont:(UIFont*) font andWidth:(float) width{
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:text attributes:@{
                                                                                                     NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width-60, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize finalSize = rect.size;
    
    //    NSLog(@"%f   %f  ---------- %f  %f",expectedLabelSize.width,expectedLabelSize.height,finalSize.width,finalSize.height);
    if(finalSize.height + 30 < CELL_HEIGHT)
    return CELL_HEIGHT;
    else
    return finalSize.height + 30;
}



+(BOOL)isNullValueCheck:(NSString *)value
{
    if (value && [value class] != [NSNull class])
    return NO;
    else
    return YES;
}


+(void)getMixpanelData:(NSString *)track setProperties:(NSString *)properties{
    
    //[Mixpanel sharedInstanceWithToken:@"da01d311ede2a43d08946ef5725c5410"]; //Dev
    [Mixpanel sharedInstanceWithToken:MIX_PANEL]; //Prod
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:track
         properties:@{ track:@"Sucess" , @"User":properties   }];
}


+(NSMutableArray *)sortTheArray:(NSMutableArray *)array
{
    NSArray *myArr=[NSArray arrayWithArray:array];
    
    
    NSLog(@"%@",myArr);
    for(NSMutableDictionary *dictionary in myArr){
        [dictionary setObject:[Utility getDateWithStringDate:[dictionary valueForKey:@"startDate"] withFormat:@"MMM yyyy"] forKey:@"startDateVal"];
        if([[dictionary valueForKey:@"endDate"] isEqualToString:@"Present"])
        [dictionary setObject:[NSDate date] forKey:@"endDateVal"];
        else
        [dictionary setObject:[Utility getDateWithStringDate:[dictionary valueForKey:@"endDate"] withFormat:@"MMM yyyy"] forKey:@"endDateVal"];
    }
    
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc]initWithKey:@"endDateVal" ascending:NO];
    NSSortDescriptor *descriptor1=[[NSSortDescriptor alloc]initWithKey:@"startDateVal" ascending:NO];
    
    myArr = [myArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, descriptor1, nil]];
    
    for(NSMutableDictionary *dictionary in myArr){
        [dictionary removeObjectForKey:@"startDateVal"];
        [dictionary removeObjectForKey:@"endDateVal"];
    }
    return  [myArr mutableCopy];
}

+(NSMutableArray *)sortEducationArray:(NSMutableArray *)array
{
    NSArray *myArr=[NSArray arrayWithArray:array];
    
    for(NSMutableDictionary *dictionary in myArr){
        NSMutableDictionary *degree_object = [dictionary valueForKey:@"degree"];
        
        [degree_object setObject:[myArr valueForKey:@"degree_name"] forKey:@"title"];
        [degree_object setObject:[myArr valueForKey:@"degree_short_name"] forKey:@"shortTitle"];
        
    }
    for(NSMutableDictionary *dictionary in myArr){
        [dictionary setObject:[Utility getDateWithStringDate:[dictionary valueForKey:@"startDate"] withFormat:@"MMM yyyy"] forKey:@"startDateVal"];
        if([[dictionary valueForKey:@"endDate"] isEqualToString:@"Present"])
        [dictionary setObject:[NSDate date] forKey:@"endDateVal"];
        else
        [dictionary setObject:[Utility getDateWithStringDate:[dictionary valueForKey:@"endDate"] withFormat:@"MMM yyyy"] forKey:@"endDateVal"];
    }
    
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc]initWithKey:@"endDateVal" ascending:NO];
    NSSortDescriptor *descriptor1=[[NSSortDescriptor alloc]initWithKey:@"startDateVal" ascending:NO];
    
    myArr = [myArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, descriptor1, nil]];
    
    for(NSMutableDictionary *dictionary in myArr){
        [dictionary removeObjectForKey:@"startDateVal"];
        [dictionary removeObjectForKey:@"endDateVal"];
    }
    return  [myArr mutableCopy];
    
    
    
}
+(UIView *)getConversationTitleViewWithTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UILabel *title_lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    title_lbl.font = [UIFont fontWithName:GlobalFontSemibold size:17.0f];
    title_lbl.textAlignment = NSTextAlignmentCenter;
    title_lbl.text = title;
    title_lbl.tag = 11;
    title_lbl.textColor = [UIColor whiteColor];
    [view addSubview:title_lbl];
    
    UILabel *sub_title_lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 200, 20)];
    sub_title_lbl.font = [UIFont fontWithName:GlobalFontRegular size:14.0f];
    sub_title_lbl.textAlignment = NSTextAlignmentCenter;
    sub_title_lbl.text = subTitle;
    sub_title_lbl.tag = 10;
    sub_title_lbl.textColor = [UIColor whiteColor];
    [view addSubview:sub_title_lbl];
    
    return view;
}

+(NSMutableDictionary *)getDictionaryFromString:(NSString *)string_dictionary
{
    if(string_dictionary == nil)
    return nil;
    
    NSData *data = [string_dictionary dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    return dictionary;
}

+(NSString *)convertDictionaryToJSONString:(NSMutableDictionary *)dictionary
{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    return  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+(NSString *)getChannelName:(NSMutableDictionary *)dictionary
{
    NSString *channel_name;
    if([Utility isComapany]){
        //Channel name 83174
        channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[dictionary  valueForKeyPath:@"jobPostId.jobPostId"],[dictionary valueForKeyPath:@"userId.userId"]];
    }else{
        //Channel name
        channel_name  = [NSString stringWithFormat:@"workruit_v1%@%@",[dictionary valueForKeyPath:@"jobPostId"],[[NSUserDefaults standardUserDefaults] valueForKeyPath:APPLICANT_REGISTRATION_ID]];
    }
    return channel_name;
}

+ (NSMutableDictionary *)removeNullRecursive:(NSMutableDictionary *)dictionary {
    for (NSString *key in [dictionary allKeys]) {
        id nullString = [dictionary objectForKey:key];
        if ([nullString isKindOfClass:[NSDictionary class]]) {
            [Utility removeNullRecursive:(NSMutableDictionary*)nullString];
        } else {
            if ((NSString*)nullString == (id)[NSNull null])
            [dictionary setValue:@"" forKey:key];
        }
    }
    return dictionary;
}

+(NSString *)removeNullFromObject:(NSString *)value
{
    value = [NSString stringWithFormat:@"%@",value];
    if(value == nil || [value isKindOfClass:[NSNull class]] || [value isEqualToString:@"(null)"])
    return @"";
    else return value;
}

+(BOOL)mobileNumberValidation:(NSString *)mobileNumber
{
    if(mobileNumber == nil)
    return YES;
    
    NSString *expression = @"^(?:(?:\\+|0{0,2})91(\\s*[\\-]\\s*)?|[0]?)?[789]\\d{9}$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:mobileNumber
                                                        options:0
                                                          range:NSMakeRange(0, [mobileNumber length])];
    if (numberOfMatches == 0)
    return NO;
    else
    return YES;
}

/**
 * Method For get App store version
 */
+(NSString*)getAppStoreVersion{
    NSString *appstoreVersion ;
    NSString *appstoreUrl;
    if ([appstoreUrl isEqualToString:@""] || [appstoreVersion isEqualToString:@""]) {
        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appID = infoDictionary[@"CFBundleIdentifier"];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
        NSData* data = [NSData dataWithContentsOfURL:url];
        
        NSDictionary* lookup;
        if (data) {
            lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        
        if ([lookup[@"resultCount"] integerValue] == 1){
            
            appstoreVersion = lookup[@"results"][0][@"version"]; // version
            appstoreUrl = lookup[@"results"][0][@"artistViewUrl"]; // iTunesStore link
        }
    }
    
    return appstoreUrl;
}

+(void)checkForPermission
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        NSLog(@"%@", @"You have camera access");
    }
    else if(authStatus == AVAuthorizationStatusDenied)
    {
        NSLog(@"%@", @"Denied camera access");
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
            } else {
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
            }
        }];
    }
    else if(authStatus == AVAuthorizationStatusRestricted)
    {
        NSLog(@"%@", @"Restricted, normally won't happen");
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
            } else {
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
            }
        }];
    }
    else
    {
        NSLog(@"%@", @"Camera access unknown error.");
    }
}

+(NSString *)getAppVersionNumber
{
    NSString * version = nil;
    version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (!version) {
        version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    return version;
}

+(BOOL)notificationServicesEnabled {
    BOOL isEnabled = NO;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            isEnabled = NO;
        } else {
            isEnabled = YES;
        }
    }
    return isEnabled;
}

+(float)converVersionToFloat:(NSString *)version
{
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:0];
    NSArray *array = [version componentsSeparatedByString:@"."];
    for(int i = 0; i < [array count]; i++){
        if(i == 0)
        [string appendString:[NSString stringWithFormat:@"%@.",[array objectAtIndex:i]]];
        else
        [string appendString:[array objectAtIndex:i]];
    }
    return  [[NSString stringWithString:string] floatValue];
}

+(NSString *)getJobFunctions:(NSArray *)jobFunctions{
    NSMutableString *stringObjects  = [[NSMutableString alloc] initWithCapacity:0];
    for (NSDictionary *dictionary in jobFunctions) {
        if(dictionary == [jobFunctions lastObject]){
            [stringObjects appendString:[NSString stringWithFormat:@"%@", [dictionary valueForKey:@"jobFunctionName"]]];
        }else
        [stringObjects appendString:[NSString stringWithFormat:@"%@, ", [dictionary valueForKey:@"jobFunctionName"]]];
    }
    return [NSString stringWithString:stringObjects];
}


+(NSString*)getAgoTimeIntervalInString:(NSDate *) dateObject
{
    NSString *timeLeft;
    NSDate *today10am =[NSDate date];
    
    NSInteger seconds = [today10am timeIntervalSinceDate:dateObject];
    
    NSInteger years = (int) (floor(seconds / (3600 * 24 * 30 * 12)));
    if(years) seconds -= years * 3600 * 24 * 30 *12;
    
    NSInteger months = (int) (floor(seconds / (3600 * 24 * 30)));
    if(months) seconds -= months * 3600 * 24 * 30;
    
    NSInteger days = (int) (floor(seconds / (3600 * 24)));
    if(days) seconds -= days * 3600 * 24;
    
    NSInteger hours = (int) (floor(seconds / 3600));
    if(hours) seconds -= hours * 3600;
    
    NSInteger minutes = (int) (floor(seconds / 60));
    if(minutes) seconds -= minutes * 60;
    
    if(days > 0 || months > 0 || years > 0) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [gregorianCalendar rangeOfUnit:NSCalendarUnitDay startDate:&today10am
                              interval:NULL forDate:today10am];
        [gregorianCalendar  rangeOfUnit:NSCalendarUnitDay startDate:&dateObject
                               interval:NULL forDate:dateObject];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                            fromDate:today10am toDate:dateObject options:0];
        
        if([components day] < 0){
            if([components day] == -1)
            timeLeft = [NSString stringWithFormat:@"%ld day ago", (long)([components day]*-1)];
            else
            timeLeft = [NSString stringWithFormat:@"%ld days ago", (long)([components day]*-1)];
        }else{
            if([components day] == 1)
            timeLeft = [NSString stringWithFormat:@"%ld day ago", (long)([components day]*-1)*-1];
            else
            timeLeft = [NSString stringWithFormat:@"%ld days ago", (long)([components day]*-1)*-1];
        }
    }else{
        timeLeft = @"Today";
    }
    return timeLeft;
}
+ (NSString*)encodeStringTo64:(NSString*)fromString
{
    NSData *plainData = [fromString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:kNilOptions];
    return base64String;
}

+(NSMutableDictionary *)getDefaultUpdateProfileNotificationObject:(NSString *)title
{
    
    NSString *event_name = @"";
    /*if([title isEqualToString:@"Experience Missing!"])
     event_name = @"Applicant_Add_Experience";
     else if([title isEqualToString:@"Education Missing!"])
     event_name = @"Applicant_Add_Education";
     else*/
    event_name = @"Applicant_Update_Profile";
    
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] initWithCapacity:0];
    [aps setObject:event_name forKey:@"category"];
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    [notificationDictionary setObject:aps forKey:@"aps"];
    return notificationDictionary;
}

+(NSString *)getFormatedURL:(NSString *)url
{
    NSLog(@"%@",url);
    
    NSURL *url1 = [NSURL URLWithString:[url hasPrefix:@"/"]?[NSString stringWithFormat:@"%@%@",IMAGE_BASE_URL,url]:[NSString stringWithFormat:@"%@/%@",IMAGE_BASE_URL,url]];
    NSString *path = [url1 path];
    NSString *extension = [path pathExtension];
    
    if ([url isEqualToString:@"/company/176/1310848594590183"])
    {
        return [url hasPrefix:@"/"]?[NSString stringWithFormat:@"%@%@%@",IMAGE_BASE_URL,url,@".png"]:[NSString stringWithFormat:@"%@/%@%@",IMAGE_BASE_URL,url,@".png"];
    }
    else{
        return [url hasPrefix:@"/"]?[NSString stringWithFormat:@"%@%@",IMAGE_BASE_URL,url]:[NSString stringWithFormat:@"%@/%@",IMAGE_BASE_URL,url];
    }
}


//+(NSString *)getFormatedURL:(NSString *)url
//{
//    return [url hasPrefix:@"/"]?[NSString stringWithFormat:@"%@%@",IMAGE_BASE_URL,url]:[NSString stringWithFormat:@"%@/%@",IMAGE_BASE_URL,url];
//}
@end

