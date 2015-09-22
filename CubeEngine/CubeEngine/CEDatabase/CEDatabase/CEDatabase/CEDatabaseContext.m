//
//  CEDatabaseContext.m
//  CEDatabase
//
//  Created by chancezhang on 14-7-29.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <objc/runtime.h>

#import "CEDatabasePrivateCommon.h"
#import "CEDatabase.h"
#import "CEDatabaseContext.h"
#import "CEDatabase+Private.h"
#import "CEQueryCondition+Private.h"


#define BINDED_KEY_PREFIX @"_binded_object_id_"
#define IDENTIFIED_PROPERTY @"objectID"

#define ENABLE_DB_TRACE 0

#define kCEDatabaseRemoveTableInternalNotification @"kCEDatabaseRemoveTableInternalNotification"

@interface CEDatabaseContext () {
    __weak CEDatabase *_db;
    NSString *_sqliteTableName; // table name in sqlite database
    NSArray *_columnInfos;
    ColumnInfo *_customPrimaryColumn;
    NSDictionary *_transformedPropertyDict; // 与关键字有冲突的属性字典 @{原属性:转换后属性}
}

@end


@implementation CEDatabaseContext

/**
 创建一个数据库context。
 @param tableName 表名
 @param clazz 表数据结构，以Class中定义的property为表的列名
 @param database 数据库, 若数据库中无此表，则在数据库中创建一个新的表
 
 @return CEDatabaseContext实例
 */
+ (CEDatabaseContext *)contextWithTableName:(NSString *)tableName
                                       class:(Class)clazz
                                  inDatabase:(CEDatabase *)database {
    if (tableName.length && [clazz isSubclassOfClass:[CEManagedObject class]] && database) {
        return [[CEDatabaseContext alloc] initWithTableName:tableName class:clazz inDatabase:database];
        
    } else {
        return nil;
    }
}

- (id)initWithTableName:(NSString *)tableName class:(Class)clazz inDatabase:(CEDatabase *)database {
    CEDatabaseLog(@"%s", __FUNCTION__);
    if (self = [super init]) {
        if ([clazz isSubclassOfClass:[CEManagedObject class]]) {
            // 初始化基础信息
            _tableClass = clazz;
            _db = database;
            _tableName = tableName;
            _sqliteTableName = ConvertToSqliteTableName(tableName);
            
            // 初始化表
            [self initColumnInfos];
            [self checkTableVersion];
            [self initTable];
            _enable = (_columnInfos.count != 0);
            
            // add notification
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveTableNotification:) name:kCEDatabaseRemoveTableInternalNotification object:nil];
        
        } else {
            _enable = NO;
        }
        
    }
    return self;
}


- (void)dealloc {
    printf("%s - %s\n -%s", __FUNCTION__, [_db.name UTF8String], dispatch_queue_get_label(dispatch_get_current_queue()));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self closeContext];
}

#pragma mark - Init

