//
//  TestQuery.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-4.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CEQueryCondition+Private.h"

#define kDefaultSize 10

@interface TestQuery : XCTestCase {
    CEDatabase *_db;
    CEDatabaseContext *_context1;
    CEDatabaseContext *_context2;
    CEDatabaseContext *_context3;
}

@end

@implementation TestQuery

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestQuery"];
    
    _context1 = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:kDefaultSize];
    for (int i = 0; i < kDefaultSize; i++) {
        CustomKeyObject *obj = [CustomKeyObject new];
        obj.value = [NSString stringWithFormat:@"obj_%d", i];
        [objects addObject:obj];
    }
    XCTAssert([_context1 insertObjects:objects error:nil]);
    
    
    _context2 = [CEDatabaseContext contextWithTableName:[[DefaultKeyObject class] description] class:[DefaultKeyObject class] inDatabase:_db];
    [objects removeAllObjects];
    for (int i = 0; i < kDefaultSize; i++) {
        DefaultKeyObject *obj = [DefaultKeyObject new];
        obj.value = [NSString stringWithFormat:@"obj_%d", i];
        [objects addObject:obj];
    }
    XCTAssert([_context2 insertObjects:objects error:nil]);
    
    _context3 = [CEDatabaseContext contextWithTableName:[[PrimaryTypeObject class] description] class:[PrimaryTypeObject class] inDatabase:_db];
    [objects removeAllObjects];
    for (int i = 0; i < kDefaultSize; i++) {
        PrimaryTypeObject *obj = [PrimaryTypeObject new];
        obj.uniqueId = 1000 + i;
        obj.doubleValue = i + 0.5;
        [objects addObject:obj];
    }
    
    XCTAssert([_context3 insertObjects:objects error:nil]);
}


- (void)tearDown
{
    [super tearDown];
    
    _context1 = nil;
    _context2 = nil;
    [CEDatabase removeDatabase:_db.name error:nil];
    _db = nil;
}


- (void)testQueryAll
{
    XCTAssertEqual([_context1 queryAllWithError:nil].count, kDefaultSize);
    XCTAssertEqual([_context2 queryAllWithError:nil].count, kDefaultSize);
    XCTAssertEqual([_context3 queryAllWithError:nil].count, kDefaultSize);
}


- (void)testQuery {
    XCTAssertFalse([_context1 queryByCondition:nil error:nil]);
    XCTAssert([_context1 queryByCondition:[CEQueryCondition new] error:nil]);
    XCTAssertFalse([_context1 queryById:nil error:nil]);
    XCTAssertFalse([_context1 queryById:[CustomKeyObject new] error:nil]);
}


- (void)testQueryByIDForCustomKeyObject
{
    CustomKeyObject *customObj = (CustomKeyObject *)[_context1 queryById:@"obj_1" error:nil];
    XCTAssertEqualObjects(customObj.value, @"obj_1");
    XCTAssertEqualObjects(customObj.objectID, @"obj_1");
}


- (void)testQueryByIDForDefaultKeyObject
{
    DefaultKeyObject *defaultObj = (DefaultKeyObject *)[_context2 queryById:@(2) error:nil];
    XCTAssertEqualObjects(defaultObj.value, @"obj_1");
    XCTAssertEqualObjects(defaultObj.objectID, @(2));
}


- (void)testQueryByIDForCustomPrimaryTypeObject {
    // 测试id 为C类型的查询
    PrimaryTypeObject *customObj = (PrimaryTypeObject *)[_context3 queryById:@(1002) error:nil];
    XCTAssertEqual(customObj.uniqueId, 1002);
    XCTAssertEqualObjects(customObj.objectID, @(1002));
}


@end






