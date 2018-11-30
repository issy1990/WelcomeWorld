//
//  FMDBDataAccess.m
//  Chanda
//
//  Created by Mohammad Azam on 10/25/11.
//  Copyright (c) 2011 HighOnCoding. All rights reserved.
//

#import "FMDBDataAccess.h"

#define DB_NAME @"workruit_V1.sqlite"

@implementation FMDBDataAccess

+(FMDBDataAccess *)sharedInstance
{
    static FMDBDataAccess *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FMDBDataAccess alloc] init];
    });
    return sharedInstance;
}

-(void)start
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentDir stringByAppendingPathComponent:DB_NAME];
    
    NSLog(@"%@",databasePath);
    NSError *error;

    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    if(success)
        return;
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
    success = [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:&error];
    NSLog(@"%@",error);
}

-(void)dropTheDataBaseAndReplaceDatabase
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentDir stringByAppendingPathComponent:DB_NAME];
    
    NSLog(@"%@",databasePath);
    NSError *error;
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    if(success)
        [fileManager removeItemAtPath:databasePath error:&error];
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
    success = [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:&error];
    NSLog(@"%@",error);
}

-(BOOL)exicuteQuery:(NSString *)sql
{
    FMDatabase *db = [FMDatabase databaseWithPath:[self db_name]];
    [db open];
    BOOL success = [db executeUpdate:sql];
    [db close];
    return success;
}

-(NSMutableArray *)getDataFromDB:(NSString *)sql
{
    if(sql == nil)
        return nil;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[self db_name]];
    
    [db open];
    FMResultSet *results = [db executeQuery:sql];
    while([results next])
    {
        NSDictionary *dic = [results resultDictionary];
        [array addObject:dic];
    }
    [db close];
    return array;
}

-(NSString *)db_name
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return  [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:DB_NAME];
}

@end
