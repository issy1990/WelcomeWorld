//
//  GoodLuckCardViewController.m
//  workruit
//
//  Created by Teja on 8/16/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "GoodLuckCardViewController.h"

@interface GoodLuckCardViewController ()

@end

@implementation GoodLuckCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.image_view.layer.cornerRadius = self.image_view.frame.size.width/2;
    self.image_view.layer.masksToBounds = YES;
    
    NSString *urlString = [[NSUserDefaults standardUserDefaults] stringForKey:@"demo_image"];
    
                          
    [self.image_view sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"goodluckimage"]] ;
    [self.button setTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"demo_button"] forState:UIControlStateNormal];
    self.lable_2.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"demo_heading"];
    self.lable_1.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"demo_text"];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
     
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)startdemo:(id)sender{
    
   [self dismissViewControllerAnimated:YES completion:nil];



}

@end
