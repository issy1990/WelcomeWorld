//
//  WRCreateComapnyAccount.h
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
@class CompanyHelper;
@class ApplicantHelper;
@interface WRCreateComapnyAccount : UIViewController<UITextFieldDelegate>
@property(nonatomic, weak) IBOutlet UITableView *table_view;
@property(nonatomic,strong) IBOutlet UILabel *terms_condtion_lable;

-(IBAction)backButtonAction:(id)sender;
-(IBAction)nextButtonForProcess:(id)sender;
-(IBAction)openURLWithAction:(id)sender;

@end
