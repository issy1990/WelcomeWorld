//
//  WREnterSocialMedia.h
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WREnterSocialMedia : UIViewController
@property(nonatomic, weak) IBOutlet UITableView *table_view;

-(IBAction)skipButtonAction:(id)sender;
-(IBAction)nextButtonForProcess:(id)sender;
-(IBAction)previousButtonAction:(id)sender;
@end
