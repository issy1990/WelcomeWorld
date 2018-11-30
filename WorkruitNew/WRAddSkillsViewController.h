//
//  WRAddSkillsViewController.h
//  workruit
//
//  Created by Admin on 10/23/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@protocol SAVETags_Delegate;
@protocol SAVETags_Delegate <NSObject>
@optional
-(void)didSelectWithTags:(NSMutableArray *)array;
@end

@interface WRAddSkillsViewController : UIViewController

@property(nonatomic,assign) id <SAVETags_Delegate>delegate;
@property(nonatomic,strong) IBOutlet UITableView *table_view;
@property(nonatomic,strong) CJCompanyHelper *cjCompanyObject;
@property(nonatomic,strong) NSMutableArray *suggestedSkillsArray;
@end
