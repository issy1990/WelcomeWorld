//
//  WRUploadAPicture.h
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WRUploadAPicture.h"
#import "HeaderFiles.h"


@interface WRUploadAPicture : UIViewController
@property(nonatomic,strong)IBOutlet UIButton *upload_button;
@property(nonatomic,strong)IBOutlet UIImageView *profilePic;

-(IBAction)previousButtonAction:(id)sender;
-(IBAction)skipButtonAction:(id)sender;

@end
