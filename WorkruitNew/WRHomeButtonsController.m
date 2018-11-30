//
//  WRHomeButtonsController.m
//  workruit
//
//  Created by Admin on 2/5/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "WRHomeButtonsController.h"

@interface WRHomeButtonsController ()

@end

@implementation WRHomeButtonsController
{
    IBOutlet UIView * myView;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.button_one.layer.cornerRadius = self.button_one.frame.size.height/2;
    self.button_two.layer.cornerRadius = self.button_two.frame.size.height/2;
    
    self.button_two.layer.borderColor = [UIColor colorWithRed:51/255.0f green:122/255.0f blue:183/255.0f alpha:1.0f].CGColor;
    self.button_two.layer.borderWidth = 1.5f;
    self.button_two.layer.masksToBounds = YES;

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

@end
