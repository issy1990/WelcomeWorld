//
//  LoadOtherJobsViewController.m
//  WorkruitNew
//
//  Created by Chandra on 2/11/18.
//  Copyright © 2018 Admin. All rights reserved.
//

#import "LoadOtherJobsViewController.h"

@interface LoadOtherJobsViewController ()

@end

@implementation LoadOtherJobsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navLabel.text = self.titleStr;
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.webLink]]];
    [_webView loadRequest:request];
}

-(IBAction)backButtonAction:(id)sender;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
