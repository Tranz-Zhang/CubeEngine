//
//  TestUpdate.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-4.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TestUpdate : XCTestCase {
    CEDatabase *_db;
    CEDatabaseContext *_context;
}

@end

@implementation TestUpdate

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestUpdate"];
    _context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 10; i++) {
        CustomKeyObject *obj = [CustomKeyObject new];
        obj.value = [NSString stringWithFormat:@"obj_%d", i];
        obj.num = i;
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


- (void)testUpdateType {
    // 更新空数据
    XCTAssertFalse([_context update:nil error:nil]);
    
    // 更新错误类型的数据
    XCTAssertFalse([_context update:[TestObject new] error:nil]);
    
    // 更新新建的数据,objectID为空
    XCTAssertFalse([_context update:[CustomKeyObject new] error:nil]);
    
    // 更新查询出来的数据
    XCTAssert([_context update:[_context queryById:@"obj_2" error:nil] error:nil]);
}

- (void)testUpdateSingle
{
    CustomKeyObject *obj = (CustomKeyObject *)[_context queryById:@"obj_2" error:nil];
    obj.value = @"obj_modified";
    obj.num = 3;
    [_context update:obj error:nil];
    
    CustomKeyObject *updatedObj = (CustomKeyObject *)[_context queryById:@"obj_modified" error:nil];
    XCTAssertEqual(updatedObj.num, 3);
    XCTAssertEqualObjects(updatedObj.value, @"obj_modified");
}

- (void)testMultipleUpdate {
    NSArray *allObjs = [_context queryAllWithError:nil];
    CustomKeyObject *obj1 = allObjs[1];
    obj1.num = 12345;
    CustomKeyObject *obj3 = allObjs[3];
    obj3.num = 67890;
    [_context updateObjects:@[obj1, obj3] error:nil];
    
    CustomKeyObject *updatedObj = (CustomKeyObject *)[_context queryById:@"obj_1" error:nil];
    XCTAssertEqual(updatedObj.num, 12345);
    
    updatedObj = (CustomKeyObject *)[_context queryById:@"obj_3" error:nil];
    XCTAssertEqual(updatedObj.num, 67890);
}

- (void)testRollback {
    NSArray *allObjs = [_context queryAllWithError:nil];
    CustomKeyObject *obj1 = allObjs[1];
    obj1.num = 12345;
    CustomKeyObject *obj3 = allObjs[3];
    obj3.num = 67890;
    NSArray *updatedObjects = @[obj1, obj3, [NSNull null]];
    XCTAssertFalse([_context updateObjects:updatedObjects error:nil]);
    
    CustomKeyObject *updatedObj = (CustomKeyObject *)[_context queryById:@"obj_1" error:nil];
    XCTAssertEqual(updatedObj.num, 1);
    
    updatedObj = (CustomKeyObject *)[_context queryById:@"obj_3" error:nil];
    XCTAssertEqual(updatedObj.num, 3);
}


- (void)testNewObjectUpdate {
    CustomKeyObject *obj = [CustomKeyObject new];
    obj.value = @"obj_2";
    obj.num = 987654;
    XCTAssertFalse([_context update:obj error:nil]);
}



@end






