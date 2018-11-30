//
//  FireBaseAPICalls.h
//  workruit
//
//  Created by Admin on 3/4/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFiles.h"
@class Firebase;
@interface FireBaseAPICalls : NSObject
+(void)captureScreenDetails:(NSString *)title;
+(void)captureMixpannelEvent:(NSString *)title;
@end
