//
//  TestAsync.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-6.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CEDatabase+Private.h"

@interface TestAsync : XCTestCase {
    CEDatabase *_db;
    CEDatabase *_db2;
}

@end

@implementation TestAsync

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestAsync"];
    _db2 = [CEDatabase databaseWithName:@"TestAsync2"];
}

- (void)tearDown
{
    [super tearDown];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"syb_database"];
    [[NSFileManager defaultManager] removeItemAtPath:directory error:nil];
}


// 由于运行环境不稳定，这个异步测试有可能失败，如果失败概率比较高，则可判定为测试失败。
- (void)testAsyncReadWriteDifferentTable {
    CEDatabaseContext *context1 = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    CEDatabaseContext *context2 = [CEDatabaseContext contextWithTableName:[[DefaultKeyObject class] description] class:[DefaultKeyObject class] inDatabase:_db];
    
    XCTAssertEqual([context1 queryAllWithError:nil].count, 0);
    XCTAssertEqual([context2 queryAllWithError:nil].count, 0);
    
    //------------------------------- context 1 --------------------------------
    // insert 100
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context1: insert 100");
        for (int i = 0; i < 100; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context1 insert:obj error:nil]);
//            NSLog(@"Insert %@", obj.value);
        }
    });
    
    // update 0 -49 and insert more 50
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context1: update 0 -49 and insert more 50");
        NSArray *result = [context1 queryAllWithError:nil];
        for (CustomKeyObject *obj in result) {
            obj.num = arc4random() % 100000;
        }
        XCTAssert([context1 updateObjects:result error:nil]);
        
        for (int i = 100; i < 150; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context1 insert:obj error:nil]);
        }
    });
    
    // query and delete
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Context1: query 50");
        CEQueryCondition *condition = [CEQueryCondition new];
        [condition setRange:NSMakeRange(0, 50)];
        NSArray *result = [context1 queryByCondition:condition error:nil];
        XCTAssertEqual(result.count, 50);
        
        dispatch_async([self ramdomQueue], ^{
            NSLog(@"Context1: delete 50");
            CEQueryCondition *condition = [CEQueryCondition new];
            [condition setRange:NSMakeRange(50, 50)];
            NSArray *result = [context1 queryByCondition:condition error:nil];
            XCTAssertEqual(result.count, 50);
            XCTAssert([context1 removeObjects:result error:nil]);
        });
    });
    
    //------------------------------- context 2 --------------------------------
    
    // insert 100
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context2: insert 100");
        for (int i = 0; i < 100; i++) {
            
            DefaultKeyObject *obj = [DefaultKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context2 insert:obj error:nil]);
//            NSLog(@"Insert %@", obj.value);
        }
    });
    
    // update 0 -49 and insert more 50
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context2: update 0 -49");
        NSArray *result = [context2 queryAllWithError:nil];
        for (DefaultKeyObject *obj in result) {
            obj.value = [NSString stringWithFormat:@"obj_%d", (int)(arc4random() % 100000)];
        }
        XCTAssert([context2 updateObjects:result error:nil]);
        
        NSLog(@"Context2: insert more 50");
        for (int i = 100; i < 150; i++) {
            DefaultKeyObject *obj = [DefaultKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context2 insert:obj error:nil]);
        }
    });
    
    // query and delete
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Context2: query 50");
        CEQueryCondition *condition = [CEQueryCondition new];
        [condition setRange:NSMakeRange(0, 50)];
        NSArray *result = [context2 queryByCondition:condition error:nil];
        XCTAssertEqual(result.count, 50);
        
        dispatch_async([self ramdomQueue], ^{
            NSLog(@"Context2: delete 50");
            CEQueryCondition *condition = [CEQueryCondition new];
            [condition setRange:NSMakeRange(50, 50)];
            NSArray *result = [context2 queryByCondition:condition error:nil];
            XCTAssertEqual(result.count, 50);
            XCTAssert([context2 removeObjects:result error:nil]);
        });
    });
    
    [self waitForTimeout:8];
    XCTAssertEqual([context1 queryAllWithError:nil].count, 100);
    XCTAssertEqual([context2 queryAllWithError:nil].count, 100);
}


// 由于运行环境不稳定，这个异步测试有可能失败，如果失败概率比较高，则可判定为测试失败。
- (void)testAsyncReadWriteDifferentDB {
    CEDatabaseContext *context1 = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    CEDatabaseContext *context2 = [CEDatabaseContext contextWithTableName:[[DefaultKeyObject class] description] class:[DefaultKeyObject class] inDatabase:_db2];
    
    //------------------------------- context 1 --------------------------------
    // insert 100
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context1: insert 100");
        for (int i = 0; i < 100; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context1 insert:obj error:nil]);
//            NSLog(@"Insert %@", obj.value);
        }
    });
    
    // update 0 -49 and insert more 50
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context1: update 0 -49 and insert more 50");
        NSArray *result = [context1 queryAllWithError:nil];
        for (CustomKeyObject *obj in result) {
            obj.num = arc4random() % 100000;
        }
        XCTAssert([context1 updateObjects:result error:nil]);
        
        for (int i = 100; i < 150; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context1 insert:obj error:nil]);
        }
    });
    
    // query and delete
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Context1: query 50");
        CEQueryCondition *condition = [CEQueryCondition new];
        [condition setRange:NSMakeRange(0, 50)];
        NSArray *result = [context1 queryByCondition:condition error:nil];
        XCTAssertEqual(result.count, 50);
        
        dispatch_async([self ramdomQueue], ^{
            NSLog(@"Context1: delete 50");
            CEQueryCondition *condition = [CEQueryCondition new];
            [condition setRange:NSMakeRange(50, 50)];
            NSArray *result = [context1 queryByCondition:condition error:nil];
            XCTAssertEqual(result.count, 50);
            XCTAssert([context1 removeObjects:result error:nil]);
        });
    });
    
    //------------------------------- context 2 --------------------------------
    
    // insert 100
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context2: insert 100");
        for (int i = 0; i < 100; i++) {
            
            DefaultKeyObject *obj = [DefaultKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context2 insert:obj error:nil]);