// 初始化"列"信息
- (void)initColumnInfos {
    // 获取属性信息
    u_int count;
    objc_property_t* propertyArray = class_copyPropertyList(_tableClass, &count);
    NSMutableArray *columnInfos = [NSMutableArray arrayWithCapacity:count];
    NSMutableDictionary *transformedPropertyDict = [NSMutableDictionary dictionary];
    NSString *bindedProperty;
    for (int i = 0; i < count; i++) {
        ColumnInfo *info = [ColumnInfo new];
        /* 获取属性名称
         正常情况我们把Object的属性名称作为列名，即columnInfo.name == columnInfo.propertyName
         但如果属性名称与sqlite关键字有冲突，则在属性明后面添加"__"作为列名,
         这时columnInfo.name = @"XXX__", columnInfo.propertyName = "XXX"
         */
        const char* cPropertyName = property_getName(propertyArray[i]);
        NSString *propertyName = [NSString stringWithCString:cPropertyName encoding:NSUTF8StringEncoding];
        // 过滤以"_binded_object_id_"开头的属性
        if ([propertyName hasPrefix:BINDED_KEY_PREFIX]) {
            bindedProperty = [propertyName substringFromIndex:BINDED_KEY_PREFIX.length];
            continue;
        }
        
        info.propertyName = propertyName;
        if ([SqliteKeywords() containsObject:propertyName.uppercaseString]) {
            info.name = [propertyName stringByAppendingString:@"__"];
            // 记录冲突字段
            [transformedPropertyDict setObject:info.name forKey:propertyName];
            
        } else {
            info.name = propertyName;
        }
        
        // 获取属性信息 例:T@"NSString", N, V_propertyName -> NSString
        const char* attribute = property_getAttributes(propertyArray[i]);
        NSString *attributeString = [NSString stringWithCString:attribute encoding:NSUTF8StringEncoding];
        NSUInteger endIndex = [attributeString rangeOfString:@","].location;
        NSString *objcType = [attributeString substringWithRange:NSMakeRange(1, endIndex - 1)];
        if ([objcType hasPrefix:@"@"]) {// objc type
            objcType = [objcType substringWithRange:NSMakeRange(2, MAX(objcType.length - 3, 0))];
            if (!objcType) {
                CEDatabaseLog(@"CEDatabaseContext Error: unsupported property type");
                continue;
            }
            
        } else { // c type
            objcType = [objcType lowercaseString];
        }
        
        info.objcType = objcType;
        info.sqliteType = [ObjCToSqliteTypeDict() objectForKey:objcType];
        if (!info.sqliteType) {
            Class unknownClazz= NSClassFromString(objcType);
            if ([unknownClazz conformsToProtocol:@protocol(NSCoding)]) {
                info.sqliteType = @"BLOB";
                
            } else {
                CEDatabaseLog(@"skip unknown type: [%@] %@", info.objcType, info.name);
                continue;
            }
        }
        
        [columnInfos addObject:info];
    }
    if (transformedPropertyDict.count) {
        _transformedPropertyDict = transformedPropertyDict.copy;
    }
    
    // setup primary key
    for (ColumnInfo *column in columnInfos) {
        column.isPrimaryKey = [bindedProperty isEqualToString:column.propertyName];
        if (column.isPrimaryKey) {
            _customPrimaryColumn = column;
        }
    }
    
    _columnInfos = columnInfos;
    free(propertyArray);
}

// 初始化表
- (void)initTable {
    if (!_db || !_columnInfos.count) {
        CEDatabaseLog(@"CEDatabaseContext Error: no column infos");
        return;
    }
    
    [_db safeSyncExecute:^{
        if ([_db.fmdb tableExists:_sqliteTableName]) {
            // !!!: 处理表版本变更
            return;
        }
        // create new table
        NSMutableString *createTableCmd = [NSMutableString stringWithFormat:@"CREATE TABLE %@ (", _sqliteTableName];
        for (ColumnInfo *column in _columnInfos) {
            [createTableCmd appendFormat:@"%@ %@", column.name, column.sqliteType];
            if (column.isPrimaryKey) {
                [createTableCmd appendString:@" PRIMARY KEY NOT NULL, "];
                
            } else {
                [createTableCmd appendString:@", "];
            }
        }
        [createTableCmd replaceCharactersInRange:NSMakeRange(createTableCmd.length - 2, 2) withString:@")"];
        if(![_db.fmdb executeUpdate:createTableCmd]) {
            CEDatabaseLog(@"CEDatabaseContext Error: create table fail");
        }
    } error:nil];
}


