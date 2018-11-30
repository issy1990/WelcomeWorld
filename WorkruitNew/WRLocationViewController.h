//
//  WRLocationViewController.h
//  workruit
//
//  Created by Admin on 10/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
#import<UIKit/UIKit.h>
#import<CoreLocation/CoreLocation.h>

@interface WRLocationViewController : UIViewController

@property(nonatomic, weak) IBOutlet UITableView *table_view;
@property (nonatomic,weak) IBOutlet UILabel *headerLbl;
@property(nonatomic,readwrite) int flag;
@property(nonatomic,weak) IBOutlet UIButton *save_button;
//@property(nonatomic,strong) CLLocationManager *manager;
@property (nonatomic, strong) NSArray *titlesArray;
@property (nonatomic, strong) NSString *jobTypeFromArray;

@property (nonatomic, strong) NSMutableArray *filteredTitlesArray;
@property(nonatomic,assign) NSMutableDictionary *json_data_from_profile;
@property(nonatomic,readwrite) int isComingFromSignUpProcess;
@property(nonatomic,strong) NSString *comingFromAccountPage;

@end
