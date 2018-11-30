//
//  WRCandidateProfileController.h
//  workruit
//
//  Created by Admin on 10/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRCandidateProfileController : UIViewController

@property (nonatomic, strong) YSLDraggableCardContainer *container;
//TODO
@property(nonatomic,weak) IBOutlet UILabel *message_lbl;
@property(nonatomic,weak) IBOutlet UIButton *create_job_btn;
@property(nonatomic,weak) IBOutlet UILabel *title_lbl;

@property(nonatomic,weak) IBOutlet UIView *welcomeToView;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *topConstraint;
@property(nonatomic,weak) IBOutlet UIButton *preferenceButton;
@property(nonatomic,weak) IBOutlet UIView *headerView;
@property(nonatomic,strong) UIView *imageViewBlink;
@property(nonatomic,strong) NSMutableArray *demoCardArray;
@property(nonatomic,weak) IBOutlet UILabel * headerJoblbl;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint * label_Contsrint, * top_contsraint;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint * btn_Contsrint;

@end