- (void)checkTableVersion {
    [_db safeSyncExecute:^{
        // get current table info
        FMResultSet *resultSet = nil;
        NSString *tableInfoCmd = [NSString stringWithFormat:@"PRAGMA TABLE_INFO(%@)", _sqliteTableName];
        resultSet = [_db.fmdb executeQuery:tableInfoCmd];
        
        if (!resultSet) {
            return;
        }
        
        NSMutableArray *localColumns = [NSMutableArray arrayWithCapacity:resultSet.columnCount];
        while ([resultSet next]) {
            /**
             cid         name        type        notnull     dflt_value  pk
             ----------  ----------  ----------  ----------  ----------  ----------
             0           id          integer     99                      1
             1           name                    0                       0
             */
            ColumnInfo *columnInfo = [ColumnInfo new];
            columnInfo.name = [resultSet stringForColumn:@"name"];
            columnInfo.sqliteType = [resultSet stringForColumn:@"type"];
            columnInfo.isPrimaryKey = [resultSet boolForColumn:@"pk"];
            [localColumns addObject:columnInfo];
        }
        
        NSMutableArray *newColumns = [NSMutableArray arrayWithArray:_columnInfos];
        // ?: any quick way to check different ?
        BOOL hasChange = (localColumns.count != newColumns.count);
        if (!hasChange) {
            for (ColumnInfo *newInfo in newColumns) {
                BOOL findColumn = NO;
                for (ColumnInfo *oldInfo in localColumns) {
                    if ([oldInfo.name isEqualToString:newInfo.name] &&
                        [oldInfo.sqliteType isEqualToString:newInfo.sqliteType] &&
                        oldInfo.isPrimaryKey == newInfo.isPrimaryKey) {
                        findColumn = YES;
                        break;
                    }
                }
                if (!findColumn) {
                    hasChange = YES;
                    break;
                }
            }
        }
        
        // 有变化是删除当前表
        if (hasChange) {
            NSError *error;
            [CEDatabaseContext internalRemoveTable:self.tableName fromDB:_db error:&error];
            if (error) {
                CEDatabaseLog(@"Remove Table Error: %@", error);
            } else {
                CEDatabaseLog(@"Remove table: %@", _sqliteTableName);
            }
        }
        
    } error:nil];
}




#pragma mark - Query
/** 查找所有 */
- (NSArray *)queryAllWithError:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return nil;
    }
    
    NSMutableArray *resultList = [NSMutableArray array];
    [_db safeSyncExecute:^{
        NSString *queryAllCmd = [NSString stringWithFormat: @"SELECT rowid,* FROM %@", _sqliteTableName];
        FMResultSet *resultSet = [_db.fmdb executeQuery:queryAllCmd];
        while ([resultSet next]) {
            id object = [_tableClass new];
            [self updateValueForObject:object fromResult:resultSet];
            [resultList addObject:object];
        }
        [resultSet close];
    } error:error];
    return resultList.count != 0 ? resultList : nil;
}


/** 根据ID值查找，若没手动设置id，则会按默认id值查找
 @param idValue id值，CEDatabaseObject子类可通过函数
 */
- (CEManagedObject *)queryById:(id)idValue error:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return nil;
    }
    
    NSMutableArray *resultList = [NSMutableArray array];
    [_db safeSyncExecute:^{
        NSMutableString *queryByIdCmd = [NSMutableString stringWithFormat: @"SELECT rowid,* FROM %@", _sqliteTableName];
        NSString *primaryKey = _customPrimaryColumn ? _customPrimaryColumn.name : @"rowid";
        [queryByIdCmd appendFormat:@" WHERE %@ = ?", primaryKey];
        
        FMResultSet *resultSet = [_db.fmdb executeQuery:queryByIdCmd, idValue];
        while ([resultSet next]) {
            id object = [_tableClass new];
            [self updateValueForObject:object fromResult:resultSet];
            [resultList addObject:object];
        }
        [resultSet close];
    } error:error];
    
    return resultList.count != 0 ? resultList[0] : nil;
}


