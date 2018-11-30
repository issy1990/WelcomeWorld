//
//  ChatDataModel.h
//  PUBNUB_SAMPLE
//
//  Created by Admin on 12/9/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"

@interface ChatDataModel : NSObject

//Message object model
+ (JSQMessage *)getMessageObject:(NSDictionary *)item;

@end
