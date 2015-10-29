//
//  TestConditionQuery.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-6.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CEQueryCondition+Private.h"

// 测试用数据结构
@interface Worker : CEManagedObject

BIND_OBJECT_ID(name)
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger age;
@property (nonatomic) double skillLevel;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSData *avatar;

+ (Worker *)workerWithName:(NSString *)name age:(NSInteger)age skillLevel:(double)skillLevel
                  birthday:(NSDate *)birthday avatar:(NSData *)avatar;

@end

@implementation Worker
+ (Worker *)workerWithName:(NSString *)name age:(NSInteger)age skillLevel:(double)skillLevel
                  birthday:(NSDate *)birthday avatar:(NSData *)avatar {
    Worker *worker = [Worker new];
    worker.name = name;
    worker.age = age;
    worker.skillLevel = skillLevel;
    worker.birthday = birthday;
    worker.avatar = avatar;
    return worker;
}
@end



@interface TestConditionQuery : XCTestCase {
    CEDatabase *_db;
    CEDatabaseContext *_context;
    
    NSDate *_date_1988_2_3;
    NSDate *_date_1988_5_8;
    NSDate *_date_1992_12_6;
    NSDate *_date_1986_8_8;
    NSDate *_date_1990_6_2;
}

@end

@implementation TestConditionQuery

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestConditionQuery"];
    _context = [CEDatabaseContext contextWithTableName:[[Worker class] description] class:[Worker class] inDatabase:_db];
    
    _date_1988_2_3 = [self dateOfYear:1988 month:2 day:3];
    _date_1988_5_8 = [self dateOfYear:1988 month:5 day:8];
    _date_1992_12_6 = [self dateOfYear:1992 month:12 day:6];
    _date_1986_8_8 = [self dateOfYear:1986 month:8 day:8];
    _date_1990_6_2 = [self dateOfYear:1990 month:6 day:2];
    
    NSMutableArray *workers = [NSMutableArray arrayWithCapacity:6];
    [workers addObject:[Worker workerWithName:@"James" age:26 skillLevel:8.6 birthday:_date_1988_2_3 avatar:nil]];
    [workers addObject:[Worker workerWithName:@"Funny" age:26 skillLevel:7.5 birthday:_date_1988_5_8 avatar:nil]];
    [workers addObject:[Worker workerWithName:@"Danne" age:22 skillLevel:8.0 birthday:_date_1992_12_6 avatar:nil]];
    [workers addObject:[Worker workerWithName:@"Frank" age:28 skillLevel:9.9 birthday:_date_1986_8_8 avatar:nil]];
    [workers addObject:[Worker workerWithName:@"Marky" age:22 skillLevel:8.8 birthday:_date_1992_12_6 avatar:nil]];
    [workers addObject:[Worker workerWithName:@"Cicie" age:24 skillLevel:7.8 birthday:_date_1990_6_2 avatar:nil]];
    XCTAssert([_context insertObjects:workers error:nil]);
}


- (NSDate *)dateOfYear:(int)year month:(int)month day:(int)day {
    NSDateComponents *dayComponents = [NSDateComponents new];
    dayComponents.year = year;
    dayComponents.month = month;
    dayComponents.day = day;
    return [[NSCalendar currentCalendar] dateFromComponents:dayComponents];
}


- (void)tearDown
{
    [super tearDown];
    
    _context = nil;
    [CEDatabase removeDatabase:_db.name error:nil];
    _db = nil;
}

#pragma mark - 条件查询

// == condition
- (void)testConditionEQUAL {
    CEQueryCondition *condition = [CEQueryCondition new];
    [condition setConditionWithFormat:@"age == %@", @(22)];
    NSArray *result = [_context queryByCondition:condition error:nil];
    
    NSArray *compareList = @[@"Danne", @"Marky"];
    XCTAssertEqual(result.count, compareList.count);
    for (Worker *worker in result) {
        XCTAssert([compareList containsObject:worker.name]);
    }
}

// && condition
- (void)testConditionAND {
    CEQueryCondition *condition = [CEQueryCondition new];
    [condition setConditionWithFormat:@"age == %@ && birthday == %@", @(26), _date_1988_2_3];
    NSArray *result = [_context queryByCondition:condition error:nil];
    
    XCTAssertEqual(result.count, 1);
    Worker *james = result.lastObject;
    XCTAssertEqualObjects(james.name, @"James");
}

