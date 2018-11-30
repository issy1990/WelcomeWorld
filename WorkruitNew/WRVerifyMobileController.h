//
//  WRVerifyMobileController.h
//  workruit
//
//  Created by Admin on 10/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
@protocol MOBILE_NUMBER_CHANGE_DELEGATE;
@protocol MOBILE_NUMBER_CHANGE_DELEGATE <NSObject>
@optional
-(void)mobileNumberDidChangeWithTag:(int)tag;
@end


@interface WRVerifyMobileController : UIViewController
@property(nonatomic, weak) IBOutlet UITableView *table_view;
@property(nonatomic,strong) NSString *myInformationForDev;
@property(nonatomic,strong) NSString *old_phone_number;
@property(nonatomic,assign) NSMutableDictionary *json_data_dictionary;
@property(nonatomic,weak) IBOutlet UIButton *save_button;
@property(nonatomic,readwrite) int isFromAccountScreen;
@property(nonatomic,retain)id<MOBILE_NUMBER_CHANGE_DELEGATE>delegate;

@end
