//
//  WRACMatchScreen.h
//  workruit
//
//  Created by Admin on 1/7/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WRACMatchScreen : UIViewController

@property(nonatomic,weak) IBOutlet UILabel *lable_1;
@property(nonatomic,weak) IBOutlet UILabel *lable_2;
@property(nonatomic,weak) IBOutlet  UILabel *lable_3;

@property(nonatomic,weak) IBOutlet UIImageView *image_view;

@property(nonatomic,weak) IBOutlet UIButton *chat_with_button;

@property(nonatomic,strong) NSMutableDictionary *selectedDic;

@property(nonatomic,strong) NSDictionary *notification_payload;
@property(nonatomic,weak)IBOutlet UIView *backgroundView;
@property(nonatomic,strong) NSMutableDictionary *dictionary_global;

@end