// || condition
- (void)testConditionOR {
    CEQueryCondition *condition = [CEQueryCondition new];
    [condition setConditionWithFormat:@"age == %@ || name == %@", @(28), @"Cicie"];
    NSArray *result = [_context queryByCondition:condition error:nil];
    NSArray *compareList = @[@"Frank", @"Cicie"];
    
    XCTAssertEqual(result.count, compareList.count);
    for (Worker *worker in result) {
        XCTAssert([compareList containsObject:worker.name]);
    }
}

// >= condition + sort
- (void)testConditionLARGER_SORT {
    CEQueryCondition *condition = [CEQueryCondition new];
    [condition setConditionWithFormat:@"skillLevel >= %@", @(8)];
    [condition setSortOrderWithProperties:@[@"skillLevel"] isAscending:NO];
    NSArray *result = [_context queryByCondition:condition error:nil];
    
    NSArray *compareList = @[@"Frank", @"Marky", @"James", @"Danne"];
    XCTAssertEqual(result.count, compareList.count);
    [result enumerateObjectsUsingBlock:^(Worker *worker, NSUInteger idx, BOOL *stop) {
        XCTAssertEqualObjects(worker.name, compareList[idx]);
    }];
    
}

// limit condition + sort
- (void)testConditionLIMIT_SORT {
    CEQueryCondition *condition = [CEQueryCondition new];
    [condition setSortOrderWithProperties:@[@"name"] isAscending:YES];
    [condition setRange:NSMakeRange(1, 4)];
    NSArray *result = [_context queryByCondition:condition error:nil];
    
    NSArray *compareList =  @[@"Danne", @"Frank", @"Funny", @"James"];
    XCTAssertEqual(result.count, compareList.count);
    [result enumerateObjectsUsingBlock:^(Worker *worker, NSUInteger idx, BOOL *stop) {
        XCTAssertEqualObjects(worker.name, compareList[idx]);
    }];
    
}

// no arguments
- (void)testConditionNO_ARGUMENT {
    CEQueryCondition *condition = [CEQueryCondition new];
    [condition setConditionWithFormat:@"name == 'Danne'"];
    NSArray *result = [_context queryByCondition:condition error:nil];
    
    XCTAssertEqual(result.count, 1);
    Worker *Danne = result.lastObject;
    XCTAssertEqualObjects(Danne.name, @"Danne");
}

// nil condition
- (void)testConditionEMPTY_CONDITION {
    CEQueryCondition *condition = [CEQueryCondition new];
    NSArray *result = [_context queryByCondition:condition error:nil];
    XCTAssertEqual(result.count, 6);
}

// nil result
- (void)testConditionNIL_ARGUMENT {
    NSArray *result = [_context queryByCondition:nil error:nil];
    XCTAssertNil(result);
}


#pragma mark - 条件查询语句

- (void)testQueryConditionWhere {
    CEQueryCondition *queryCondition = [CEQueryCondition new];
    NSDictionary *argumentDict = nil;
    
    // test normal cmd
    [queryCondition setConditionWithFormat:@"defaultValue == %@", @"hoho"];
    XCTAssertEqualObjects(queryCondition.getCmd, @"WHERE defaultValue = :__where_arg_0");
    XCTAssertEqualObjects(queryCondition.getArgumentDict, @{@"__where_arg_0":@"hoho"});
    
    // test combined cmd and blank space
    [queryCondition setConditionWithFormat:@"defaultValue == %@&&someValue == %@", @"hoho", @(2423.22)];
    XCTAssertEqualObjects(queryCondition.getCmd, @"WHERE defaultValue = :__where_arg_0 AND someValue = :__where_arg_1");
    argumentDict = @{@"__where_arg_0":@"hoho", @"__where_arg_1":@(2423.22)};
    XCTAssertEqualObjects(queryCondition.getArgumentDict, argumentDict);
    
    // test NSArray argument and
    [queryCondition setConditionWithFormat:@"defaultValue >=%@ || value == %@ && value1 = 'hello'", @"hoho", @[@"1"]];
    XCTAssertEqualObjects(queryCondition.getCmd, @"WHERE defaultValue >=:__where_arg_0 OR value = :__where_arg_1 AND value1 = 'hello'");
    NSData *array_value = [NSKeyedArchiver archivedDataWithRootObject:@[@"1"]];
    argumentDict = @{@"__where_arg_0":@"hoho", @"__where_arg_1":array_value};
    XCTAssertEqualObjects(queryCondition.getArgumentDict, argumentDict);
    
    // test blank space and NSDate
    NSDate *date = [NSDate date];
    [queryCondition setConditionWithFormat:@"date=%@", date];
    XCTAssertEqualObjects(queryCondition.getCmd, @"WHERE date=:__where_arg_0");
    XCTAssertEqualObjects(queryCondition.getArgumentDict, @{@"__where_arg_0":date});
    
    // test nil
    [queryCondition setConditionWithFormat:nil];
    XCTAssertNil(queryCondition.getCmd);
    XCTAssertNil(queryCondition.getArgumentDict);
}


