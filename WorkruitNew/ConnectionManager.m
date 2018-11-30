//
//  ConnectionManager.m
//  DAS mobile
//
//  Created by eMbience
//  Copyright (c) Digital Air Strike 2013. All rights reserved.
//

#import "ConnectionManager.h"
#import "AppDelegate.h"
#import "AFNetworking.h"

@implementation ConnectionManager
- (id)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    }
    return self;
}

-(void)startRequestWithURL:(NSString *)verifyURL WithParams:(NSString *)verifyReqStr  forRequest:(int)reqType controller:(UIViewController *)controller httpMethod:(NSString *)method{
    
    NSLog(@"url :- %@",verifyURL);
    NSLog(@"params :- %@",verifyReqStr);
    
    AppDelegate *app_delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if(!app_delegate.isNetAvailable && reqType != -2){
        //  [CustomAlertView showAlertWithTitle:NETWORK_ERROR_TITLE message:NETWORK_ERROR_MESSAGE OkButton:@"Try Again" delegate:controller];
        return;
    }
    
    verifyURL = [verifyURL stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    self.requestType = reqType;
    
    if(reqType > 0)
    {
    if (reqType == 103||reqType == -103)
    {
        NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:USERJOBSFORAPPLICANTARRAY];
        NSMutableArray *arrayList = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
        
        if ([arrayList count] != 0)
        {
        }
        else
        {
            if ([[controller class] isKindOfClass:[UIViewController class]])
                [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
        }
    }
    else{
        if (reqType ==500)
        {
        }
        if (reqType ==300||reqType ==400)
        {
            if ([[controller class] isKindOfClass:[UIViewController class]])
                [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
        }
        else
        {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"loadIndi"])
            {
                NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:PROFILEFORJOBARRAY];
                NSArray *profileForJobArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];

                if ([profileForJobArray count] != 0)
                {
                    
                }
                else
                {
                    NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:INTRESTEDLISTARRAY];
                    NSMutableArray *arrayObjectsSaved = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
                    
                    if ([arrayObjectsSaved count] != 0)
                    {
                        if (reqType ==100) {
                            if ([[controller class] isKindOfClass:[UIViewController class]])
                                [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
                        }
                    }
                    else
                    {
                        if ([[controller class] isKindOfClass:[UIViewController class]])
                            [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
                    }
                }
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"loadIndi"];
            }
            else{
                if (reqType ==106||[[NSUserDefaults standardUserDefaults]boolForKey:@"loadIndi1"]){
                }
                else{
                    if (reqType == -110) {
                    }
                    else{
                        if ([[NSUserDefaults standardUserDefaults]valueForKey:@"getApplicantJobMatches"])
                        {
                            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"getApplicantJobMatches"];
                            
                            NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:USERJOBSFORAPPLICANTARRAY];
                            NSMutableArray *arrayList = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
                            
                            if ([arrayList count] != 0)
                            {
                                
                            } else {
                                if ([[controller class] isKindOfClass:[UIViewController class]])
                                    [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
                            }
                        } else {
                            if ([controller  isKindOfClass:[UIViewController class]])
                                [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
                        }
                    }
                }
            }
        }
    }
  }
    else
    {
        if(reqType == -350)
        {
            if ([Utility isComapany]) {
                NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:INTRESTEDLISTARRAY];
                NSMutableArray *arrayObjectsSaved = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
                
                 if ([arrayObjectsSaved count]==0)
                {
                    if ([[controller class] isKindOfClass:[UIViewController class]])
                        [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
                }
            }
            else{
                NSData *dataArray = [[NSUserDefaults standardUserDefaults] objectForKey:INTRESTEDLISTARRAY];
                NSMutableArray *arrayObjectsSaved = [NSKeyedUnarchiver unarchiveObjectWithData:dataArray];
                
                if ([arrayObjectsSaved count]== 0)
                {
                    if ([[controller class] isKindOfClass:[UIViewController class]])
                        [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
                }
            }
        }
//        else if (reqType == -105)
//        {
//            if ([Utility isComapany]) {
//              if ([[controller class] isKindOfClass:[UIViewController class]])
//                [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
//            }
//        }
    }
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }];
    
    NSMutableURLRequest*request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:verifyURL]];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSString *authorization = [NSString stringWithFormat:@"%@:%@",USERNAME,PASSWORD];
    authorization = [Utility encodeStringTo64:authorization] ;
    [request setValue:[NSString stringWithFormat:@"Basic %@",authorization] forHTTPHeaderField:@"Authorization"];
    
    [[SDWebImageDownloader sharedDownloader] setValue:[NSString stringWithFormat:@"Basic %@",authorization] forHTTPHeaderField:@"Authorization"];
    
    if(reqType==-121212 || reqType == 121212 || reqType == 121213){
        [request setValue:@"94b51cc4-0c99-11e7-93ae-92361f002671" forHTTPHeaderField:@"Token"];
    }else{
        NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
        
        if([session_id length] > 10){
            [request setValue:session_id forHTTPHeaderField:@"Token"];
            [[SDWebImageDownloader sharedDownloader] setValue:session_id forHTTPHeaderField:@"Token"];
        }
        else{
            NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                                    stringForKey:@"sessionName"];
            [request setValue:savedValue forHTTPHeaderField:@"Token"];
            [[SDWebImageDownloader sharedDownloader] setValue:savedValue forHTTPHeaderField:@"Token"];
        }
    }
    
    if (verifyReqStr) {
        [request setHTTPBody:[verifyReqStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    request.timeoutInterval = 30;
    [request setHTTPMethod:method];
    
    NSLog(@"fired API : %@",request.URL);
    
    
    self.dataTask = [defaultSession dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSString *someString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                                              if(reqType != -6000){
                                                  
                                                  NSString *session_id = [[NSUserDefaults standardUserDefaults] valueForKey:SESSION_ID];
                                                  
                                                  NSString *session_id1 = [[NSUserDefaults standardUserDefaults]stringForKey:@"sessionName"];
                                                  
                                                  if((reqType==-121212 || reqType == 121212 || reqType == 121213))
                                                      someString = [AESCrypt decrypt:someString password:@"password"];
                                                  else{
                                                      if([session_id length] > 10){
                                                          someString = [AESCrypt decrypt:someString password:session_id];
                                                      }
                                                      else{
                                                          someString = [AESCrypt decrypt:someString password:session_id1];
                                                      }
                                                  }
                                              }
                                              
                                              //To hide the loader
                                              if(reqType > 0)
                                                  if ([controller isKindOfClass:[UIViewController class]]) {
                                                      [MBProgressHUD hideHUDForView:controller.view animated:NO];
                                                  }

                                              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                              
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                              if(error == nil && [httpResponse statusCode] < 400)
                                              {
                                                  NSData* newData = [someString dataUsingEncoding:NSUTF8StringEncoding];
                                                  id jsonDic = nil;
                                                  
                                                  if(newData)
                                                      jsonDic = [NSJSONSerialization JSONObjectWithData:newData options:NSJSONReadingMutableContainers error:NULL];
                                                  
                                                  
                                                  if([jsonDic isKindOfClass:[NSDictionary class]] && [[jsonDic valueForKey:STATUS_KEY] isEqualToString:FAILD_KEY]){
                                                      
                                                      if([[jsonDic valueForKeyPath:@"msg.description"] isEqualToString:@"Your phone number is not verified."]){
                                                          
                                                          if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didFailedWithError:forTag: withData:)])
                                                              [self.delegate didFailedWithError:error forTag:-1000 withData:jsonDic];
                                                          
                                                      }else if([[jsonDic valueForKeyPath:@"msg.description"] isEqualToString:@"Your email is not verified."]){
                                                          
                                                          if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didFailedWithError:forTag: withData:)])
                                                              [self.delegate didFailedWithError:error forTag:-2000 withData:jsonDic];
                                                      }else{
                                                          if(![self.delegate isKindOfClass:[AppDelegate class]])
                                                          {
                                                              if ([[jsonDic valueForKey:@"msg"] isKindOfClass:[NSDictionary class]] && ([[jsonDic valueForKeyPath:@"msg.title"]isEqualToString:@"Experience Missing!"] || [[jsonDic valueForKeyPath:@"msg.title"]isEqualToString:@"Education Missing!" ] || [[jsonDic valueForKeyPath:@"msg.title"]isEqualToString:@"Finish Signing Up"])) {
                                                                  
                                                                  [CustomAlertView showAlertForUpdate:[jsonDic valueForKeyPath:@"msg.title"]  message:[jsonDic valueForKeyPath:@"msg.description"] OkButton:@"Update" cancelButton:@"Cancel" delegate:self.delegate];
                                                                  
                                                              }else{
                                                                  if([[jsonDic valueForKey:@"msg"] isKindOfClass:[NSDictionary class]]){
                                                                      [CustomAlertView showAlertWithTitle:[jsonDic valueForKeyPath:@"msg.title"] message:[jsonDic valueForKeyPath:@"msg.description"] OkButton:@"Ok" delegate:self.delegate];
                                                                  }else{
                                                                      [CustomAlertView showAlertWithTitle:nil message:[jsonDic valueForKeyPath:@"msg"] OkButton:@"Ok" delegate:self.delegate];
                                                                  }
                                                              }
                                                          }
                                                      }
                                                      return;
                                                  }else{
                                                      if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didReceivedResponseWithData:forTag:)]) {
                                                          
                                                          if([jsonDic isKindOfClass:[NSDictionary class]])
                                                              jsonDic = [Utility  removeNullRecursive:[jsonDic mutableCopy]];
                                                          
                                                          [self.delegate didReceivedResponseWithData:jsonDic forTag:self.requestType];
                                                          self.delegate=nil;
                                                      }
                                                  }
                                              }else{
                                                  if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didFailedWithError:forTag:)])
                                                      [self.delegate didFailedWithError:error forTag:self.requestType];
                                              }
                                          });
                                          
                                          
                                      }];
    [self.dataTask resume];
}
@end

