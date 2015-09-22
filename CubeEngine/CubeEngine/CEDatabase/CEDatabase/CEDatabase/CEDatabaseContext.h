//
//  CEDatabaseContext.h
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-7-29.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEDatabase.h"
#import "CEQueryCondition.h"
#import "CEManagedObject.h"
#import "CEDatabaseNotifications.h"


/**
 数据库Context
 
 CEDatabaseContext代表一个数据库表，是数据库操作的入口，实现了数据对象的添加，更新，查询，删除等基本操作。
 
 CEDatabaseContext是线程安全的，可以在不同线程之间传递使用。
 */

@interface CEDatabaseContext : NSObject

/** 表名 */
@property (nonatomic, readonly) NSString *tableName;

/** 数据库表对应的类 */
@property (nonatomic, readonly) Class tableClass;

/** Context 是否可用 */
@property (nonatomic, readonly, getter = isEnabled) BOOL enable;


/**
 创建一个数据库context。
 @param tableName 表名
 @param clazz 表数据结构，以Class中定义的property为表的列名
 @param database 数据库, 若数据库中无此表，则在数据库中创建一个新的表
 
 @return CEDatabaseContext实例
 */
+ (CEDatabaseContext *)contextWithTableName:(NSString *)tableName
                                       class:(Class)clazz
                                  inDatabase:(CEDatabase *)database;

/**
 创建一个数据库context。
 @param clazz 表数据结构，以Class中定义的property为元数据
 @param database 数据库, 若数据库中无此表，则在数据库中创建一个新的表s
 
 @return CEDatabaseContext实例
 */
- (id)initWithTableName:(NSString *)tableName class:(Class)clazz inDatabase:(CEDatabase *)database;


/** 查找所有 
 @return Context所在的表中的所有数据, 无数据时返回nil
 */
- (NSArray *)queryAllWithError:(NSError * __autoreleasing *)error;

/** 
 根据objectID查找，若没绑定objectID，则会按自动分配的objectID查找
 @param idValue objectID值，CEDatabaseObject子类可通过函数BIND_OBJECT_ID()绑定objectID
 
 @return 指定objectID的数据, 找不到时返回nil
 */
- (CEManagedObject *)queryById:(id)idValue error:(NSError * __autoreleasing *)error;

/** 
 条件查找，提供最全面的查询条件设置
 
 @param condition 查询条件
 @see CEQueryCondition
 
 @return 指定条件的数据列表, 找不到时返回nil
 */
- (NSArray *)queryByCondition:(CEQueryCondition *)condition
                        error:(NSError * __autoreleasing *)error;


/** 
 插入单个数据
 
 若插入数据已经存在数据库中，则返回失败
 
 @param object 要插入的数据，其类型必须与tableClass相同
 @return YES：操作成功  NO：操作失败
 */
- (BOOL)insert:(CEManagedObject *)object error:(NSError * __autoreleasing *)error;

/** 
 插入多个数据
 
 插入过程中有一个object失败，则数据库会回滚到插入之前的状态
 
 @param objects 数据列表，列表中的数据类型必须与tableClass相同
 @return YES：操作成功  NO：操作失败
 */
- (BOOL)insertObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error;


/** 
 更新单个数据
 
 若更新的数据不存在（objectID无法匹配），则返回失败
 
 @param object 要更新的数据，其类型必须与tableClass相同
 @return YES：操作成功  NO：操作失败
 */
- (BOOL)update:(CEManagedObject *)object error:(NSError * __autoreleasing *)error;

/** 
 更新多个数据
 
 若更新过程中有一个object失败，则数据库会回滚到更新之前的状态
 
 @param objects 数据列表，列表中的数据类型必须与tableClass相同
 @return YES：操作成功  NO：操作失败
 */
- (BOOL)updateObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error;


/** 
 删除单个数据
 
 若删除的数据的objectID无法匹配，则返回失败
 
 @param object 要删除的数据，其类型必须与tableClass相同
 @return YES：操作成功  NO：操作失败
 */
- (BOOL)remove:(CEManagedObject *)object error:(NSError * __autoreleasing *)error;

/**
 删除多个数据
 
 若删除过程中有一个object删除失败，则数据库会回滚到删除之前的状态
 
 @param objects 数据列表，列表中的数据类型必须与tableClass相同
 @return YES：操作成功  NO：操作失败
 */
- (BOOL)removeObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error;

/**
 删除所有数据
 
 @return YES：操作成功  NO：操作失败
 */
- (BOOL)removeAllObjectsWithError:(NSError * __autoreleasing *)error;


/**
 删除数据库表
 
 删除前发出通知:CEDatabaseRemoveTableNotification
 
 如果相关联的CEDatabaseContext没有被销毁，则该Context会变成无效状态，这时候任何的数据库操作都会返回失败。
 
 */
+ (BOOL)removeTable:(NSString *)tableName fromDatabase:(CEDatabase *)database error:(NSError * __autoreleasing *)error;


@end



