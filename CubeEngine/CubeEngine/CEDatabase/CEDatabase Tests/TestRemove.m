//
//  TestRemove.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-4.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

#define kDefaultSize 10

@interface TestRemove : XCTestCase {
    CEDatabase *_db;
    CEDatabaseContext *_context;
}

@end

@implementation TestRemove

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestUpdate"];
    _context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:kDefaultSize];
    for (int i = 0; i < kDefaultSize; i++) {
        CustomKeyObject *obj = [CustomKeyObject new];
        obj.value = [NSString stringWithFormat:@"obj_%d", i];
        [objects addObject:obj];
    }
    XCTAssert([_context insertObjects:objects error:nil]);
}


- (void)tearDown
{
    [super tearDown];
    
    _context = nil;
    [CEDatabase removeDatabase:_db.name error:nil];
    _db = nil;
}


- (void)testRemoveType
{
    XCTAssertFalse([_context remove:nil error:nil]);
    XCTAssertFalse([_context remove:[TestObject new] error:nil]);
    XCTAssertFalse([_context remove:[CustomKeyObject new] error:nil]);
    XCTAssert([_context remove:[_context queryById:@"obj_2" error:nil] error:nil]);
}


- (void)testRemoveSingleObject
{
    XCTAssertEqual([_context queryAllWithError:nil].count, kDefaultSize);
    CustomKeyObject *obj = (CustomKeyObject *)[_context queryById:@"obj_2" error:nil];
    [_context remove:obj error:nil];
    XCTAssertNil([_context queryById:@"obj_2" error:nil]);
    XCTAssertEqual([_context queryAllWithError:nil].count, 9);
}


- (void)testRemoveMultipleObjects {
    XCTAssertEqual([_context queryAllWithError:nil].count, kDefaultSize);
    
    CustomKeyObject *obj2 = (CustomKeyObject *)[_context queryById:@"obj_2" error:nil];
    CustomKeyObject *obj5 = (CustomKeyObject *)[_context queryById:@"obj_5" error:nil];
    CustomKeyObject *obj7 = (CustomKeyObject *)[_context queryById:@"obj_7" error:nil];
    [_context removeObjects:@[obj2, obj5, obj7] error:nil];
    
    XCTAssertNil([_context queryById:@"obj_2" error:nil]);
    XCTAssertNil([_context queryById:@"obj_5" error:nil]);
    XCTAssertNil([_context queryById:@"obj_7" error:nil]);
    XCTAssertEqual([_context queryAllWithError:nil].count, 7);
}


- (void)testRemoveAll {
    XCTAssertEqual([_context queryAllWithError:nil].count, kDefaultSize);
    [_context removeAllObjectsWithError:nil];
    XCTAssertEqual([_context queryAllWithError:nil].count, 0);
}


- (void)testRollback {
    XCTAssertEqual([_context queryAllWithError:nil].count, kDefaultSize);
    
    CustomKeyObject *obj2 = (CustomKeyObject *)[_context queryById:@"obj_2" error:nil];
    CustomKeyObject *obj7 = (CustomKeyObject *)[_context queryById:@"obj_7" error:nil];
    NSArray *removedObjects = @[obj2, [NSNull null], obj7];
    XCTAssertFalse([_context removeObjects:removedObjects error:nil]);
    
    XCTAssert([_context queryById:@"obj_2" error:nil]);
    XCTAssert([_context queryById:@"obj_5" error:nil]);
    XCTAssert([_context queryById:@"obj_7" error:nil]);
    XCTAssertEqual([_context queryAllWithError:nil].count, kDefaultSize);
}


@end