//            NSLog(@"Insert %@", obj.value);
        }
    });
    
    // update 0 -49 and insert more 50
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context2: update 0 -49");
        NSArray *result = [context2 queryAllWithError:nil];
        for (DefaultKeyObject *obj in result) {
            obj.value = [NSString stringWithFormat:@"obj_%d", (int)(arc4random() % 100000)];
        }
        XCTAssert([context2 updateObjects:result error:nil]);
        
        NSLog(@"Context2: insert more 50");
        for (int i = 100; i < 150; i++) {
            DefaultKeyObject *obj = [DefaultKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context2 insert:obj error:nil]);
        }
    });
    
    // query and delete
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Context2: query 50");
        CEQueryCondition *condition = [CEQueryCondition new];
        [condition setRange:NSMakeRange(0, 50)];
        NSArray *result = [context2 queryByCondition:condition error:nil];
        XCTAssertEqual(result.count, 50);
        
        dispatch_async([self ramdomQueue], ^{
            NSLog(@"Context2: delete 50");
            CEQueryCondition *condition = [CEQueryCondition new];
            [condition setRange:NSMakeRange(50, 50)];
            NSArray *result = [context2 queryByCondition:condition error:nil];
            XCTAssertEqual(result.count, 50);
            XCTAssert([context2 removeObjects:result error:nil]);
        });
    });
    
    [self waitForTimeout:10];
    XCTAssertEqual([context1 queryAllWithError:nil].count, 100);
    XCTAssertEqual([context2 queryAllWithError:nil].count, 100);
}


// 由于运行环境不稳定，这个异步测试有可能失败，如果失败概率比较高，则可判定为测试失败。
- (void)testAsyncInsertSameTable
{
//    _db.fmdb.crashOnErrors = YES;
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < 100; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            printf("Insert: obj_%d \n", i);
            XCTAssert([context insert:obj error:nil]);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 100; i < 200; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            printf("Insert: obj_%d \n", i);
            XCTAssert([context insert:obj error:nil]);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        _db.fmdb.traceExecution = YES;
        CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
        for (int i = 200; i < 300; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            printf("Insert: obj_%d \n", i);
            XCTAssert([context insert:obj error:nil]);
        }
    });
    
    [self waitForTimeout:15];
    NSArray *result = [context queryAllWithError:nil];
    XCTAssertEqual(result.count, 300);
}


// 由于运行环境不稳定，这个异步测试有可能失败，如果失败概率比较高，则可判定为测试失败。
- (void)testAsyncReadWriteSameTable {
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    
    //------------------------------- context 1 --------------------------------
    // insert 100
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context1: insert 100");
        NSMutableArray *insertObjs = [NSMutableArray arrayWithCapacity:100];
        for (int i = 0; i < 100; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            [insertObjs addObject:obj];
        }
        XCTAssert([context insertObjects:insertObjs error:nil]);
    });
    
    // update 0 -49 and insert more 50
    dispatch_async([self ramdomQueue], ^{
        NSLog(@"Context1: update 0 -49 and insert more 50");
        NSArray *result = [context queryAllWithError:nil];
        for (CustomKeyObject *obj in result) {
            obj.num = arc4random() % 100000;
        }
        XCTAssert([context updateObjects:result error:nil]);
        
        for (int i = 100; i < 150; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context insert:obj error:nil]);
        }
    });
    
    // query and delete
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Context1: query 50");
        CEQueryCondition *condition = [CEQueryCondition new];
        [condition setRange:NSMakeRange(0, 50)];
        NSArray *result = [context queryByCondition:condition error:nil];
        XCTAssertEqual(result.count, 50);
        
        dispatch_async([self ramdomQueue], ^{
            NSLog(@"Context1: delete 50");
            CEQueryCondition *condition = [CEQueryCondition new];
            [condition setRange:NSMakeRange(50, 50)];
            NSArray *result = [context queryByCondition:condition error:nil];
            XCTAssertEqual(result.count, 50);
            XCTAssert([context removeObjects:result error:nil]);
        });
    });

    [self waitForTimeout:5];
    XCTAssertEqual([context queryAllWithError:nil].count, 100);
}

- (void)testAsyncCreationAndAccess {
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    dispatch_async([self ramdomQueue], ^{
        for (int i = 0; i < 1000; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            XCTAssert([context insert:obj error:nil]);
        }
    });
//    NSMutableArray *contexts = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        dispatch_async([self ramdomQueue], ^{
            CEDatabase *db = [CEDatabase databaseWithName:[NSString stringWithFormat:@"EmptyDB_%d", i]];
            CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:@"Test" class:[CustomKeyObject class] inDatabase:db];
//            [contexts addObject:context];
        });
    }
    
    [self waitForTimeout:10];
}

#pragma mark -

- (dispatch_queue_t)ramdomQueue {
    int priorities[4] = {DISPATCH_QUEUE_PRIORITY_DEFAULT,
                         DISPATCH_QUEUE_PRIORITY_HIGH,
                         DISPATCH_QUEUE_PRIORITY_LOW,
                         DISPATCH_QUEUE_PRIORITY_BACKGROUND};
    int index = arc4random() % 4;
    return dispatch_get_global_queue(priorities[index], 0);
}





@end
