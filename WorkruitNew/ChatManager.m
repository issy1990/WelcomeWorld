//
//  ChatManager.m
//  FirebaseChatDemo
//
//  Created by Matt Amerige on 7/7/16.
//  Copyright © 2016 mamerige. All rights reserved.
//

#import "ChatManager.h"

@interface ChatManager ()

@end

@implementation ChatManager

+ (instancetype)sharedManager
{
    static ChatManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ChatManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate: nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)connect
{
    // Create a reference to the messages path
    chatReference = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"/channels/%@",self.channel_name]];
    [chatReference keepSynced:YES];
    
    // Listen for new messages
    [self listenForNewMessages];
    
    // Listen for deleted messages
    [self listenForDeletedMessages];
}

- (void)listenForNewMessages
{
    [chatReference observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if (snapshot.value) {
             NSDictionary *dictionary_object = (NSDictionary *)snapshot.value;
             NSDate *date_one = [Utility getDateWithStringDate:[dictionary_object valueForKey:@"date"] withFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
             
             if(date_one == nil){
                 date_one = [Utility getDateWithStringDate:[dictionary_object valueForKey:@"date"] withFormat:@"yyyy-MM-dd HH:mm:ss.zzz"];
             }
             if(date_one == nil)
             {
                 NSString * data = [dictionary_object valueForKey:@"date"];
                 NSString * finalStr =[data stringByReplacingOccurrencesOfString:@"IST" withString:@""];
                 date_one = [Utility getDateWithStringDate:finalStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
             }
             
             NSMutableArray *arrayObjects = [[FMDBDataAccess sharedInstance] getDataFromDB:[NSString stringWithFormat:@"select *from chat_table where msg_id = '%@'",[dictionary_object valueForKey:@"msg_id"]]];
             
             if (arrayObjects.count == 0) {
                 NSString *message = [dictionary_object valueForKey:@"msg"];
                 
                 if ([message isEqualToString:APP_DEFAULT_MESSAGE])
                     return;
                 
                 message = [message stringByReplacingOccurrencesOfString:@"\'" withString:@""];
                 message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                 
                 [[FMDBDataAccess sharedInstance] exicuteQuery:[NSString stringWithFormat:@"insert or replace into chat_table (channel_name,date,from_id,to_id,msg_id,msg,chat_type,media_type) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')",self.channel_name,[dictionary_object valueForKey:@"date"],[dictionary_object valueForKey:@"from_id"],[dictionary_object valueForKey:@"to_id"],[dictionary_object valueForKey:@"msg_id"],message,[dictionary_object valueForKey:@"chat_type"],[dictionary_object valueForKey:@"media_type"]]];
                 
                 JSQMessage *object_message = [[JSQMessage alloc] initWithSenderId:[dictionary_object valueForKey:@"from_id"] senderDisplayName:[dictionary_object valueForKey:@"msg_id"] date:date_one text:[dictionary_object valueForKey:@"msg"]];
                 
                 if (self.delegate && [self.delegate respondsToSelector:@selector(messagesDidUpdate:)]) {
                     [self.delegate messagesDidUpdate:object_message];
                 }
             }
         }
     }];
}

- (void)listenForDeletedMessages
{
    [chatReference observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value) {
        }
    }];
    //Need to update latest call back here
}

-(void)clearAllAbserver
{
    [chatReference removeAllObservers];
}

- (void)sendMessageFrom:(NSString *)senderName withContent:(NSMutableDictionary *)content withPayload:(NSMutableDictionary *)payload
{
    FIRDatabaseReference *chatReferenceNew = [chatReference childByAutoId];
    [chatReferenceNew keepSynced:YES];
    [chatReferenceNew setValue:content];
    [self sendPayloadToFCMserverWithPayload:payload];
}

-(void)sendPayloadToFCMserverWithPayload:(NSMutableDictionary *)payload
{
    NSMutableURLRequest*request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://fcm.googleapis.com/fcm/send"]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:[NSString stringWithFormat:@"key=AIzaSyCkp3D1z9XqtD19bH8PGJU2dzNiwMj4wjg"] forHTTPHeaderField:@"Authorization"];
    
    if (payload) {
        NSLog(@"%@",[Utility convertDictionaryToJSONString:payload]);
        [request setHTTPBody:[[Utility convertDictionaryToJSONString:payload] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    request.timeoutInterval = 30;
    [request setHTTPMethod:@"POST"];
    self.dataTask = [defaultSession dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                      }];
    [self.dataTask resume];
}

@end