/** 条件查找，提供最全面的查询条件设置 */
- (NSArray *)queryByCondition:(CEQueryCondition *)condition
                        error:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return nil;
    }
    if (![self checkQueryCondition:condition error:error])  {
        return nil;
    };
    
    NSMutableArray *resultList = [NSMutableArray array];
    [_db safeSyncExecute:^{
        NSMutableString *cmd = [NSMutableString stringWithFormat:@"SELECT rowid,* FROM %@", _sqliteTableName];
        __block NSString *conditionCmd = [condition getCmd];
        if (conditionCmd) {
            // 检查是否有冲突属性需要转换
            if (_transformedPropertyDict.count) {
                [_transformedPropertyDict enumerateKeysAndObjectsUsingBlock:
                 ^(NSString *property, NSString *columnName, BOOL *stop) {
                    conditionCmd = [conditionCmd stringByReplacingOccurrencesOfString:property
                                                                           withString:columnName];
                }];
            }
            [cmd appendFormat:@" %@", conditionCmd];
        }
        
        NSDictionary *arguments = [condition getArgumentDict];
        FMResultSet *resultSet = [_db.fmdb executeQuery:cmd withParameterDictionary:arguments];
        
        while ([resultSet next]) {
            id object = [_tableClass new];
            [self updateValueForObject:object fromResult:resultSet];
            [resultList addObject:object];
        }
        [resultSet close];
    } error:error];
    
    return resultList.count != 0 ? resultList : nil;
}


// 把从result中提取值填入object中
- (void)updateValueForObject:(id)object fromResult:(FMResultSet *)resultSet {
    if (![object isKindOfClass:_tableClass]) return;
    
    BOOL hasSetPrimaryKey = NO;
    for (ColumnInfo *column in _columnInfos) {
        id value = [resultSet objectForColumnName:column.name];
        value = (value != [NSNull null] ? value : nil); // 去掉NSNull
        if (value && [column.sqliteType isEqualToString:@"BLOB"] &&
            ![column.objcType isEqualToString:@"NSData"] &&
            ![column.objcType isEqualToString:@"NSMutableData"]) {
            // 对NSData外的其他对象转换成NSData
            value = [NSKeyedUnarchiver unarchiveObjectWithData:value];
        }
        
        if (value) {
            [object setValue:value forKey:column.propertyName];
            if (column.isPrimaryKey) {
                [object setValue:value forKey:IDENTIFIED_PROPERTY];
                hasSetPrimaryKey = YES;
            }
        }
    }
    
    if (!hasSetPrimaryKey) {
        NSNumber *rowID = [resultSet objectForColumnName:@"rowid"];
        if (rowID) {
            [object setValue:rowID forKey:IDENTIFIED_PROPERTY];
        }
    }
}


#pragma mark - Insert

- (BOOL)insert:(CEManagedObject *)object error:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return NO;
    }
    
    __block BOOL success = NO;
    [_db safeSyncExecute:^{
        success = [self executeInsert:object error:error];
    } error:error];
    return success;
}


- (BOOL)insertObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return NO;
    }
    
    if (!objects.count) {
        return YES;
    }
    __block BOOL success = NO;
    [_db safeSyncExecute:^{
        [_db.fmdb beginTransaction];
        for (id object in objects) {
            success = [self executeInsert:object error:error];
            if (!success) {
                break;
            }
        }
        if (success) {
            [_db.fmdb commit];
            
        } else {
            [_db.fmdb rollback];
        }
    } error:error];
    return success;
}


