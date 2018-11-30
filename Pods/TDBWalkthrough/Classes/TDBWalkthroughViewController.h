//
//  TDBWalkThroughViewController.h
//  TDBWalkthrough
//
//  Created by Titouan Van Belle on 24/04/14.
//  Copyright (c) 2014 3dB. All rights reserved.
//

#import <UIKit/UIKit.h>



@class TDBWalkthrough;
@interface TDBWalkthroughViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property(strong, nonatomic) UIButton *get_strated_button;

@property(nonatomic,assign) TDBWalkthrough *walk_through_object;


#pragma mark - Setup Methods

- (void)setupWithClassName:(NSString *)className
                   nibName:(NSString *)nibName
                    images:(NSArray *)images
              descriptions:(NSArray *)descriptions;

@end
