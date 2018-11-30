//
//  WRNotesViewController.h
//  workruit
//
//  Created by Admin on 7/9/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRNotesViewController : UIViewController <UITextViewDelegate>
@property(nonatomic,weak) IBOutlet UITextView *notesTextView;
@property(nonatomic,weak) IBOutlet UILabel *wordCount;
@property(nonatomic,weak) IBOutlet UIButton *skipButton;
@property(nonatomic, weak) IBOutlet UITableView *table_view;
@end
