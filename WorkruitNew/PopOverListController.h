//
//  popOverListController.h
//  workruit
//
//  Created by Admin on 10/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@protocol POPOVER_Delegate;
@protocol POPOVER_Delegate <NSObject>
@optional
-(void)didSelectValue:(NSString *)value forIndex:(int)index;
@end

@interface PopOverListController : UITableViewController
@property(nonatomic,strong)    NSMutableArray *allCountriesArray;
@property(nonatomic,strong)    NSMutableArray *filterdCountriesArray;
@property(nonatomic,assign) id <POPOVER_Delegate>delegate;
-(void)filterTheArray:(NSString *)query;
-(void)filterTheArrayWithBegen:(NSString *)query;
@end
