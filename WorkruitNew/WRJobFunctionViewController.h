//
//  WRJobFunctionViewController.h
//  workruit
//
//  Created by Admin on 7/10/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "WRSkillsViewController.h"

@interface WRJobFunctionViewController : UIViewController
@property(nonatomic,strong) NSMutableArray *mutableArray;
@property(nonatomic,weak) IBOutlet UITableView *table_view;
@property(nonatomic,weak) IBOutlet UIButton *nextButton,*backButton;
@property(nonatomic, weak) IBOutlet UILabel *headerLbl;
@property(nonatomic, weak) IBOutlet UILabel *messageLbl;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *topConstrant;
@property(nonatomic,readwrite) BOOL isCommingFromEditApplicant;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint* authorLabelHeight;
@property (weak, nonatomic) IBOutlet ASJTagsView *tagsView1;
@end
