//
//  TestNSCodingSupport.m
//  CEDatabase
//
//  Created by chance on 14-9-14.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CEManagedObject.h"

@interface OriginalObject : CEManagedObject

@property (nonatomic) NSInteger number;
@property (nonatomic, strong) NSString *name;

@end

@implementation OriginalObject

@end



@interface SubObject : OriginalObject

@property (nonatomic, strong) NSNumber *serialNum;

@end

@implementation SubObject

@end



@interface SubSubObject : SubObject

@property (nonatomic) double length;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *name;

@end

@implementation SubSubObject

@end



@interface TestNSCodingSupport : XCTestCase

@end

@implementation TestNSCodingSupport

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

- (void)testProperties
{
    NSSet *compareSet = [NSSet setWithObjects:@"number", @"name", @"objectID", nil];
    OriginalObject *originalObj = [OriginalObject new];
    NSSet *allProperties = [originalObj allProperties];
    XCTAssertEqualObjects(compareSet, allProperties);
    
    compareSet = [NSSet setWithObjects:@"number", @"name", @"objectID", @"serialNum", nil];
    SubObject *subObj = [SubObject new];
    allProperties = [subObj allProperties];
    XCTAssertEqualObjects(compareSet, allProperties);
    
    compareSet = [NSSet setWithObjects:@"number", @"name", @"objectID", @"serialNum", @"length", @"data", nil];
    SubSubObject *subSubObj = [SubSubObject new];
    allProperties = [subSubObj allProperties];
    XCTAssertEqualObjects(compareSet, allProperties);
}

- (void)testCoding {
    SubSubObject *obj = [SubSubObject new];
    obj.number = 123;
    obj.name = @"Hello";
    obj.serialNum = @(654321);
    obj.length = 5.5;
    obj.data = [@"DataString" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    XCTAssertNotNil(encodedData);
    
    SubSubObject *decodedObj = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
    XCTAssertNil(decodedObj.objectID);
    XCTAssertEqual(obj.number, decodedObj.number,);
    XCTAssertEqualObjects(obj.name, decodedObj.name);
    XCTAssertEqual(obj.length, decodedObj.length,);
    XCTAssertEqualObjects(obj.serialNum, decodedObj.serialNum);
    XCTAssertEqualObjects(obj.data, decodedObj.data);
    
}

@end