- (void)testQueryConditionOrder {
    CEQueryCondition *queryCondition = [CEQueryCondition new];
    
    // asc
    [queryCondition setSortOrderWithProperties:@[@"value", @"name"] isAscending:YES];
    XCTAssertEqualObjects(queryCondition.getCmd, @"ORDER BY value, name ASC");
    
    // desc
    [queryCondition setSortOrderWithProperties:@[@"value"] isAscending:NO];
    XCTAssertEqualObjects(queryCondition.getCmd, @"ORDER BY value DESC");
    
    // nil
    [queryCondition setSortOrderWithProperties:nil isAscending:YES];
    XCTAssertNil(queryCondition.getCmd);
    
    [queryCondition setSortOrderWithProperties:@[] isAscending:YES];
    XCTAssertNil(queryCondition.getCmd);
}


- (void)testQueryConditionLimit {
    CEQueryCondition *queryCondition = [CEQueryCondition new];
    
    [queryCondition setRange:NSMakeRange(0, 3)];
    XCTAssertEqualObjects(queryCondition.getCmd, @"LIMIT 3");
    [queryCondition setRange:NSMakeRange(CENotUsed, 3)];
    XCTAssertEqualObjects(queryCondition.getCmd, @"LIMIT 3");
    
    [queryCondition setRange:NSMakeRange(3, 0)];
    XCTAssertEqualObjects(queryCondition.getCmd, @"LIMIT 0 OFFSET 3");
    [queryCondition setRange:NSMakeRange(3, CENotUsed)];
    XCTAssertEqualObjects(queryCondition.getCmd, @"OFFSET 3");
    
    [queryCondition setRange:NSMakeRange(5, 6)];
    XCTAssertEqualObjects(queryCondition.getCmd, @"LIMIT 6 OFFSET 5");
    
    [queryCondition setRange:NSMakeRange(0, 0)];
    XCTAssertEqualObjects(queryCondition.getCmd, @"LIMIT 0");
    [queryCondition setRange:NSMakeRange(CENotUsed, CENotUsed)];
    XCTAssertNil(queryCondition.getCmd);
}


- (void)testQueryConditionMix
{
    NSString *cmd = nil;
    // test where + order
    CEQueryCondition *condition1 = [CEQueryCondition new];
    [condition1 setConditionWithFormat:@"value >= %@ && age <= 1", @"hello"];
    [condition1 setSortOrderWithProperties:@[@"value", @"age"] isAscending:YES];
    cmd = @"WHERE value >= :__where_arg_0 AND age <= 1 ORDER BY value, age ASC";
    XCTAssertEqualObjects(condition1.getCmd, cmd);
    
    // test order + limit
    CEQueryCondition *condition2 = [CEQueryCondition new];
    [condition2 setSortOrderWithProperties:@[@"value", @"age"] isAscending:YES];
    [condition2 setRange:NSMakeRange(2, 3)];
    cmd = @"ORDER BY value, age ASC LIMIT 3 OFFSET 2";
    XCTAssertEqualObjects(condition2.getCmd, cmd);
    
    // test where + limit
    CEQueryCondition *condition3 = [CEQueryCondition new];
    [condition3 setConditionWithFormat:@"value >= %@ && age <= 1", @"hello"];
    [condition3 setRange:NSMakeRange(2, 3)];
    cmd = @"WHERE value >= :__where_arg_0 AND age <= 1 LIMIT 3 OFFSET 2";
    XCTAssertEqualObjects(condition3.getCmd, cmd);
}


@end
