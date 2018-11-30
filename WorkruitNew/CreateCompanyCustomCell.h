//
//  CreateCompanyCustomCell.h
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface CreateCompanyCustomCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *titleLbl;
@property(nonatomic,weak) IBOutlet CustomTextField *ValueTF;
@property(assign) BOOL check;

@end
