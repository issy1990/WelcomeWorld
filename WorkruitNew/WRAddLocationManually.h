//
//  WRAddLocationManually.h
//  WorkruitNew
//
//  Created by Admin on 9/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"


@interface WRAddLocationManually : UIViewController

@property(nonatomic,strong) IBOutlet UITableView *table_view;
@property(nonatomic,strong) NSMutableArray *suggestedSkillsArray;
@property(nonatomic,strong) NSMutableArray *redefineLocationsArray;
@end
