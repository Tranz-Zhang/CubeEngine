//
//  CEDatabase.h
//  CEDatabase
//
//  Created by chancezhang on 14-7-29.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEDatabaseNotifications.h"

/**
 数据库文件
 
 负责在本地目录下创建db文件，以及数据库一些基本参数的设置
 */

@interface CEDatabase : NSObject

/** 数据库名称 */
@property (nonatomic, readonly) NSString *name;

/** 数据库存储路径 */
@property (nonatomic, readonly) NSString *filePath;

/** 数据库是否可用*/
@property (nonatomic, readonly, getter = isEnabled) BOOL enable;


/**
 创建数据库
 @param databaseName 数据库名称
 @param dbFilePath 数据库存储路径，不需要带数据库名称，如:...Document/Database,
        nil时存储在Document的syb_database目录下面
 */
+ (CEDatabase *)databaseWithName:(NSString *)databaseName;
+ (CEDatabase *)databaseWithName:(NSString *)databaseName inPath:(NSString *)path;
- (id)initWithName:(NSString *)databaseName inPath:(NSString *)path;


/**
 删除数据库，会关闭当前数据库并且删除本地的db文件
 删除前发出通知:CEDatabaseRemovedNotification
 
 @param databaseName 数据库名称
 @param dbFilePath 数据库存储路径，不需要带数据库名称，如:...Document/Database,
 nil时默认选择Document下面的syb_database目录
 */
+ (BOOL)removeDatabase:(NSString *)databaseName error:(NSError * __autoreleasing *)error;
+ (BOOL)removeDatabase:(NSString *)databaseName inPath:(NSString *)path error:(NSError * __autoreleasing *)error;



@end