// 执行插入操作
- (BOOL)executeInsert:(CEManagedObject *)object error:(NSError * __autoreleasing *)error {
    // 检查对象
    if (![self checkObject:object containID:NO error:error]) {
        return NO;
    }
    
    // generate insert cmd
    NSMutableString *insertCmd = [NSMutableString stringWithFormat:@"INSERT INTO %@ VALUES (", _sqliteTableName];
    for (ColumnInfo *column in _columnInfos) {
        [insertCmd appendFormat:@":%@, ", column.name];
    }
    [insertCmd replaceCharactersInRange:NSMakeRange(insertCmd.length - 2, 2) withString:@")"];
    
    // execute command
    NSDictionary *valueDict = [self sqliteValueDictionary:object];
    if (![_db.fmdb executeUpdate:insertCmd withParameterDictionary:valueDict]) {
//        CEDatabaseLog(@"CEDatabaseContext Error: insert object fail ErrorInfo:%@", _db.fmdb.lastErrorMessage);
        if(error) {
            *error = [_db.fmdb lastError];
        }
        return NO;
    }
    // 对objectID进行赋值
    if (_customPrimaryColumn) {
        // 把绑定的property值赋到objectID中
        id bindedValue = [object valueForKey:_customPrimaryColumn.propertyName];
        [object setValue:bindedValue forKey:IDENTIFIED_PROPERTY];
        
    } else {
        // 使用默认id，获取最大的rowid，赋值到obj中
        NSString *getMaxRowIdCmd = [NSString stringWithFormat:@"SELECT MAX(rowid) FROM %@", _sqliteTableName];
        long rowId = [_db.fmdb longForQuery:getMaxRowIdCmd];
        [object setValue:@(rowId) forKey:IDENTIFIED_PROPERTY];
    }
    
    return YES;
}


// 获取sqlite值字典
- (NSMutableDictionary *)sqliteValueDictionary:(id)object {
    NSMutableDictionary *valueDict = [NSMutableDictionary dictionaryWithCapacity:_columnInfos.count];
    for (ColumnInfo *column in _columnInfos) {
        id value = [object valueForKey:column.propertyName];
        if (value && [column.sqliteType isEqualToString:@"BLOB"] &&
            ![column.objcType isEqualToString:@"NSData"] &&
            ![column.objcType isEqualToString:@"NSMutableData"]) {
            // 对NSData外的其他对象转换成NSData
            value = [NSKeyedArchiver archivedDataWithRootObject:value];
        }
        [valueDict setObject:value ? value : [NSNull null] forKey:column.name];
    }
    
    return valueDict;
}


#pragma mark - Update
/** 更新单个数据*/
- (BOOL)update:(CEManagedObject *)object error:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return NO;
    }
    
    __block BOOL success = NO;
    [_db safeSyncExecute:^{
        success = [self executeUpdate:object error:error];
    } error:error];
    
    return success;
}

/** 更新多个数据 */
- (BOOL)updateObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return NO;
    }
    
    if (!objects.count) {
        return YES;
    }
    __block BOOL success = NO;
    [_db safeSyncExecute:^{
        [_db.fmdb beginTransaction];
        for (id object in objects) {
            success = [self executeUpdate:object error:error];
            if (!success) {
                break;
            }
        }
        if (success) {
            [_db.fmdb commit];
            
        } else {
            [_db.fmdb rollback];
        }
    } error:error];
    return success;
}

// execute update
- (BOOL)executeUpdate:(CEManagedObject *)object error:(NSError * __autoreleasing *)error {
    // 检查对象
    if (![self checkObject:object containID:YES error:error]) {
        return NO;
    }
    
    // generate update cmd
    NSMutableString *updateCmd = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", _sqliteTableName];
    for (ColumnInfo *column in _columnInfos) {
        [updateCmd appendFormat:@"%@ = :%@", column.name, column.name];
        if (column != _columnInfos.lastObject) {
            [updateCmd appendString:@", "];
        }
    }
    NSString *primaryKey = _customPrimaryColumn ? _customPrimaryColumn.name : @"rowid";
    [updateCmd appendFormat:@" WHERE %@ = :___where_key___", primaryKey];
    NSMutableDictionary *valueDict = [self sqliteValueDictionary:object];
    valueDict[@"___where_key___"] = object.objectID ? object.objectID : [NSNull null];
    
    // execute
    if(![_db.fmdb executeUpdate:updateCmd withParameterDictionary:valueDict]) {
        CEDatabaseLog(@"CEDatabaseContext Error: update object fail!");
        return NO;
    }
    return YES;
}


#pragma mark - Delete
/**
 删除单个数据
 */
