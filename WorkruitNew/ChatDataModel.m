//
//  ChatDataModel.m
//  PUBNUB_SAMPLE
//
//  Created by Admin on 12/9/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ChatDataModel.h"

@implementation ChatDataModel

//{from_id:””,to_id:””,msg_id:””,msg:””,date:””,media_type:””,chat_type:””}

//Message object model
+ (JSQMessage *)getMessageObject:(NSDictionary *)item
{
    NSString *text_Messsage = item[@"msg"];;
    NSString *name = item[@"to_id"];
    NSString *userId = item[@"to_id"];
    NSDate *date = [NSDate date];// String2Date(item[@"date"]);
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date text:text_Messsage];
    
    return message;
}


- (JSQMessage *)addPhotoMediaMessage:(NSDictionary *)item
{
    NSString *name = item[@"to_id"];
    NSString *userId = item[@"to_id"];
    //NSDate *date = [NSDate date];// String2Date(item[@"date"])

    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"demo_avatar_woz"]];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:userId
                                                   displayName:name
                                                         media:photoItem];
    return photoMessage;
}

@end
