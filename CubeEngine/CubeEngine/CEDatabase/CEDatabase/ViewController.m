//
//  ViewController.m
//  CEDatabase
//
//  Created by chance on 14-8-13.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <objc/runtime.h>
#import <CoreData/CoreData.h>

#import "sqlite3.h"
#import "ViewController.h"
#import "FMDB.h"
#import "SuperStudent.h"
#import "CEDatabase+Private.h"
#import "TestObject.h"
#import "CustomKeyObject.h"

@interface ViewController ()

@property (nonatomic, strong) FMDatabase *db;
@property (weak, nonatomic) IBOutlet UITextView *infoView;
@property (nonatomic, strong) NSMutableSet *threadIds;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	if ([UIDevice currentDevice].systemVersion.floatValue > 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.infoView.text = nil;
    
    // sqlite base info
    [self log:[NSString stringWithFormat:@"SQLite Version: %@", [FMDatabase sqliteLibVersion]]];
    [self log:[NSString stringWithFormat:@"Support Multithread: %@", [FMDatabase isSQLiteThreadSafe] ? @"YES" : @"NO"]];
    
    // create db
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[paths lastObject] stringByAppendingPathComponent:@"test.db"];
    self.db = [[FMDatabase alloc] initWithPath:dbPath];
    if (!_db) {
        [self log:@"ERROR: fail to create db!"];
        
    } else {
        [self log:@"create db success"];
    }
    
    self.threadIds = [NSMutableSet setWithCapacity:15];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)log:(NSString *)logInfo {
    NSMutableString *info = [NSMutableString stringWithString:self.infoView.text];
    [info appendFormat:@"-%@\n", logInfo];
    self.infoView.text = info;
    [self.infoView scrollRangeToVisible:NSMakeRange(info.length - 1, 1)];
}


- (IBAction)onTest:(id)sender {
    
    Student *student = [Student new];
    [student setValue:@"Tranz" forKey:@"name"];
    [student setValue:@(123.56) forKey:@"intValue"];
    
    Class clazz = [Student class];
    NSLog(@"%@", [self createTableCommand:[Student class]]);
    u_int count;
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        const char* propertyAttribute = property_getAttributes(properties[i]);
        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        NSLog(@"%s: %s", propertyName, propertyAttribute);
    }
    free(properties);
    
    return;
    
    [_db open];
    if (![self isTableExist:@"student"]) {
        [_db executeUpdate:@"CREATE TABLE student (name text, age INTEGER, grade int)"];
        [self log:@"create table: student"];
    }
    
    // insert
    [_db executeUpdate:@"INSERT INTO student(name, age, grade) values (?, ?, ?)", @"Tranz", @(26), @(6)];
    [_db executeUpdate:@"INSERT INTO student(name, age) values (?, ?)", @"Trana", @(26)];
    
    FMResultSet *result = [_db executeQuery:@"select * from student"];
    [self log:result.statement.query];
    while ([result next]) {
        [self log:[result description]];
    }
    [result close];
    
    // delete
    [_db executeUpdate:@"DELETE FROM student WHERE grade = (null)"];
    result = [_db executeQuery:@"select * from student"];
    [self log:@"After Delete:"];
    while ([result next]) {
        [self log:[result description]];
    }
    [result close];
    
    // drop table
    if([_db executeUpdate:@"DROP TABLE IF EXISTS student"]) {
        [self log:@"drop table: student"];
    } else {
        [self log:@"ERROR: fail to drop table"];
    }
    
}

- (BOOL)isTableExist:(NSString *)tableName {
    NSString *resultTable = [_db stringForQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name=?", tableName];
    return resultTable ? YES : NO;
}

- (BOOL)checkLastError {
    if ([_db hadError]) {
        [self log:[NSString stringWithFormat:@"ERROR: create table fail: %@", [_db lastErrorMessage]]];
        return YES;
    }
    return NO;
}


#pragma mark - DB Operation

- (NSString *)createTableCommand:(Class)clazz {
    NSString *tableName = [clazz description];
    NSMutableString *command = [NSMutableString stringWithFormat:@"CREATE TABLE %@", tableName];
    u_int count;
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    [command appendString:@"("];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        const char* propertyAttribute = property_getAttributes(properties[i]);
        NSString *typeName = [self sqliteTypeForPropertyAttribute:propertyAttribute];
        [command appendFormat:@"%s %@, ", propertyName, typeName];
        //        NSLog(@"%s: %s - %@", propertyName, propertyAttribute, );
    }
    [command replaceCharactersInRange:NSMakeRange(command.length - 2, 2) withString:@")"];
    return command;
}


