//
//  DBCreationTest.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-7-31.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CEDatabase+Private.h"
#import "FMDatabaseAdditions.h"

// 测试数据库创建
@interface TestDBCreation : XCTestCase {
    CEDatabase *_db;
    NSString *_documentPath;
    NSString *_dbName1;
    NSString *_dbName2;
    NSString *_dbName3;
}

@end

@implementation TestDBCreation

- (void)setUp
{
    [super setUp];
    _db = [CEDatabase databaseWithName:@"TestTable"];
    
    _documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"syb_database"];
    _dbName1 = @"TestDB";
    _dbName2 = @"TestDB2.db";
    _dbName3 = @"TestDB3.abc";
}

- (void)tearDown
{
    [super tearDown];
    // 删除db文件夹
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"syb_database"];
    [[NSFileManager defaultManager] removeItemAtPath:directory error:nil];
    _db = nil;
    _documentPath = nil;
    _dbName1 = nil;
    _dbName2 = nil;
    _dbName3 = nil;
}

- (void)testDBCreation_none
{
    CEDatabase *db = [CEDatabase databaseWithName:_dbName1];
    NSString *dbFilePath = [_documentPath stringByAppendingFormat:@"/%@", _dbName1];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]);
    dispatch_sync(db.fmdbQueue, ^{
        FMDatabase *testDB = db.fmdb;
        testDB = nil;
    });
    XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]);
}

- (void)testDBCreation_db{
    CEDatabase *db = [CEDatabase databaseWithName:_dbName2];
    NSString *dbFilePath = [_documentPath stringByAppendingFormat:@"/%@", _dbName2];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]);
    dispatch_sync(db.fmdbQueue, ^{
        FMDatabase *testDB = db.fmdb;
        testDB = nil;
    });
    XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]);
}

- (void)testDBCreation_abc{
    CEDatabase *db = [CEDatabase databaseWithName:_dbName3];
    NSString *dbFilePath = [_documentPath stringByAppendingFormat:@"/%@", _dbName3];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]);
    dispatch_sync(db.fmdbQueue, ^{
        FMDatabase *testDB = db.fmdb;
        testDB = nil;
    });
    XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]);
}


- (void)testRemoveDB {
    [CEDatabase removeDatabase:_db.name error:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbFilePath = [_documentPath stringByAppendingPathComponent:@"TestTable"];
    XCTAssertFalse([fileManager fileExistsAtPath:dbFilePath], @"Remove DB Fail");
}

- (void)testCreateTable {
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[TestObject class] description] class:[TestObject class] inDatabase:_db];
    BOOL tableExists = [self isTableExist:[[TestObject class] description]];
    XCTAssert(tableExists, @"Fail to Create Table");
    context = nil;
}


- (void)testCreateNoneDBObjectTable {
    CEDatabaseContext *context = [[CEDatabaseContext alloc] initWithTableName:@"Test" class:[NoneDBObject class] inDatabase:_db];
    BOOL tableExists = [self isTableExist:[[NoneDBObject class] description]];
    XCTAssertFalse(tableExists, @"Fail to Create Table");
    context = nil;
}

- (void)testRemoveTable {
    // create table
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[TestObject class] description] class:[TestObject class] inDatabase:_db];
    BOOL tableExists = [self isTableExist:[[TestObject class] description]];
    XCTAssert(tableExists, @"Fail to Create Table");
    
    // remove table
    [CEDatabaseContext removeTable:context.tableName fromDatabase:_db error:nil];
    tableExists = [self isTableExist:[[TestObject class] description]];
    XCTAssertFalse(tableExists, @"Fail to Remove Table");
    
    context = nil;
}

// 测试表名冲突
- (void)testTableNameConfliction; {
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:@"TABLE" class:[Table class] inDatabase:_db];
    XCTAssert([self isTableExist:[[[Table class] description] stringByAppendingString:@"__"]]);
    
    Table *testObject = [Table new];
    testObject.name = @"xxxx";
    XCTAssert([context insert:testObject error:nil]);
    
    Table *queryObject = [context queryAllWithError:nil].lastObject;
    XCTAssertEqualObjects(queryObject.name, @"xxxx");
    
    // remove table
    XCTAssert([CEDatabaseContext removeTable:context.tableName fromDatabase:_db error:nil]);
}


// 测试属性冲突
- (void)testPropertyNameConfiliction {
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[ConflictPropertyObject class] description] class:[ConflictPropertyObject class] inDatabase:_db];
    XCTAssert([self isTableExist:[[ConflictPropertyObject class] description]]);
    
    ConflictPropertyObject *testObject = [ConflictPropertyObject new];
    testObject.table = @"myTable";
    testObject.where = @"home";
    testObject.query = @"when";
    XCTAssert([context insert:testObject error:nil]);
    
    ConflictPropertyObject *queryObject = [context queryAllWithError:nil].lastObject;
    XCTAssertEqualObjects(queryObject.table, @"myTable");
    XCTAssertEqualObjects(queryObject.where, @"home");
    XCTAssertEqualObjects(queryObject.query, @"when");
}


- (void)testCustiomDirectory {
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *customPath = [[myPathList lastObject] stringByAppendingPathComponent:@"my_cache_dir"];
    CEDatabase *db = [CEDatabase databaseWithName:@"customPathDB" inPath:customPath];
    dispatch_sync(db.fmdbQueue, ^{
        FMDatabase *testDB = db.fmdb;
        testDB = nil;
    });
    XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:[customPath stringByAppendingPathComponent:@"customPathDB"]]);
    
    // remove db
    [CEDatabase removeDatabase:@"customPathDB" inPath:customPath error:nil];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[customPath stringByAppendingPathComponent:@"customPathDB"]]);
}

- (BOOL)isTableExist:(NSString *)tableName {
    __block BOOL isExist = NO;
    dispatch_sync(_db.fmdbQueue, ^{
        isExist = [_db.fmdb tableExists:tableName];
    });
    return isExist;
}


@end









