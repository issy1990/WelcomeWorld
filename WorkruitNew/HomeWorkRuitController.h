//
//  HomeWorkRuitController.h
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import "HMSegmentedControl.h"
#import "TDBWalkthrough.h"
#import "HHSlideView.h"

@interface HomeWorkRuitController : UIViewController

@property(nonatomic,weak) IBOutlet UIButton *btn_one, *btn_two;
@property(nonatomic,weak) IBOutlet UIView *buttom_view;
@property(nonatomic,weak) IBOutlet UILabel *messageLbl;
@property(nonatomic,weak) IBOutlet HHSlideView *slideView;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *htConstraint;

-(IBAction)buttonClicked:(id)sender;

@end