- (NSString *)sqliteTypeForPropertyAttribute:(const char*)attribute {
    
    NSString *attributeString = [NSString stringWithCString:attribute encoding:NSUTF8StringEncoding];
    int endIndex = [attributeString rangeOfString:@","].location;
    NSString *typeString = [attributeString substringWithRange:NSMakeRange(1, endIndex - 1)];
    
    NSDictionary *objcToSqliteTypeDict =
    @{@"c" : @"INTEGER",
      @"s" : @"INTEGER",
      @"i" : @"INTEGER",
      @"l" : @"INTEGER",
      @"q" : @"INTEGER",
      @"d" : @"DOUBLE",
      @"f" : @"FLOAT",
      @"NSString" : @"TEXT",
      @"NSMutableString" : @"TEXT",
      @"NSArray" : @"BLOB",
      @"NSMutableArray" : @"BLOB",
      @"NSDictionary" : @"BLOB",
      @"NSMutableDictionary" : @"BLOB",
      @"NSData" : @"BLOB",
      @"NSMutableData" : @"BLOB",
      @"NSSet" : @"BLOB",
      @"NSMutableSet" : @"BLOB",
      @"NSDate" : @"DATE",
      @"NSNumber" : @"REAL"};
    
    if ([typeString hasPrefix:@"@"]) {// objc type
        NSString *objcType = [typeString substringWithRange:NSMakeRange(2, typeString.length - 3)];
        return objcToSqliteTypeDict[objcType];
        
    } else { // c type
        return objcToSqliteTypeDict[typeString.lowercaseString];
    }
}


