//
//  CustomAlert.h
//  workruit
//
//  Created by Admin on 10/21/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeaderFiles.h"

@protocol AlertViewDelegate_Custom_Delegate;
@protocol AlertViewDelegate_Custom_Delegate <NSObject>
@optional
-(void)didClickedAlertButtonWithIndex:(NSInteger)buttonIndex tag:(NSInteger)tag;
@end

@interface CustomAlertView : NSObject

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton delegate:(id)delegate;

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton cancelButton:(NSString *)cancelButton delegate:(id)delegate withTag:(NSInteger)tag;

+(void)showAlertWithTitle1:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton delegate:(id)delegate;

+(void)showAlertForUpdate:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton cancelButton:(NSString *)cancelButton delegate:(id)delegate;

+(void)showAlertWithTitleDelegate:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton delegate:(id)delegate;
@end
