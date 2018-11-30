//
//  FMDBDataAccess.h
//  Chanda
//
//  Created by Mohammad Azam on 10/25/11.
//  Copyright (c) 2011 HighOnCoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h" 
#import "FMResultSet.h" 

@interface FMDBDataAccess : NSObject
+(FMDBDataAccess *)sharedInstance;
-(void)start;
-(void)dropTheDataBaseAndReplaceDatabase;
-(NSMutableArray *)getDataFromDB:(NSString *)sql;
-(BOOL)exicuteQuery:(NSString *)sql;
@end
