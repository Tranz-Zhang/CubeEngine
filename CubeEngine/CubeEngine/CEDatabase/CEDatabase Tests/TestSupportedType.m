//
//  DBTypeTest.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-7-31.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>

// 测试数据库存储类型
@interface TestSupportedType : XCTestCase {
    CEDatabase *_db;
    CEDatabaseContext *_context;
}

@end

@implementation TestSupportedType

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestSupportedTypeDB"];
    _context = [CEDatabaseContext contextWithTableName:[[TestObject class] description] class:[TestObject class] inDatabase:_db];
}

- (void)tearDown
{
    [super tearDown];
    _context = nil;
    [CEDatabase removeDatabase:_db.name error:nil];
    _db = nil;
}


- (void)testOCType {
    TestObject *obj = [TestObject new];
    obj.string = @"Obj";
    obj.array = @[@"1", @"2", @"3"];
    obj.dictionary = @{@"a": @"apple", @"b" : @"banana", @"c" : @"cocoa"};
    obj.set = [NSSet setWithObjects:@"apple", @"banana", @"cocoa", nil];
    obj.number = @(99);
    obj.value = [NSValue valueWithCGPoint:CGPointMake(123, 456)];
    UIImage *image = [UIImage imageNamed:@"colorful"];
    obj.data = UIImagePNGRepresentation(image);
    
    XCTAssert([_context insert:obj error:nil]);
    
    TestObject *queryObj = [_context queryAllWithError:nil].lastObject;
    XCTAssertNotNil(queryObj);
    XCTAssertEqualObjects(queryObj.string, obj.string);
    XCTAssertEqualObjects(queryObj.array, obj.array);
    XCTAssertEqualObjects(queryObj.dictionary, obj.dictionary);
    XCTAssertEqualObjects(queryObj.set, obj.set);
    XCTAssertEqualObjects(queryObj.number, obj.number);
    XCTAssertEqualObjects(queryObj.value, obj.value);
    XCTAssertEqualObjects(queryObj.data, obj.data);
}

- (void)testMaxCValue {
    TestObject *obj = [TestObject new];
    obj.boolValue = YES;
    obj.charValue = CHAR_MAX;
    obj.shortValue = SHRT_MAX;
    obj.intValue = INT32_MAX;
    obj.longValue = LONG_MAX;
    obj.longLongValue = LLONG_MAX;
    obj.uCharValue = UCHAR_MAX;
    obj.uShortValue = USHRT_MAX;
    obj.uIntValue = UINT32_MAX;
    obj.uLongValue = ULONG_MAX;
    obj.uLongLongValue = ULLONG_MAX;
    obj.doubleValue = DBL_MAX;
    obj.floatValue = FLT_MAX;
    
    XCTAssert([_context insert:obj error:nil]);
    
    TestObject *queryObj = [_context queryAllWithError:nil].lastObject;
    XCTAssertNotNil(queryObj);
    XCTAssertEqual(queryObj.boolValue, obj.boolValue);
    XCTAssertEqual(queryObj.charValue, obj.charValue);
    XCTAssertEqual(queryObj.shortValue, obj.shortValue);
    XCTAssertEqual(queryObj.intValue, obj.intValue);
    XCTAssertEqual(queryObj.longValue, obj.longValue);
    XCTAssertEqual(queryObj.longLongValue, obj.longLongValue);
    XCTAssertEqual(queryObj.uCharValue, obj.uCharValue);
    XCTAssertEqual(queryObj.uShortValue, obj.uShortValue);
    XCTAssertEqual(queryObj.uIntValue, obj.uIntValue);
    XCTAssertEqual(queryObj.uLongValue, obj.uLongValue);
    XCTAssertEqual(queryObj.uLongLongValue, obj.uLongLongValue);
    XCTAssertEqual(queryObj.doubleValue, obj.doubleValue);
    XCTAssertEqual(queryObj.floatValue, obj.floatValue);
}

- (void)testMinCValue {
    TestObject *obj = [TestObject new];
    obj.boolValue = NO;
    obj.charValue = CHAR_MIN;
    obj.shortValue = SHRT_MIN;
    obj.intValue = INT32_MIN;
    obj.longValue = LONG_MIN;
    obj.longLongValue = LLONG_MIN;
    obj.uCharValue = 0;
    obj.uShortValue = 0;
    obj.uIntValue = 0;
    obj.uLongValue = 0;
    obj.uLongLongValue = 0;
    obj.doubleValue = DBL_MIN;
    obj.floatValue = FLT_MIN;
    
    XCTAssert([_context insert:obj error:nil]);
    
    TestObject *queryObj = [_context queryAllWithError:nil].lastObject;
    XCTAssertNotNil(queryObj);
    XCTAssertEqual(queryObj.boolValue, obj.boolValue);
    XCTAssertEqual(queryObj.charValue, obj.charValue);
    XCTAssertEqual(queryObj.shortValue, obj.shortValue);
    XCTAssertEqual(queryObj.intValue, obj.intValue);
    XCTAssertEqual(queryObj.longValue, obj.longValue);
    XCTAssertEqual(queryObj.longLongValue, obj.longLongValue);
    XCTAssertEqual(queryObj.uCharValue, obj.uCharValue);
    XCTAssertEqual(queryObj.uShortValue, obj.uShortValue);
    XCTAssertEqual(queryObj.uIntValue, obj.uIntValue);
    XCTAssertEqual(queryObj.uLongValue, obj.uLongValue);
    XCTAssertEqual(queryObj.uLongLongValue, obj.uLongLongValue);
    XCTAssertEqual(queryObj.doubleValue, obj.doubleValue);
    XCTAssertEqual(queryObj.floatValue, obj.floatValue);
}


- (void)testStoreCustomObjectToNSArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        CustomCodingObject *codingObj = [CustomCodingObject new];
        codingObj.codingName = [NSString stringWithFormat:@"coder_%d", i];
        codingObj.codingDate = [NSDate dateWithTimeIntervalSinceNow:i];
        codingObj.value = i;
        [array addObject:codingObj];
    }
    TestObject *obj = [TestObject new];
    obj.array = array; // array of custom object
    [_context insert:obj error:nil];
    
    TestObject *queryObj = [_context queryAllWithError:nil].lastObject;
    for (int i = 0; i < 3; i++) {
        CustomCodingObject *codingObj = array[i];
        CustomCodingObject *queryCodingObj = queryObj.array[i];
        XCTAssertEqualObjects(codingObj.codingName, queryCodingObj.codingName);
        XCTAssertEqualObjects(codingObj.codingDate, queryCodingObj.codingDate);
        XCTAssertEqual(codingObj.value, queryCodingObj.value);
    };
    
}


// 支持CEManagedObject的property
- (void)testCustomProperty {
    TestObject *obj = [TestObject new];
    obj.string = @"MyObj";
    
    CustomKeyObject *customObj = [CustomKeyObject new];
    customObj.value = @"value";
    customObj.num = 88;
    obj.customObject = customObj;
    
    SubNSObject *subObject = [SubNSObject new];
    subObject.someValue = @"SomeValue";
    obj.subObject = subObject;
    
    XCTAssert([_context insert:obj error:nil]);
    
    TestObject *queryObj = [_context queryAllWithError:nil].lastObject;
    XCTAssertNotNil(queryObj);
    XCTAssertEqualObjects(queryObj.string, obj.string);
    XCTAssertNotNil(customObj);
    XCTAssertEqual(customObj.num, queryObj.customObject.num);
    XCTAssertEqualObjects(customObj.value, queryObj.customObject.value);
    XCTAssertNil(queryObj.subObject);
    
}


@end






