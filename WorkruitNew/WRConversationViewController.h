//
//  ConversationViewController.h
//  workruit
//
//  Created by Admin on 12/18/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@class WRActivityViewController;
@interface WRConversationViewController : JSQMessagesViewController

@property(nonatomic,strong) NSMutableDictionary *object_dictionary;
-(IBAction)backButtonAction:(id)sender;
@end
