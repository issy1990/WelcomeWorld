//
//  ChooseCompanyIndustry.h
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRChooseCompanyIndustry : UIViewController
@property(nonatomic,weak) IBOutlet UIButton *nextButton,*backButton;
@property(nonatomic, weak) IBOutlet UITableView *table_view;
@property(nonatomic, weak) IBOutlet UILabel *headerLbl;
@property(nonatomic, weak) IBOutlet UILabel *messageLbl;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *topConstrant;
@property(nonatomic,strong) NSMutableArray *mutableArray;
@property(nonatomic,readwrite) BOOL isNextButtonHide;
@property(nonatomic,readwrite) BOOL isBackButtonHide;
@property(nonatomic,readwrite) BOOL isCommingFromEditApplicant;

-(IBAction)nextButtonForProcess:(id)sender;
-(IBAction)previousButtonAction:(id)sender;
@end
