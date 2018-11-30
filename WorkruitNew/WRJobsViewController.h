//
//  WRJobsViewController.h
//  workruit
//
//  Created by Admin on 10/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "AppDelegate.h"

@class ApplicantHelper;
@interface WRJobsViewController : UIViewController
{
    
}
@property(nonatomic,weak) IBOutlet UITableView *table_view;
@property(nonatomic,weak) IBOutlet UIButton *create_job_btn;

@property(nonatomic,strong) IBOutlet UISegmentedControl *segmentController;
@property(nonatomic,readwrite) int navigateToCreateJobScreen;

@property(nonatomic,weak) IBOutlet UIView *no_jobs_view;
@property(nonatomic,weak) IBOutlet UILabel *titleLbl, *messageLbl;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint * top_Contsrint, * second_contsrint;

@end