- (IBAction)onCEDatabase:(id)sender {
//    [self _dbTest01];
//    return;
    
    CEDatabase *database = [CEDatabase databaseWithName:@"Test"];
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[TestObject class] description] class:[TestObject class]
                                                            inDatabase:database];
    
    TestObject *obj = [TestObject new];
    obj.boolValue = YES;
    obj.string = @"string";
    obj.array = @[@"1", @"2", @"3"];
    obj.dictionary = @{@"a" : @"apple"};
    obj.set = [NSSet setWithObjects:@"8", @"5", @"3", nil];
    obj.number = @(123123.345457);
    obj.value = [NSValue valueWithCGPoint:CGPointMake(123, 234)];
    UIImage *image = [UIImage imageNamed:@"colorful"];
    obj.data = UIImagePNGRepresentation(image);
    [context insert:obj error:nil];
    NSAssert([context queryAllWithError:nil].count == 1, @"Insert Fail");
    
    FMDatabase *db = database.fmdb;
    //    db.traceExecution = YES;
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM TestObject WHERE string = ? and array = ?", obj.string];
    if (![rs next]) NSLog(@"String fail");
    
    rs = [db executeQuery:@"SELECT * FROM TestObject WHERE array = ?", [NSKeyedArchiver archivedDataWithRootObject:obj.array]];
    if (![rs next]) NSLog(@"array fail");
    
    rs = [db executeQuery:@"SELECT * FROM TestObject WHERE dictionary = ?", [NSKeyedArchiver archivedDataWithRootObject:obj.dictionary]];
    if (![rs next]) NSLog(@"dictionary fail");
    
    rs = [db executeQuery:@"SELECT * FROM TestObject WHERE set__ = ?", [NSKeyedArchiver archivedDataWithRootObject:obj.set]];
    if (![rs next]) NSLog(@"set fail");
    
    rs = [db executeQuery:@"SELECT * FROM TestObject WHERE number = ?", obj.number];
    if (![rs next]) NSLog(@"number fail");
    
    rs = [db executeQuery:@"SELECT * FROM TestObject WHERE value = ?", [NSKeyedArchiver archivedDataWithRootObject:obj.value]];
    if (![rs next]) NSLog(@"value fail");
    
    rs = [db executeQuery:@"SELECT * FROM TestObject WHERE data = ?", obj.data];
    if (![rs next]) NSLog(@"data fail");
    
    
    //    NSArray *result = [context queryAllWithError:nil];
    //    for (Student *student in result) {
    //        NSAssert(student.longLongValue == ULLONG_MAX, @"Longlong error");
    //        NSAssert(student.floatValue == CGFLOAT_MAX, @"cgfloat error");
    //        NSLog(@"Array: %@", student.array);
    //        NSLog(@"Dictionary: %@", student.dictionary);
    //    }
    
    /*
     CEDatabase *db = [CEDatabase databaseWithName:@"TestDB"];
     CEDatabaseContext *context = [CEDatabaseContext contextWithTableName: class:[TestObject class] inDatabase:db];
     
     TestObject *obj1 = [TestObject new];
     obj1.string = @"Obj1";
     obj1.array = @[@"1", @"2", @"3"];
     obj1.dictionary = @{@"a": @"apple", @"b" : @"banana", @"c" : @"cocoa"};
     obj1.set = [NSSet setWithObjects:@"apple", @"banana", @"cocoa", nil];
     obj1.number = @(99);
     obj1.value = [NSValue valueWithCGPoint:CGPointMake(123, 456)];
     // Mutable OC Type
     //    obj1.mutableString = nil;
     //    obj1.mutableArray = nil;
     //    obj1.mutableDictionary = nil;
     //    obj1.mutableSet = nil;
     
     
     // MAX C Type
     TestObject *obj2 = [TestObject new];
     obj2.string = @"Obj2";
     obj2.boolValue = YES;
     //    obj2.charValue = CHAR_MAX;
     obj2.shortValue = SHRT_MAX;
     obj2.intValue = INT32_MAX;
     obj2.longValue = LONG_MAX;
     obj2.longLongValue = LLONG_MAX;
     obj2.uCharValue = UCHAR_MAX;
     obj2.uShortValue = USHRT_MAX;
     obj2.uIntValue = UINT32_MAX;
     obj2.uLongValue = ULONG_MAX;
     obj2.uLongLongValue = ULLONG_MAX;
     obj2.doubleValue = DBL_MAX;
     obj2.floatValue = FLT_MAX;
     
     // MIN C Type
     TestObject *obj3 = [TestObject new];
     obj3.string = @"Obj3";
     obj3.boolValue = YES;
     //    obj3.charValue = CHAR_MIN;
     obj3.shortValue = SHRT_MIN;
     obj3.intValue = INT32_MIN;
     obj3.longValue = LONG_MIN;
     obj3.longLongValue = LLONG_MIN;
     obj3.uCharValue = 0;
     obj3.uShortValue = 0;
     obj3.uIntValue = 0;
     obj3.uLongValue = 0;
     obj3.uLongLongValue = 0;
     obj3.doubleValue = DBL_MIN;
     obj3.floatValue = FLT_MIN;
     
     [context insertObjects:@[obj1, obj2, obj3]];
     //*/
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self clearAll:nil];
//    });
    
    
    
}



- (IBAction)onOCTest:(id)sender {
    dispatch_queue_t queue = dispatch_queue_create("MyQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_t group2 = dispatch_group_create();
    
    // Add a task to the group
    dispatch_group_async(group, queue, ^{
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 10; i++) {
                NSLog(@"Counting: %d", i);
                [NSThread sleepForTimeInterval:0.5];
            }
        });
    });
    
    // Add a task to the group
    dispatch_group_async(group2, queue, ^{
        for (int i = 0; i < 10; i++) {
            NSLog(@"Another Counting: %d", i);
            [NSThread sleepForTimeInterval:1];
        }
    });
    
    // Do some other work while the tasks execute.
    
    // When you cannot make any more forward progress,
    // wait on the group to block the current thread.
    NSLog(@"dispatch_group_wait:1");
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"dispatch_group_wait:2");
    dispatch_group_wait(group2, DISPATCH_TIME_FOREVER);
    
    NSLog(@"start dispatch Sync");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHaha:) name:@"haha" object:nil];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (int i = 0; i < 10; i++) {
                NSLog(@"Sync Counting: %d", i);
                [NSThread sleepForTimeInterval:0.5];
            }
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haha" object:@"I'm Here!!!"];
    });
    
    NSLog(@"dispatch_release");
    // Release the group when it is no longer needed.
    dispatch_release(group);
    dispatch_release(group2);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)onHaha:(NSNotification *)notification {
    NSString *obj = notification.object;
    NSLog(@"get: %@", obj);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"haha: %d", i);
            [NSThread sleepForTimeInterval:0.5];
        }
    });
}


