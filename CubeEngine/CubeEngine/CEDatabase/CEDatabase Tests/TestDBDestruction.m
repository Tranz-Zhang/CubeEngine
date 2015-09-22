//
//  TestDBDestruction.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-10.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FMDatabaseAdditions.h"
#import "CEDatabase+Private.h"

@interface TestDBDestruction : XCTestCase

@end

@implementation TestDBDestruction

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testRemoveDB {
    // 测试删除DB后进行删除表的操作是否成功
    CEDatabase *db = [CEDatabase databaseWithName:@"TestDestruction"];
    CEDatabaseContext *context1 = [CEDatabaseContext contextWithTableName:@"A" class:[TestObject class] inDatabase:db];
    CEDatabaseContext *context2 = [CEDatabaseContext contextWithTableName:@"B" class:[CustomKeyObject class] inDatabase:db];
    
    XCTAssert([CEDatabaseContext removeTable:context1.tableName fromDatabase:db error:nil]);
    
    [CEDatabase removeDatabase:db.name error:nil];
    XCTAssertFalse([CEDatabaseContext removeTable:context2.tableName fromDatabase:db error:nil]);
}



- (void)testRemoveSqliteKeywordTable {
    // 测试表名为sqlite关键字是删除是否成功
    CEDatabase *db = [CEDatabase databaseWithName:@"TestDestruction"];
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:@"TABLE" class:[TestObject class] inDatabase:db];
    
    XCTAssert([CEDatabaseContext removeTable:context.tableName fromDatabase:db error:nil]);
}


