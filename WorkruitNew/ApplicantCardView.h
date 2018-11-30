//
//  ApplicantCardView.h
//  workruit
//
//  Created by Admin on 11/22/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface ApplicantCardView : UIView <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) NSMutableDictionary *profile_dictionary;
@property(nonatomic,strong) UITableView *table_view;
@property(nonatomic,strong) UIImageView *likeTickImage,*passTickImage;
@property (nonatomic,weak) IBOutlet UIImageView *imageView;
- (void)startAnim;
@end
