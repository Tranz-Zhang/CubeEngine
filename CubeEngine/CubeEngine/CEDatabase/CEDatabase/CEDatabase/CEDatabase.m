//
//  CEDatabase.m
//  CEDatabase
//
//  Created by chancezhang on 14-7-29.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import "CEDatabase.h"
#import "CEDatabasePrivateCommon.h"
#import "CEDatabase+Private.h"
#import "FMDatabase.h"

// 数据库删除通知
#define kCEDatabaseWillRemoveDBFileNotification @"kCEDatabaseWillRemoveDBFileNotification"

#define kDefaultDatabaseDirectory @"syb_database"

static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

/**
 用于记录fmdb实例以及其对应的dispatch queue，同时记录对数据库的引用者地址字符串
 */
@interface AsyncDBInfo : NSObject

@property (nonatomic, strong) FMDatabase *fmDatabase;
@property (nonatomic, assign) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) NSMutableSet *refrences;

@end

@implementation AsyncDBInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _refrences = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc
{
    if (self.dispatchQueue) {
//        dispatch_release(self.dispatchQueue);
        self.dispatchQueue = nil;
        
        CEDatabaseLog(@"AsyncDBInfo: Delete Queue");
    }
}

@end


static __strong NSMutableDictionary *_asyncDBInfoDict;

@implementation CEDatabase

+ (CEDatabase *)databaseWithName:(NSString *)databaseName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *defaultFilePath = [[paths lastObject] stringByAppendingPathComponent:kDefaultDatabaseDirectory];
    return [CEDatabase databaseWithName:databaseName inPath:defaultFilePath];
}

+ (CEDatabase *)databaseWithName:(NSString *)databaseName inPath:(NSString *)path {
    return [[CEDatabase alloc] initWithName:databaseName inPath:path];
}

- (id)initWithName:(NSString *)databaseName inPath:(NSString *)path {
    CEDatabaseLog(@"%s", __FUNCTION__);
    if (self = [super init]) {
        _name = databaseName;
        _enable = [self checkDatabaseDirectory:path];
        NSString *dbName = [databaseName stringByAppendingString:@".db"];
        _filePath = [path stringByAppendingPathComponent:dbName];
        
        if (!_asyncDBInfoDict) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                _asyncDBInfoDict = [NSMutableDictionary dictionary];
            });
        }
        @synchronized(_asyncDBInfoDict) {
            AsyncDBInfo *dbInfo = _asyncDBInfoDict[databaseName];
            if (!dbInfo) {
                /*
                 创建数据库信息以及数据库队列
                 相同名称的数据共享同一个AsyncDBInfo
                 */
                dbInfo = [AsyncDBInfo new];
                // create dispatch queue
                dispatch_queue_t queue = dispatch_queue_create([self.name UTF8String], DISPATCH_QUEUE_SERIAL);
                dispatch_queue_set_specific(queue, kDispatchQueueSpecificKey, (__bridge void *)dbInfo, NULL);
                
                dbInfo.dispatchQueue = queue;
                [_asyncDBInfoDict setObject:dbInfo forKey:databaseName];
                
                CEDatabaseLog(@"CEDatabase: new dbInfo");
            }
            NSString *refAddress = [NSString stringWithFormat:@"%p", self];
            [dbInfo.refrences addObject:refAddress];
        }
        
        // add db removed notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDatabaseRemovedNotification:) name:kCEDatabaseWillRemoveDBFileNotification object:nil];
    }
    return self;
}


- (void)dealloc {
    CEDatabaseLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // close db notification
    if (_enable) {
        [self postDatabaseCloseNotification];
    }
    
    @synchronized(_asyncDBInfoDict) {
        AsyncDBInfo *dbInfo = _asyncDBInfoDict[_name];
        if (dbInfo) {
            NSString *refAddress = [NSString stringWithFormat:@"%p", self];
            [dbInfo.refrences removeObject:refAddress];
            if (!dbInfo.refrences.count) {
                // close fmdb
                [_asyncDBInfoDict removeObjectForKey:_name];
                CEDatabaseLog(@"CEDatabase: remove dbInfo");
            }
        }
    }
}


- (void)onDatabaseRemovedNotification:(NSNotification *)notification {
    CEDatabaseLog(@"%s", __FUNCTION__);
    NSString *dbName = notification.userInfo[CEDatabaseNameKey];
    if ([dbName isEqualToString:_name] && _enable) {
        [self postDatabaseCloseNotification];
        _enable = NO;
    }
}

