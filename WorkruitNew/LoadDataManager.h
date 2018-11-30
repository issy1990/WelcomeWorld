//
//  LoadDataManager.h
//  DAS mobile
//
//  Created by eMbience
//  Copyright (c) Digital Air Strike 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ConnectionManager.h"

@interface LoadDataManager : NSObject<HTTPHelper_Delegate>
@property(nonatomic,strong) UITabBarController *tabBarController;
+(LoadDataManager *)sharedInstance;
-(void)getApplicationData;
@end
