//
//  LoadOtherJobsViewController.h
//  WorkruitNew
//
//  Created by Chandra on 2/11/18.
//  Copyright © 2018 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadOtherJobsViewController : UIViewController

@property(weak,nonatomic) IBOutlet UIWebView * webView;
@property(strong,nonatomic)NSString * webLink;
@property(strong,nonatomic)NSString * titleStr;
@property(weak,nonatomic) IBOutlet UILabel * navLabel;

-(IBAction)backButtonAction:(id)sender;

@end
