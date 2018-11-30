//
//  ConnectionManager.h
//  DAS mobile
//
//  Created by eMbience
//  Copyright (c) Digital Air Strike 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFiles.h"

@protocol HTTPHelper_Delegate;
@protocol HTTPHelper_Delegate <NSObject>
@optional
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag;
-(void)didFailedWithError:(NSError *)error forTag:(int)tag;
-(void)didFailedWithError:(NSError *)error forTag:(int)tag withData:(NSDictionary *)data;
@end

@interface ConnectionManager : NSObject
{
    NSURLSession *defaultSession;
}
@property(nonatomic,retain)id<HTTPHelper_Delegate>delegate;
@property(nonatomic,retain)NSURLSessionDataTask * dataTask;
@property (nonatomic,readwrite) int requestType;


-(void)startRequestWithURL:(NSString *)verifyURL WithParams:(NSString *)verifyReqStr  forRequest:(int)reqType controller:(id)controller httpMethod:(NSString *)method;

@end