// post two close notification
- (void)postDatabaseCloseNotification {
    NSDictionary *userInfo = @{CEDatabaseNameKey : _name};
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CEDatabaseClosedNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

/*
// 删除表
- (BOOL)removeTableForClass:(Class)clazz error:(NSError * __autoreleasing *)error {
    AsyncDBInfo *dbInfo = _asyncDBInfoDict[_name];
    if (!dbInfo.fmDatabase) {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Database is closed or not available!"};
            *error = [NSError errorWithDomain:CEDatabaseDomain  code:-1 userInfo:userInfo];
        }
        return NO;
    }
    
    // 发出通知
    NSDictionary *userInfo = @{CEDatabaseTableNameKey : [clazz description]};
    [[NSNotificationCenter defaultCenter] postNotificationName:CEDatabaseRemoveTableNotification
                                                        object:nil
                                                      userInfo:userInfo];
    // 删除表
    __block BOOL success = NO;
    dispatch_sync(self.fmdbQueue, ^{
        NSString *dropTableCmd = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", [clazz description]];
        success = [self.fmdb executeUpdate:dropTableCmd];
    });
    
    if (!success && !error) {
        *error = [self.fmdb lastError];
    }
    
    return success;
}
//*/


/** 数据库即将关闭 */
+ (BOOL)removeDatabase:(NSString *)databaseName error:(NSError * __autoreleasing *)error {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *defaultFilePath = [[paths lastObject] stringByAppendingPathComponent:kDefaultDatabaseDirectory];
    return [CEDatabase removeDatabase:databaseName inPath:defaultFilePath error:error];
}

+ (BOOL)removeDatabase:(NSString *)databaseName inPath:(NSString *)path error:(NSError * __autoreleasing *)error {
    if (!databaseName.length || !path.length) {
        return NO;
    }
    
    AsyncDBInfo *dbInfo;
    @synchronized(_asyncDBInfoDict) {
        dbInfo = _asyncDBInfoDict[databaseName];
    }
    
    if (!dbInfo) {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Database is closed or not available!"};
            *error = [NSError errorWithDomain:CEDatabaseDomain  code:-1 userInfo:userInfo];
        }
        return NO;
    }
    
    dispatch_sync(dbInfo.dispatchQueue, ^{
        // 发出通知
        NSDictionary *userInfo = @{CEDatabaseNameKey : databaseName};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCEDatabaseWillRemoveDBFileNotification
                                                            object:nil
                                                          userInfo:userInfo];
        // 删除db信息
        @synchronized(_asyncDBInfoDict) {
            [_asyncDBInfoDict removeObjectForKey:databaseName];
        }
    });
    
    // 删除db文件
    NSString *dbName = [databaseName stringByAppendingString:@".db"];
    NSString *filePath = [path stringByAppendingPathComponent:dbName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *fileDeleteError;
        if (![fileManager removeItemAtPath:filePath error:&fileDeleteError]) {
            if (error) {
                *error = fileDeleteError;
            }
            return NO;
        }
    }
    return YES;
}

#pragma mark - Category Private Methods

- (FMDatabase *)fmdb {
    AsyncDBInfo *dbInfo;
    @synchronized(_asyncDBInfoDict) {
        dbInfo = _asyncDBInfoDict[_name];
    }
    if (!_enable || !dbInfo) return nil;
    
    // 线程检查
    AsyncDBInfo *dbInfoForQueue = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
    if (dbInfo != dbInfoForQueue) {
        CEDatabaseLog(@"CEDatabase: Wrong Thread to call fmdb");
        return nil;
    }
    
    if (!dbInfo.fmDatabase) {
        if (!dbInfo.fmDatabase){
            dbInfo.fmDatabase = [self createFMDB];
            CEDatabaseLog(@"---------------------- Create FMDB");
        }
    }
    
    return dbInfo.fmDatabase;
}


- (FMDatabase *)createFMDB {
    if (!_filePath) {
        return nil;
    }
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *dbName = [_name stringByAppendingString:@".db"];
//    _filePath = [[paths lastObject] stringByAppendingPathComponent:dbName];
    FMDatabase *fmdb = [FMDatabase databaseWithPath:_filePath];
    if (![fmdb open]) {
        CEDatabaseLog(@"ERROR: Could not open database.");
        return nil;
    }
    return fmdb;
}

- (BOOL)checkDatabaseDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error;
        BOOL isOK = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!isOK) {
            CEDatabaseLog(@"Create File Fail: %@", error);
        }
        return isOK;
    }
    return YES;
}


// 获取FMDatabase所对应的dispatch queue
- (dispatch_queue_t)fmdbQueue {
    if (!_enable) return nil;
    
    AsyncDBInfo *dbInfo;
    @synchronized(_asyncDBInfoDict) {
        dbInfo = _asyncDBInfoDict[_name];
    }
    return dbInfo.dispatchQueue;
}

// 数据库是否可用
- (BOOL)isClosed {
    AsyncDBInfo *dbInfo;
    @synchronized(_asyncDBInfoDict) {
        dbInfo = _asyncDBInfoDict[_name];
    }
    return !_enable || !dbInfo;
}

// 当前的调用线程是否为db线程
- (BOOL)isInFmdbQueue {
    AsyncDBInfo *dbInfo;
    @synchronized(_asyncDBInfoDict) {
        dbInfo = _asyncDBInfoDict[_name];
    }
    if (!dbInfo) return NO;
    
    // 线程检查
    AsyncDBInfo *dbInfoForQueue = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
    return dbInfo == dbInfoForQueue;
}


// 线程同步执行
- (BOOL)safeSyncExecute:(void (^)(void))block error:(NSError *__autoreleasing *)error {
    dispatch_queue_t queue = self.fmdbQueue;
    if (!queue) {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Method safeSyncExecute fail: get null queue"};
            *error = [NSError errorWithDomain:CEDatabaseContextDomain code:-1 userInfo:userInfo];
        }
        return NO;
    };
    
    // check current queue to prevent dispatch_sync dead lock
    if ([self isInFmdbQueue]) {
        block();
        
    } else {
//        dispatch_retain(queue);
        dispatch_sync(queue, ^{
            block();
        });
//        dispatch_release(queue);
    }
    return YES;
}

@end




