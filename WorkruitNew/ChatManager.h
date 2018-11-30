//
//  ChatManager.h
//  FirebaseChatDemo
//
//  Created by Matt Amerige on 7/7/16.
//  Copyright © 2016 mamerige. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "HeaderFiles.h"
#import "JSQMessage.h"

@protocol ChatManagerDelegate <NSObject>

/**
 Called whenever the chat manager receives a new message
 */
- (void)messagesDidUpdate:(JSQMessage*)message;

@end

@interface ChatManager : NSObject
{
    NSURLSession *defaultSession;
    FIRDatabaseReference *chatReference;
}

@property(nonatomic,strong) NSString *channel_name;
@property(nonatomic,retain) NSURLSessionDataTask *dataTask;

/**
 @abstract Delegates of the ChatManager can receive chat updates
 */
@property (nonatomic, weak) id<ChatManagerDelegate> delegate;

/**
 @abstract Shared instane of the Chat Manager
 */
+ (instancetype)sharedManager;

/**
 @abstract Connects this device to the Firebase chat database
 */
- (void)connect;

/**
 @abstract Sends a message to the database.}
 */
- (void)sendMessageFrom:(NSString *)senderName withContent:(NSMutableDictionary *)content withPayload:(NSMutableDictionary *)payload;
- (void)clearAllAbserver;

@end
