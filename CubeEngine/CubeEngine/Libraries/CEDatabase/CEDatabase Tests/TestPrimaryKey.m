//
//  TestPrimaryKey.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-4.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>


@interface TestPrimaryKey : XCTestCase{
    CEDatabase *_db;
//    CEDatabaseContext *_context;
}

@end

@implementation TestPrimaryKey

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestPrimaryKeyDB"];
    
}

- (void)tearDown
{
    [super tearDown];
    [CEDatabase removeDatabase:_db.name error:nil];
    _db = nil;
}


- (void)testCustomPrimaryKey
{
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    for (int i = 0; i < 5; i++) {
        CustomKeyObject *obj = [CustomKeyObject new];
        obj.value = [NSString stringWithFormat:@"obj_%d", i];
        XCTAssert([context insert:obj error:nil], @"Insert Fail");
        XCTAssertEqual(obj.value, obj.value);
    }
}


- (void)testDefaultPrimaryKey
{
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[DefaultKeyObject class] description] class:[DefaultKeyObject class] inDatabase:_db];
    for (int i = 0; i < 5; i++) {
        DefaultKeyObject *obj = [DefaultKeyObject new];
        obj.value = [NSString stringWithFormat:@"obj_%d", i];
        XCTAssert([context insert:obj error:nil], @"Insert Fail");
        XCTAssertEqualObjects(obj.objectID, @(i + 1));
    }
}


- (void)testInsertCustomPrimaryKeyObjects {
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:_db];
    
    CustomKeyObject *obj1 = [CustomKeyObject new];
    //    obj1.key = 0;
    obj1.value = [NSString stringWithFormat:@"obj_1"];
    XCTAssert([context insert:obj1 error:nil]) ;
    
    CustomKeyObject *obj2 = [CustomKeyObject new];
    obj2.value = [NSString stringWithFormat:@"obj_2"];
    XCTAssert([context insert:obj2 error:nil]);
    
    CustomKeyObject *obj3 = [CustomKeyObject new];
    obj3.value = nil;
    XCTAssertFalse([context insert:obj3 error:nil]);
    
    CustomKeyObject *obj4 = [CustomKeyObject new];
    obj4.value = @"obj_1";
    XCTAssertFalse([context insert:obj4 error:nil]);
    
    NSArray *result = [context queryAllWithError:nil];
    XCTAssertEqual(result.count, 2);
}

- (void)testInsertDefaultPrimaryKeyObjects {
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[DefaultKeyObject class] description] class:[DefaultKeyObject class] inDatabase:_db];
    
    DefaultKeyObject *obj1 = [DefaultKeyObject new];
    //    obj1.key = 0;
    obj1.value = [NSString stringWithFormat:@"obj_1"];
    XCTAssert([context insert:obj1 error:nil]) ;
    
    DefaultKeyObject *obj2 = [DefaultKeyObject new];
    obj2.value = [NSString stringWithFormat:@"obj_2"];
    XCTAssert([context insert:obj2 error:nil]);
    
    DefaultKeyObject *obj3 = [DefaultKeyObject new];
    obj3.value = nil;
    XCTAssert([context insert:obj3 error:nil]);
    
    DefaultKeyObject *obj4 = [DefaultKeyObject new];
    obj4.value = @"obj_1";
    XCTAssert([context insert:obj4 error:nil]);
    
    NSArray *result = [context queryAllWithError:nil];
    XCTAssertEqual(result.count, 4);
}

@end











