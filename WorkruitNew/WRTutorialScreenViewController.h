//
//  WRTutorialScreenViewController.h
//  workruit
//
//  Created by Admin on 6/17/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderFiles.h"

@interface WRTutorialScreenViewController : UIViewController<YSLDraggableCardContainerDelegate, YSLDraggableCardContainerDataSource>
@property (nonatomic, strong) YSLDraggableCardContainer *container;

@end
