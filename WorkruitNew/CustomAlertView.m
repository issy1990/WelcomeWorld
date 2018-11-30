//
//  CustomAlert.m
//  workruit
//
//  Created by Admin on 10/21/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton delegate:(id)delegate
{
    UIAlertController * alert_controller=   [UIAlertController
                                             alertControllerWithTitle:title
                                             message:message
                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:OkButton
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             NSLog(@"Resolving UIAlert Action for tapping OK Button");
                             [alert_controller dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert_controller addAction:ok];
    [delegate presentViewController:alert_controller animated:YES completion:nil];
}

+(void)showAlertWithTitle1:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton delegate:(id)delegate
{
    UIAlertController * alert_controller=   [UIAlertController
                                             alertControllerWithTitle:title
                                             message:message
                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:OkButton
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [delegate didClickedAlertButtonWithIndex:1 tag:1];
                             NSLog(@"Resolving UIAlert Action for tapping OK Button");
                             [alert_controller dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert_controller addAction:ok];
    [delegate presentViewController:alert_controller animated:YES completion:nil];
}

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton cancelButton:(NSString *)cancelButton delegate:(id)delegate withTag:(NSInteger)tag
{
    UIAlertController * alert_controller=   [UIAlertController
                                             alertControllerWithTitle:title
                                             message:message
                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:OkButton
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [delegate didClickedAlertButtonWithIndex:1 tag:tag];
                             [alert_controller dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert_controller addAction:ok];
    
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:cancelButton
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [delegate didClickedAlertButtonWithIndex:2 tag:tag];
                             [alert_controller dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert_controller addAction:cancel];
    
    [delegate presentViewController:alert_controller animated:YES completion:nil];
}
+(void)showAlertForUpdate:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton cancelButton:(NSString *)cancelButton delegate:(id)delegate
{
UIAlertController *alertView  =   [UIAlertController
                                   alertControllerWithTitle:title
                                   message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction* ok = [UIAlertAction
                     actionWithTitle:cancelButton
                     style:UIAlertActionStyleDefault
                     handler:^(UIAlertAction * action)
                     {
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"callAPIsToRefreshTheData" object:nil userInfo:nil];
                         [alertView dismissViewControllerAnimated:YES completion:nil];
                     }];
    
UIAlertAction* update = [UIAlertAction
                         actionWithTitle:@"Update"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION_ON_CLICK object:nil userInfo:[Utility getDefaultUpdateProfileNotificationObject:title]];
                             [FireBaseAPICalls captureMixpannelEvent:APPLICANT_HOME_INCOMPLETENOJOBS_TEXTCLICK];
                             [delegate dismissViewControllerAnimated:YES completion:nil];
                         }];
[alertView addAction:ok];
[alertView addAction:update];
[delegate presentViewController:alertView animated:YES completion:nil];
}


+(void)showAlertWithTitleDelegate:(NSString *)title message:(NSString *)message OkButton:(NSString *)OkButton delegate:(id)delegate
{
    UIAlertController * alert_controller=   [UIAlertController
                                             alertControllerWithTitle:title
                                             message:message
                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:OkButton
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             NSLog(@"Resolving UIAlert Action for tapping OK Button");
                             [delegate didClickedAlertButtonWithIndex:1 tag:1];
                             [alert_controller dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert_controller addAction:ok];
    [delegate presentViewController:alert_controller animated:YES completion:nil];
}



@end