// 三个表，一个db，不同线程进行操作，中间突然把表删掉
- (void)testAsyncRemoveTable
{
    CEDatabase *db = [CEDatabase databaseWithName:@"TestDestruction"];
    CEDatabaseContext *context1 = [CEDatabaseContext contextWithTableName:[[TestObject class] description] class:[TestObject class] inDatabase:db];
    CEDatabaseContext *context2 = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:db];
    CEDatabaseContext *context3 = [CEDatabaseContext contextWithTableName:[[DefaultKeyObject class] description] class:[DefaultKeyObject class] inDatabase:db];
    __block BOOL isContext1Enabled = YES;
    __block BOOL isContext2Enabled = YES;
    __block BOOL isContext3Enabled = YES;
    
    //---------------------------- Context1 ------------------------------------
    
    dispatch_async([self ramdomQueue], ^{
        for (int i = 0; i < 10; i++) {
            TestObject *obj = [TestObject new];
            obj.string = [NSString stringWithFormat:@"obj_%d", i];
            NSLog(@"Insert %@", obj.string);
            if (isContext1Enabled) {
                XCTAssert([context1 insert:obj error:nil]);
                
            } else { // table has deleted
                XCTAssertFalse([context1 insert:obj error:nil]);
            }
            
            [NSThread sleepForTimeInterval:0.5];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSArray *result = [context1 queryAllWithError:nil];
        XCTAssert(result.count <= 2);
        XCTAssert([context1 removeObjects:result error:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        XCTAssertNil([context1 queryAllWithError:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TestObject *obj = [TestObject new];
        obj.string = @"obj_max";
        XCTAssertFalse([context1 insert:obj error:nil]);
    });
    
    // delete table after 2.2s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.2 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Remove Table");
        isContext1Enabled = NO;
        [CEDatabaseContext removeTable:context1.tableName fromDatabase:db error:nil];
        XCTAssertFalse([self database:db containTable:[context1.tableClass description]]);
    });
    
    //---------------------------- Context2 ------------------------------------
    
    dispatch_async([self ramdomQueue], ^{
        for (int i = 0; i < 40; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            NSLog(@"Insert %@", obj.value);
            if (isContext2Enabled) {
                XCTAssert([context2 insert:obj error:nil], "%@", obj.value);
                
            } else { // table has deleted
                XCTAssertFalse([context2 insert:obj error:nil]);
            }
            
            [NSThread sleepForTimeInterval:0.1];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.91 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSArray *result = [context2 queryAllWithError:nil];
        XCTAssert(result.count <= 10);
        XCTAssert([context2 removeObjects:result error:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        XCTAssertNil([context2 queryAllWithError:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CustomKeyObject *obj = [CustomKeyObject new];
        obj.value = @"obj_max";
        XCTAssertFalse([context2 insert:obj error:nil]);
    });
    
    // delete table after 5s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.2 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Remove Table");
        isContext2Enabled = NO;
        [CEDatabaseContext removeTable:context2.tableName fromDatabase:db error:nil];
        XCTAssertFalse([self database:db containTable:[context1.tableClass description]]);
    });
    
    
    //---------------------------- Context3 ------------------------------------
    dispatch_async([self ramdomQueue], ^{
        for (int i = 0; i < 10; i++) {
            DefaultKeyObject *obj = [DefaultKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            NSLog(@"Insert %@", obj.value);
            if (isContext3Enabled) {
                XCTAssert([context3 insert:obj error:nil]);
                
            } else { // table has deleted
                XCTAssertFalse([context3 insert:obj error:nil]);
            }
            
            [NSThread sleepForTimeInterval:0.4];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSArray *result = [context3 queryAllWithError:nil];
        XCTAssert(result.count <= 3);
        XCTAssert([context3 removeObjects:result error:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        XCTAssertNil([context3 queryAllWithError:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DefaultKeyObject *obj = [DefaultKeyObject new];
        obj.value = @"obj_max";
        XCTAssertFalse([context3 insert:obj error:nil]);
    });
    
    // delete table after 5s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Remove Table");
        isContext3Enabled = NO;
        [CEDatabaseContext removeTable:context3.tableName fromDatabase:db error:nil];
        XCTAssertFalse([self database:db containTable:[context3.tableClass description]]);
    });
    
    
    [self waitForTimeout:8];
}


- (void)testAsyncRemoveDB
{
    CEDatabase *db = [CEDatabase databaseWithName:@"TestDestruction"];
    CEDatabaseContext *context1 = [CEDatabaseContext contextWithTableName:[[TestObject class] description] class:[TestObject class] inDatabase:db];
    CEDatabaseContext *context2 = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:db];
    CEDatabaseContext *context3 = [CEDatabaseContext contextWithTableName:[[DefaultKeyObject class] description]  class:[DefaultKeyObject class] inDatabase:db];
    __block BOOL isContext1Enabled = YES;
    __block BOOL isContext2Enabled = YES;
    __block BOOL isContext3Enabled = YES;
    
    //---------------------------- Context1 ------------------------------------
    
    dispatch_async([self ramdomQueue], ^{
        for (int i = 0; i < 10; i++) {
            TestObject *obj = [TestObject new];
            obj.string = [NSString stringWithFormat:@"obj_%d", i];
            NSLog(@"Insert %@", obj.string);
            if (isContext1Enabled) {
                XCTAssert([context1 insert:obj error:nil]);
                
            } else { // table has deleted
                XCTAssertFalse([context1 insert:obj error:nil]);
            }
            
            [NSThread sleepForTimeInterval:0.5];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSArray *result = [context1 queryAllWithError:nil];
        XCTAssert(result.count <= 2);
        XCTAssert([context1 removeObjects:result error:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        XCTAssertNil([context1 queryAllWithError:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TestObject *obj = [TestObject new];
        obj.string = @"obj_max";
        XCTAssertFalse([context1 insert:obj error:nil]);
    });
    
    //---------------------------- Context2 ------------------------------------
    
    dispatch_async([self ramdomQueue], ^{
        for (int i = 0; i < 40; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            NSLog(@"Insert %@", obj.value);
            if (isContext2Enabled) {
                XCTAssert([context2 insert:obj error:nil]);
                
            } else { // table has deleted
                XCTAssertFalse([context2 insert:obj error:nil]);
            }
            
            [NSThread sleepForTimeInterval:0.1];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.91 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSArray *result = [context2 queryAllWithError:nil];
        XCTAssert(result.count <= 10);
        XCTAssert([context2 removeObjects:result error:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        XCTAssertNil([context2 queryAllWithError:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CustomKeyObject *obj = [CustomKeyObject new];
        obj.value = @"obj_max";
        XCTAssertFalse([context2 insert:obj error:nil]);
    });
    
    // delete table after 5s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.2 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSLog(@"Remove Table");
        [CEDatabaseContext removeTable:context2.tableName fromDatabase:db error:nil];
        isContext2Enabled = NO;
        XCTAssertFalse([self database:db containTable:[context1.tableClass description]]);
    });
    
    
    
    //---------------------------- Context3 ------------------------------------
    dispatch_async([self ramdomQueue], ^{
        for (int i = 0; i < 10; i++) {
            DefaultKeyObject *obj = [DefaultKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            NSLog(@"Insert %@", obj.value);
            if (isContext3Enabled) {
                XCTAssert([context3 insert:obj error:nil]);
                
            } else { // table has deleted
                XCTAssertFalse([context3 insert:obj error:nil]);
            }
            
            [NSThread sleepForTimeInterval:0.4];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        NSArray *result = [context3 queryAllWithError:nil];
        XCTAssert(result.count <= 3);
        XCTAssert([context3 removeObjects:result error:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), [self ramdomQueue], ^{
        XCTAssertNil([context3 queryAllWithError:nil]);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DefaultKeyObject *obj = [DefaultKeyObject new];
        obj.value = @"obj_max";
        XCTAssertFalse([context3 insert:obj error:nil]);
    });
    
    
    // delete table after 3s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CEDatabase removeDatabase:db.name error:nil];
        isContext1Enabled = NO;
        isContext2Enabled = NO;
        isContext3Enabled = NO;
    });
    
    [self waitForTimeout:8];
    db = nil;
}


- (BOOL)database:(CEDatabase *)db containTable:(NSString *)tableName {
    if (!db.fmdbQueue) return NO;
    
    __block BOOL isExist = YES;
    dispatch_sync(db.fmdbQueue, ^{
        isExist = [db.fmdb tableExists:tableName];
    });
    return isExist;
}


- (dispatch_queue_t)ramdomQueue {
    int priorities[4] = {DISPATCH_QUEUE_PRIORITY_DEFAULT,
        DISPATCH_QUEUE_PRIORITY_HIGH,
        DISPATCH_QUEUE_PRIORITY_LOW,
        DISPATCH_QUEUE_PRIORITY_BACKGROUND};
    int index = arc4random() % 4;
    return dispatch_get_global_queue(priorities[index], 0);
}



@end



