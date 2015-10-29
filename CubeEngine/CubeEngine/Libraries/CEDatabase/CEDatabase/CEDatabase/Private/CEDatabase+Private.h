//
//  CEDatabase+Private.h
//  CEDatabase
//
//  Created by chancezhang on 14-7-30.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import "CEDatabase.h"
#import "FMDB.h"


/**
 CEDatabase私有方法，数据库使用者不需要知道这些接口
 */

@interface CEDatabase (Private)

// 获取FMDB数据库实例
- (FMDatabase *)fmdb;

// 获取FMDatabase所对应的dispatch queue
- (dispatch_queue_t)fmdbQueue;

// 数据库是否可用
- (BOOL)isClosed;

//// 当前的调用线程是否为db线程
//- (BOOL)isInFmdbQueue;


// this method make sure that block always execute in fmdbQueue
- (BOOL)safeSyncExecute:(void (^)(void))block error:(NSError *__autoreleasing *)error;

@end





