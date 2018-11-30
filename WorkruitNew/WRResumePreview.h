//
//  WRResumePreview.h
//  WorkruitNew
//
//  Created by Admin on 10/2/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRResumePreview : UIViewController
@property(nonatomic,weak) IBOutlet UIWebView *webView;
@property(nonatomic,strong) NSString  *string_url;
@property(nonatomic,weak) IBOutlet UIButton *changeButton;
@end
