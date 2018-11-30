//
//  WREditCompanyProfile.h
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WREditCompanyProfile : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,RSKImageCropViewControllerDelegate>
@property(nonatomic, weak) IBOutlet UITableView *table_view;
@property(nonatomic,readwrite) int isCommingFromFlag;
@property(nonatomic,weak) IBOutlet UIButton *save_button;
@property(nonatomic,weak) IBOutlet UIButton *back_button;
@property(nonatomic,readwrite) BOOL isSignUpProcess;

-(IBAction)saveButtonAction:(id)sender;
@end
