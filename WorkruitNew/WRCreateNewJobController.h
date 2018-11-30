//
//  WRCreateNewJobController.h
//  workruit
//
//  Created by Admin on 10/6/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@protocol WRCreateNewJobControllerDelegate;
@protocol WRCreateNewJobControllerDelegate <NSObject>
@optional
-(void)didSucessfullyClosedJob:(NSDictionary *)job forTag:(int)tag;
@end

@class CJCompanyHelper;
@interface WRCreateNewJobController : UIViewController
@property(nonatomic,weak) IBOutlet UITableView *table_view;
@property(nonatomic,weak) IBOutlet UILabel *header_lbl;
@property(nonatomic,strong) CJCompanyHelper *cjCompanyObject;
@property(nonatomic,strong) NSMutableDictionary *selectedDictionary;
@property(nonatomic,weak) IBOutlet UIButton *save_button;
@property (assign, nonatomic) IBInspectable CGFloat tagSpacing;
@property(nonatomic,weak)id<WRCreateNewJobControllerDelegate>delegate;

-(IBAction)createJobAction:(id)sender;

@end
