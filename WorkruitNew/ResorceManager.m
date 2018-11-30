//
//  ResorceManager.m
//  workruit
//
//  Created by Admin on 10/28/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ResorceManager.h"

@implementation ResorceManager

/*+(void)pushNavigationToViewController:(UIViewController )viewController navigationController:(UIViewController )context animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[[context.navigationController childViewControllers] lastObject] class] != [viewController class]) {
            
            BOOL controller_in_stack = NO;
            
            for(UIViewController *controllerInStack in context.navigationController.viewControllers){
                if([controllerInStack isKindOfClass:[viewController class]]){
                    controller_in_stack = YES;
                    [context.navigationController popToViewController:controllerInStack animated:NO];
                    break;
                }
            }
            // push navigation
            if(!controller_in_stack)
                [context.navigationController pushViewController:viewController animated:animated];
        }
    });
}*/

@end
