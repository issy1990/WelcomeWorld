//
//  AutoSuggestionCell.h
//  workruit
//
//  Created by Admin on 10/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"
@interface AutoSuggestionCell : UITableViewCell<UITextFieldDelegate>
@property(nonatomic,weak) IBOutlet UILabel *titleLbl;
@property(nonatomic,weak) IBOutlet CustomTextField *ValueTF;





@end
