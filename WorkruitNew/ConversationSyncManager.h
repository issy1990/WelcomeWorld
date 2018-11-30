//
//  ConversationSyncManager.h
//  WorkruitNew
//
//  Created by Vishal Singh Panwar on 21/05/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionManager.h"

@interface ConversationSyncManager : NSObject<HTTPHelper_Delegate>

-(void)syncConversation:(void (^)(BOOL))completion;

@end
