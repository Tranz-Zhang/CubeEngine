//
//  TestInsert.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-4.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TestInsert : XCTestCase {
    CEDatabase *_db;
    CEDatabaseContext *_context;
}

@end

@implementation TestInsert

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestInsert"];
    _context = [CEDatabaseContext contextWithTableName:[[TestObject class] description] class:[TestObject class] inDatabase:_db];
}


- (void)tearDown
{
    [super tearDown];
    
    _context = nil;
    [CEDatabase removeDatabase:_db.name error:nil];
    _db = nil;
}


- (void)testInsertWrongType
{
    XCTAssertFalse([_context insert:((CEManagedObject *)[NSDate date]) error:nil]);
    XCTAssertFalse([_context insert:[CustomKeyObject new] error:nil]);
    XCTAssertFalse([_context insert:nil error:nil]);
}

- (void)testInsert
{
    TestObject *obj1 = [TestObject new];
    //    obj1.key = 0;
    obj1.string = [NSString stringWithFormat:@"obj_1"];
    XCTAssert([_context insert:obj1 error:nil]) ;
    
    TestObject *obj2 = [TestObject new];
    obj2.key = 1;
    obj2.string = [NSString stringWithFormat:@"obj_2"];
    XCTAssert([_context insert:obj2 error:nil]) ;
    
    NSArray *result = [_context queryAllWithError:nil];
    XCTAssertEqual(result.count, 2);
}


- (void) testMultipleInsert
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 10; i++) {
        TestObject *obj = [TestObject new];
        obj.string = [NSString stringWithFormat:@"obj_%d", i];
        
        [objects addObject:obj];
    }
    [_context insertObjects:objects error:nil];
    
    NSArray *result = [_context queryAllWithError:nil];
    XCTAssertEqual(result.count, 10);
    
    TestObject *originalObject5 = objects[1];
    TestObject *dbObject5 = result[1];
    XCTAssertEqualObjects(dbObject5.string, originalObject5.string);
}


- (void)testDataOrderWithIntID {
    // ObjectID为数字类型时，取出的顺序按ObjectID进行升序排序
    
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[OrderObject_Int class] description] class:[OrderObject_Int class] inDatabase:_db];
    
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 10; i++) {
        OrderObject_Int *obj = [OrderObject_Int new];
        obj.uniqueID = arc4random() % 1000;
        [objects addObject:obj];
    }
    [context insertObjects:objects error:nil];
    
    NSArray *sortedObjects = [objects sortedArrayUsingComparator:^NSComparisonResult(OrderObject_Int *obj1, OrderObject_Int *obj2) {
        return obj1.uniqueID - obj2.uniqueID;
    }];
    
    NSArray *result1 = [context queryAllWithError:nil];
    OrderObject_Int *original0 = sortedObjects[0];
    OrderObject_Int *query0 = result1[0];
    XCTAssertEqual(original0.uniqueID, query0.uniqueID);
    
    // try after move on object
    [context remove:objects[9] error:nil];
    NSArray *result2 = [context queryAllWithError:nil];
    original0 = sortedObjects[0];
    query0 = result2[0];
    XCTAssertEqual(original0.uniqueID, query0.uniqueID);
}


- (void)testDataOrderWithStringID {
    // ObjectID为字符串类型时，取出的顺序跟插入顺序一样
    
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:@"OrderObject" class:[OrderObject_String class] inDatabase:_db];
    
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 10; i++) {
        OrderObject_String *obj = [OrderObject_String new];
        obj.uniqueID = [NSString stringWithFormat:@"%u", arc4random() % 1000];
        [objects addObject:obj];
    }
    [context insertObjects:objects error:nil];
    
    NSArray *result1 = [context queryAllWithError:nil];
    OrderObject_String *original0 = objects[0];
    OrderObject_String *query0 = result1[0];
    XCTAssertEqualObjects(original0.uniqueID, query0.uniqueID);
    
    // try after move on object
    [context remove:objects[9] error:nil];
    NSArray *result2 = [context queryAllWithError:nil];
    original0 = objects[0];
    query0 = result2[0];
    XCTAssertEqualObjects(original0.uniqueID, query0.uniqueID);
}


#define kBanchmarkCount 100

- (void)_testInsertBanchmark
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < kBanchmarkCount; i++) {
        TestObject *obj = [TestObject new];
        obj.string = [NSString stringWithFormat:@"obj_%d", i];
        
        [_context insert:obj error:nil];
    }
    NSLog(@"Time for Single Insert: %.3f", CFAbsoluteTimeGetCurrent() - startTime);
    
    NSArray *result = [_context queryAllWithError:nil];
    XCTAssertEqual(result.count, kBanchmarkCount);
}


- (void)_testMultipleInsertBanchmark
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:5];
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    for (int i = 0; i < kBanchmarkCount; i++) {
        TestObject *obj = [TestObject new];
        obj.string = [NSString stringWithFormat:@"obj_%d", i];
        
        [objects addObject:obj];
    }
    [_context insertObjects:objects error:nil];
    NSLog(@"Time for Single Insert: %.3f", CFAbsoluteTimeGetCurrent() - startTime);
    
    NSArray *result = [_context queryAllWithError:nil];
    XCTAssertEqual(result.count, kBanchmarkCount);
}


- (void)testRollback {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < kBanchmarkCount; i++) {
        TestObject *obj = [TestObject new];
        obj.string = [NSString stringWithFormat:@"obj_%d", i];
        
        [objects addObject:obj];
    }
    [objects replaceObjectAtIndex:2 withObject:[NSNull null]];
//    TestObject *wrongObj = objects[2];
//    wrongObj.string = [NSString stringWithFormat:@"obj_0"];
    XCTAssertFalse([_context insertObjects:objects error:nil]);
    
    NSArray *result = [_context queryAllWithError:nil];
    XCTAssertEqual(result.count, 0);
}


@end







