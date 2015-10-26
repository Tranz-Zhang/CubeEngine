//
//  TestErrorInfo.m
//  CEDatabase
//
//  Created by chance on 14-8-18.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

/**
 这里主要测试否有返回错误信息
 */
@interface TestErrorInfo : XCTestCase {
    CEDatabase *_db;
    CEDatabaseContext *_context;
}

@end

@implementation TestErrorInfo

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestErrorInfo"];
    _context = [CEDatabaseContext contextWithTableName:[[TestObject class] description] class:[TestObject class] inDatabase:_db];
}


- (void)tearDown
{
    [super tearDown];
    
    _context = nil;
    [CEDatabase removeDatabase:_db.name error:nil];
    _db = nil;
}


- (void)testInvalideColumnInfo {
    NSError *error;
    CEDatabaseContext *invalidedContext = [CEDatabaseContext contextWithTableName:[[CEManagedObject class] description] class:[CEManagedObject class] inDatabase:_db];
    TestObject *obj = [TestObject new];
    
    XCTAssertFalse([invalidedContext insert:obj error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([invalidedContext update:obj error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([invalidedContext remove:obj error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
}


- (void)testDBNotAvailable
{
    NSError *error;
    [CEDatabase removeDatabase:_db.name error:&error];
    XCTAssertNil(error);
    [CEDatabase removeDatabase:_db.name error:&error];
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
}


- (void)testInsertError {
    NSError *error;
    XCTAssertFalse([_context insert:((CEManagedObject *)[NSDate date]) error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([_context insert:[CustomKeyObject new] error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([_context insert:nil error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    [CEDatabase removeDatabase:_db.name error:&error];
    TestObject *obj = [TestObject new];
    XCTAssertFalse([_context insert:obj error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
}


- (void)testUpdateError {
    NSError *error;
    // 更新空数据
    XCTAssertFalse([_context update:nil error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    // 更新错误类型的数据
    XCTAssertFalse([_context update:[TestObject new] error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    // 更新新建的数据,objectID为空
    XCTAssertFalse([_context update:[CustomKeyObject new] error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    [CEDatabase removeDatabase:_db.name error:&error];
    TestObject *obj = [TestObject new];
    XCTAssertFalse([_context update:obj error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
}


- (void)testRemoveError {
    NSError *error;
    XCTAssertFalse([_context remove:nil error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([_context remove:[TestObject new] error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([_context remove:[CustomKeyObject new] error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    [CEDatabase removeDatabase:_db.name error:&error];
    TestObject *obj = [TestObject new];
    XCTAssertFalse([_context remove:obj error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
}


- (void)testQueryError {
    NSError *error;
    XCTAssertFalse([_context queryByCondition:nil error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([_context queryByCondition:[CEQueryCondition new] error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([_context queryById:nil error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    XCTAssertFalse([_context queryById:[TestObject new] error:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
    
    [CEDatabase removeDatabase:_db.name error:&error];
    XCTAssertFalse([_context queryAllWithError:&error]);
    XCTAssert(error);
    NSLog(@"%@", error.localizedDescription);
}


@end