- (BOOL)remove:(CEManagedObject *)object error:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return NO;
    }
    
    __block BOOL success = NO;
    [_db safeSyncExecute:^{
        success = [self executeRemove:object error:error];
    } error:error];
    
    return success;
}


/**
 删除多个数据
 */
- (BOOL)removeObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return NO;
    }
    
    if (!objects.count) {
        return YES;
    }
    __block BOOL success = NO;
    [_db safeSyncExecute:^{
        [_db.fmdb beginTransaction];
        for (id object in objects) {
            success = [self executeRemove:object error:error];
            if (!success) {
                break;
            }
        }
        if (success) {
            [_db.fmdb commit];
            
        } else {
            [_db.fmdb rollback];
        }
    } error:error];
    return success;
}

- (BOOL)executeRemove:(CEManagedObject *)object error:(NSError * __autoreleasing *)error {
    // 检查对象
    if (![self checkObject:object containID:YES error:error]) {
        return NO;
    }
    
    // generate delete cmd
    NSMutableString *deleteCmd = [NSMutableString stringWithFormat:@"DELETE FROM %@", _sqliteTableName];
    NSString *primaryKey = _customPrimaryColumn ? _customPrimaryColumn.name : @"rowid";
    [deleteCmd appendFormat:@" WHERE %@ = ?", primaryKey];
    
    // execute
    if (![_db.fmdb executeUpdate:deleteCmd, object.objectID]) {
        CEDatabaseLog(@"CEDatabaseContext Error: Delete object fail!");
        return NO;
    }
    return YES;
}


/**
 删除所有数据
 */
- (BOOL)removeAllObjectsWithError:(NSError *__autoreleasing *)error {
    if (![self checkContextWithError:error]) {
        return NO;
    }
    
    __block BOOL success = NO;
    [_db safeSyncExecute:^{
        NSString *deleteCmd = [NSString stringWithFormat:@"DELETE FROM %@", _sqliteTableName];
        if (![_db.fmdb executeUpdate:deleteCmd]) {
            CEDatabaseLog(@"CEDatabaseContext Error: Delete all object fail!");
            success = NO;
        }
    } error:error];
    return success;
}

/**
 删除数据库表
 
 删除前发出通知:CEDatabaseRemoveTableNotification
 
 如果相关联的CEDatabaseContext没有被销毁，则该Context会变成无效状态，这时候任何的数据库操作都会返回失败。
 */
+ (BOOL)removeTable:(NSString *)tableName fromDatabase:(CEDatabase *)database error:(NSError * __autoreleasing *)error {
#warning check if table exist
    
    __block BOOL isOK = NO;
    [database safeSyncExecute:^{
        isOK = [CEDatabaseContext internalRemoveTable:tableName fromDB:database error:error];
        if (isOK) {
            NSDictionary *userInfo = @{CEDatabaseTableNameKey : tableName};
            // 内部通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kCEDatabaseRemoveTableInternalNotification
                                                                object:nil
                                                              userInfo:userInfo];
            // 外部通知
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CEDatabaseRemoveTableNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            });
        }
    } error:error];
    
    return isOK;
}


//
+ (BOOL)internalRemoveTable:(NSString *)tableName fromDB:(CEDatabase *)db error:(NSError *__autoreleasing *)error {
    // 删除表
    __block BOOL success = NO;
    [db safeSyncExecute:^{
        NSString *sqliteTableName = ConvertToSqliteTableName(tableName);
        NSString *dropTableCmd = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", sqliteTableName];
        success = [db.fmdb executeUpdate:dropTableCmd];
    } error:error];
    
    if (!success && error) {
        *error = [db.fmdb lastError];
    }
    return success;
}


#pragma mark - CEDatabase Notificatons
// 数据库表格即将被删除
- (void)onRemoveTableNotification:(NSNotification *)notification {
    CEDatabaseLog(@"%s - %@", __FUNCTION__, notification.userInfo[CEDatabaseTableNameKey]);
    
    NSString *tableName = notification.userInfo[CEDatabaseTableNameKey];
    if ([tableName isEqualToString:_sqliteTableName]) {
        [self closeContext];
    }
}

