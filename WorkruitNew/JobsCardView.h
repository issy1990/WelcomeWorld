//
//  JobsCardView.h
//  Workruit
//
//  Created by Admin on 9/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface JobsCardView : UIView <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,strong) NSMutableDictionary *profile_dictionary;
@property(nonatomic,strong)  UITableView *table_view;
@property(nonatomic,strong) UIImageView *likeTickImage,*passTickImage;

@end
