//
//  CEDatabasePrivateCommon.h
//  CEDatabase
//
//  Created by chance on 14-10-8.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>

#define enableYLDebug 0

// log 定义
#if DEBUG && enableYLDebug
//#define CEDatabaseLog(xx, ...) NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define CEDatabaseLog(xx, ...) NSLog(xx, ##__VA_ARGS__)
#else
#define CEDatabaseLog(xx, ...)
#endif


// Sqlite keywords, uppercase strings
NSSet *SqliteKeywords();

// dictionary for transferring ObjC type to Sqlite type
NSDictionary *ObjCToSqliteTypeDict();


// conver string to legal sqlite table name
NSString *ConvertToSqliteTableName(NSString *tableName);


@interface ColumnInfo : NSObject

@property (nonatomic, strong) NSString *name;       // 表列名
@property (nonatomic, strong) NSString *sqliteType; // sqlite类型
@property (nonatomic, strong) NSString *objcType;   // OC类型，包括C
@property (nonatomic, strong) NSString *propertyName; // 列对应的property名称
@property (nonatomic) BOOL isPrimaryKey;                // 是否为主键

@end