// 数据库即将被删除
- (void)onDatabaseClosedNotification:(NSNotification *)notification {
    CEDatabaseLog(@"%s - %@", __FUNCTION__, notification.userInfo[CEDatabaseNameKey]);
    
    NSString *dbName = notification.userInfo[CEDatabaseNameKey];
    if ([_db.name isEqualToString:dbName]) {
        [self closeContext];
    }
}


// 关闭Context
- (void)closeContext {
    _enable = NO;
    _db = nil;
}

#pragma mark - Others


//+ (void)safeSyncExecute:(void (^)(void))block inDB:(CEDatabase *)db error:(NSError *__autoreleasing *)error {
//    // get db queue
//    dispatch_queue_t queue = db.fmdbQueue;
//    if (!queue) {
//        if (error) {
//            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Method safeSyncExecute fail: get null queue"};
//            *error = [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
//        }
//        return;
//    };
//    
//    // check current queue to prevent dispatch_sync dead lock
//    if ([db isInFmdbQueue]) {
//        block();
//        
//    } else {
//        dispatch_retain(queue);
//        dispatch_sync(queue, ^{
//            block();
//        });
//        dispatch_release(queue);
//    }
//}


#pragma mark - Error Check
// 检查Context
- (BOOL)checkContextWithError:(NSError *__autoreleasing *)error {
    if (!_enable || !_columnInfos) { // Context不可用
        if (error) {
            if (!_columnInfos.count) { // 无效的列信息
                NSString *desc = [NSString stringWithFormat:@"Context has invalided column infos for class %@", [_tableClass description]];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
                *error = [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
                
            } else {// 数据库已经关闭
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Database is not available."};
                *error = [NSError errorWithDomain:CEDatabaseDomain code:-1 userInfo:userInfo];
            }
        }
        return NO;
    }
    if (!_db || _db.isClosed) { // 数据库不可用
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Database is not available."};
            *error = [NSError errorWithDomain:CEDatabaseDomain code:-1 userInfo:userInfo];
        }
        return NO;
    }
    
    return YES;
}

// 检查对象
- (BOOL)checkObject:(CEManagedObject *)object
          containID:(BOOL)containID
              error:(NSError *__autoreleasing *)error
{
    if (![object isKindOfClass:_tableClass]) { // 错误的类型
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Invalided object: Class Type is wrong."};
            *error = [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
        }
        return NO;
    }
    
    if (containID && !object.objectID){ // 无效的ObjectID
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"ObjectID is null"};
            *error = [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkQueryCondition:(CEQueryCondition *)condition error:(NSError *__autoreleasing *)error {
    if (!condition) {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Invalided query condition"};
            *error = [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
        }
        return NO;
    }
    return YES;
}

//
//- (NSError *)databaseNotAvailableError {
//    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Database is not available."};
//    return [NSError errorWithDomain:CEDatabaseDomain code:-1 userInfo:userInfo];
//}

//
//- (NSError *)contextNotAvailableError {
//    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Context is not available."};
//    return [NSError errorWithDomain:CEDatabaseDomain code:-1 userInfo:userInfo];
//}

//// 错误的类型
//- (NSError *)wrongObjectClassError {
//    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Invalided object: Class Type is wrong."};
//    return [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
//}

//// 无效的列信息
//- (NSError *)invalidedColumnInfoError {
//    NSString *desc = [NSString stringWithFormat:@"Context has invalided column infos for class %@", [_tableClass description]];
//    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
//    return [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
//}

//// 错误的查询条件
//- (NSError *)invalidedQueryConditionError {
//    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Invalided query condition"};
//    return [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
//}

//// 无效的ObjectID
//- (NSError *)invalidedObjectIDError {
//    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"ObjectID is null"};
//    return [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
//}



@end



