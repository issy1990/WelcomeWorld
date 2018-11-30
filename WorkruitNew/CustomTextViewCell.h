//
//  CustomTextViewCell.h
//  workruit
//
//  Created by Admin on 10/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRWordCountHelper.h"
@interface CustomTextViewCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *titleLbl;
@property(nonatomic,weak) IBOutlet UITextView *text_view;
@property(nonatomic,weak) IBOutlet UILabel *wordCount;
@end