- (void)printThread:(NSString *)tag {
    NSString *threadId = [NSString stringWithFormat:@"%p", [NSThread currentThread]];
    BOOL duplicated = [self.threadIds containsObject:threadId];
    if ([tag isEqualToString:@"main"] || [tag isEqualToString:@"oper"] || [tag isEqualToString:@"seri"]) {
        duplicated = NO;
    }
    [self.threadIds addObject:threadId];
    NSLog(@"%d\tThread-%@: %@ %@", self.threadIds.count, tag, threadId, duplicated ? @"(Duplicated)" : @"");
    
}


- (IBAction)clearAll:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
    for (NSString *file in files) {
        NSString *filePath = [documentPath stringByAppendingPathComponent:file];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error;
            [fileManager removeItemAtPath:filePath error:&error];
            if (!error) {
                [self log:[NSString stringWithFormat:@"Delete: %@", file]];
                
            } else {
                NSLog(@"Delete Error: %@", error);
            }
        }
    }
}

/**
 - (IBAction)onOCTest:(id)sender {
 
 // test thead name
 dispatch_queue_t serialQueue = dispatch_queue_create("SerialQueue", DISPATCH_QUEUE_SERIAL);
 dispatch_queue_t concurrentQueue = dispatch_queue_create("ConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
 NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
 
 dispatch_async(dispatch_get_main_queue(), ^{
 [self printThread:@"main"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self printThread:@"deft"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
 [self printThread:@"high"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
 [self printThread:@"back"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
 [self printThread:@"low"];
 });
 NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
 [self printThread:@"oper"];
 }];
 [operationQueue addOperation:operation1];
 dispatch_async(serialQueue, ^{
 [self printThread:@"seri"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self printThread:@"deft"];
 });
 dispatch_async(concurrentQueue, ^{
 [self printThread:@"conc"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
 [self printThread:@"high"];
 });
 dispatch_async(concurrentQueue, ^{
 [self printThread:@"conc"];
 });
 NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
 [self printThread:@"oper"];
 }];
 [operationQueue addOperation:operation2];
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
 [self printThread:@"back"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
 [self printThread:@"high"];
 });
 dispatch_async(dispatch_get_main_queue(), ^{
 [self printThread:@"main"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
 [self printThread:@"back"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
 [self printThread:@"low"];
 });
 dispatch_async(serialQueue, ^{
 [self printThread:@"seri"];
 });
 NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
 [self printThread:@"oper"];
 }];
 [operationQueue addOperation:operation3];
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
 [self printThread:@"high"];
 });
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self printThread:@"deft"];
 });
 }
 */

- (void)_dbTest01 {
    CEDatabase *db = [CEDatabase databaseWithName:@"hohoho"];
    CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:db];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < 100; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            //            XCTAssert([context insert:obj]);
            NSLog(@"Insert: %@", obj.value);
            [context insert:obj error:nil];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 100; i < 200; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            //            XCTAssert([context insert:obj]);
            NSLog(@"Insert: %@", obj.value);
            [context insert:obj error:nil];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        CEDatabaseContext *context = [CEDatabaseContext contextWithTableName:[[CustomKeyObject class] description] class:[CustomKeyObject class] inDatabase:db];
        for (int i = 200; i < 300; i++) {
            CustomKeyObject *obj = [CustomKeyObject new];
            obj.value = [NSString stringWithFormat:@"obj_%d", i];
            //            XCTAssert([context insert:obj]);
            NSLog(@"Insert: %@", obj.value);
            [context insert:obj error:nil];
        }
    });
}

@end

