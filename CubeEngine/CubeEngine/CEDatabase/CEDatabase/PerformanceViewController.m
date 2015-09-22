//
//  PerformanceViewController.m
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-8-12.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <objc/runtime.h>
#import "PerformanceViewController.h"

@interface TestData : CEManagedObject

BIND_OBJECT_ID(string)
@property (nonatomic) NSInteger key;

// OC Type
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSSet *set;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSValue *value;
@property (nonatomic, strong) NSData *data;

// C Type
@property BOOL boolValue;
//@property char charValue; // 不支持！！！
@property short shortValue;
@property int intValue;
@property long longValue;
@property long long longLongValue;

@property unsigned char uCharValue;
@property unsigned short uShortValue;
@property unsigned int uIntValue;
@property unsigned long uLongValue;
@property unsigned long long uLongLongValue;

@property double doubleValue;
@property float floatValue;

@end

@implementation TestData

@end




@interface PerformanceViewController ()
@property (assign, nonatomic) NSUInteger benchmarkCount;
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UILabel *benchmarkLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) CEDatabase *db;
@property (strong, nonatomic) CEDatabaseContext *context;
@property (nonatomic, assign) dispatch_queue_t queue;

@end

@implementation PerformanceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.db = [CEDatabase databaseWithName:@"Benchmark"];
    self.context = [CEDatabaseContext contextWithTableName:[[TestData class] description]
                                                      class:[TestData class]
                                                 inDatabase:self.db];
    self.queue = dispatch_queue_create("benchmark", DISPATCH_QUEUE_SERIAL);
    self.benchmarkCount = 100;
    self.segment.selectedSegmentIndex = 1;
    
    [self log:@"CEDatabase Performance Test"];
    [self log:@"-------------------------------------\n TestObjectInfo:"];
    u_int count;
    class_copyPropertyList([TestData class], &count);
    [self log:[NSString stringWithFormat:@"Class: [%@]\nPropertyCount: [%d]", [[TestData class] description], count]];
    
}

- (void)dealloc {
    dispatch_release(self.queue);
    self.queue = nil;
    
    [CEDatabase removeDatabase:self.db.name error:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)onSegmentChange:(UISegmentedControl *)segment {
    switch (segment.selectedSegmentIndex) {
        case 0:
            _benchmarkCount = 50;
            break;
        case 1:
            _benchmarkCount = 100;
            break;
        case 2:
            _benchmarkCount = 1000;
            break;
        default:
            break;
    }
    self.benchmarkLabel.text = [NSString stringWithFormat:@"Benchmark Count: %d", _benchmarkCount];
}



- (IBAction)onStartTest:(id)sender {
    
    
    [self log:[NSString stringWithFormat:@"\n-------------- Start Test --------------\nBenchmark Count: %d\n", _benchmarkCount]];
    
    [self testInsert];
    [self testTransitionInsert];
    
    [self testUpdate];
    [self testTransitionUpdate];
    
    [self testQuery];
    
    [self testRemove];
    [self testTransitionRemove];
    
    dispatch_async(self.queue, ^{
        [self.context removeAllObjectsWithError:nil];
        [self log:@"Clear Table"];
    });
}


- (void)testInsert {
    dispatch_async(self.queue, ^{
        [self log:@"Test Insert..."];
        
        CFTimeInterval accumulatedTime = 0;
        for (int i = 0; i < _benchmarkCount; i++) {
            TestData *obj = [self generateTestObject:i];
            // 排除obj创建时间
            CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
            [self.context insert:obj error:nil];
            accumulatedTime += (CFAbsoluteTimeGetCurrent() - startTime);
        }
        
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", accumulatedTime * 1000]];
    });
}


- (void)testTransitionInsert {
    dispatch_async(self.queue, ^{
        [self log:@"Test Transition Insert..."];
        
        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:_benchmarkCount];
        for (int i = _benchmarkCount; i < _benchmarkCount * 2; i++) {
            TestData *obj = [self generateTestObject:i];
            // 排除obj创建时间
            [objects addObject:obj];
        }
        CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
        [self.context insertObjects:objects error:nil];
        CFTimeInterval duration = CFAbsoluteTimeGetCurrent() - startTime;
        
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", duration * 1000]];
    });
}


- (void)testUpdate {
    dispatch_async(self.queue, ^{
        [self log:@"Start Update..."];
        CFTimeInterval accumulatedTime = 0;
        
        NSArray *objects = [self.context queryAllWithError:nil];
        for (TestData *obj in objects) {
            obj.string = [obj.string stringByAppendingString:@"_Modified"];
            // 排除obj修改时间
            CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
            [self.context update:obj error:nil];
            accumulatedTime += CFAbsoluteTimeGetCurrent() - startTime;
        }
        
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", accumulatedTime * 1000]];
    });
}


- (void)testTransitionUpdate {
    dispatch_async(self.queue, ^{
        [self log:@"Start Transition Update..."];
        
        NSArray *objects = [self.context queryAllWithError:nil];
        for (TestData *obj in objects) {
            obj.string = [obj.string stringByAppendingString:@"_Modified"];
        }
        CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
        [self.context updateObjects:objects error:nil];
        
        CFTimeInterval duration = CFAbsoluteTimeGetCurrent() - startTime;
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", duration * 1000]];
    });
}


- (void)testQuery{
    dispatch_async(self.queue, ^{
        CFTimeInterval accumulatedTime = 0;
        NSUInteger testCount = MIN(_benchmarkCount / 10, 100);
        // Query All
        [self log:@"Test Query All..."];
        accumulatedTime = 0;
        for (int i = 0; i < testCount; i++) {
            accumulatedTime += [self testQueryAll];
        }
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", accumulatedTime * 1000 / testCount]];
        
        // Query By ID
        [self log:@"Test Query By ID..."];
        accumulatedTime = 0;
        for (int i = 0; i < testCount; i++) {
            accumulatedTime += [self testQueryById];
        }
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", accumulatedTime * 1000 / testCount]];
        
        // Query Condition
        [self log:@"Test Query Condition..."];
        accumulatedTime = 0;
        for (int i = 0; i < testCount; i++) {
            accumulatedTime += [self testQueryCondition];
        }
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", accumulatedTime * 1000 / testCount]];
    });
}

- (IBAction)onClear:(id)sender {
    self.logView.text = @"";
}

- (CFAbsoluteTime)testQueryAll {
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    [self.context queryAllWithError:nil];
    return CFAbsoluteTimeGetCurrent() - startTime;
}


- (CFAbsoluteTime)testQueryById {
    NSInteger randomID = arc4random() % _benchmarkCount;
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    [self.context queryById:@(randomID) error:nil];
    return CFAbsoluteTimeGetCurrent() - startTime;
}


- (CFAbsoluteTime)testQueryCondition {
    NSInteger randomIndex = arc4random() % (_benchmarkCount / 3);
    CEQueryCondition *condition = [CEQueryCondition new];
    [condition setRange:NSMakeRange(randomIndex, randomIndex)];
    [condition setConditionWithFormat:@"intValue >= %@", @(randomIndex)];
    [condition setSortOrderWithProperties:@[@"intValue"] isAscending:NO];
    
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    [self.context queryByCondition:condition error:nil];
    return CFAbsoluteTimeGetCurrent() - startTime;
}


- (void)testRemove {
    dispatch_async(self.queue, ^{
        // fill db
        NSArray *objects = [self.context queryAllWithError:nil];
        if (objects.count != _benchmarkCount) {
            [self.context removeAllObjectsWithError:nil];
            NSMutableArray *insertObjects = [NSMutableArray arrayWithCapacity:_benchmarkCount];
            for (int i = 0; i < _benchmarkCount; i++) {
                TestData *obj = [self generateTestObject:i];
                [insertObjects addObject:obj];
            }
            [self.context insertObjects:insertObjects error:nil];
            objects = [self.context queryAllWithError:nil];
        }
        
        [self log:@"Start Remove"];
        CFTimeInterval accumulatedTime = 0;
        
        for (TestData *obj in objects) {
            // 排除obj修改时间
            CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
            [self.context remove:obj error:nil];
            accumulatedTime += CFAbsoluteTimeGetCurrent() - startTime;
        }
        
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", accumulatedTime * 1000]];
    });
}


- (void)testTransitionRemove {
    dispatch_async(self.queue, ^{
        // fill db
        NSArray *objects = [self.context queryAllWithError:nil];
        if (objects.count != _benchmarkCount) {
            [self.context removeAllObjectsWithError:nil];
            NSMutableArray *insertObjects = [NSMutableArray arrayWithCapacity:_benchmarkCount];
            for (int i = 0; i < _benchmarkCount; i++) {
                TestData *obj = [self generateTestObject:i];
                [insertObjects addObject:obj];
            }
            [self.context insertObjects:insertObjects error:nil];
            objects = [self.context queryAllWithError:nil];
        }
        
        CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
        [self log:@"Start Transition Remove"];
        [self.context removeObjects:objects error:nil];
        CFTimeInterval duration = CFAbsoluteTimeGetCurrent() - startTime;
        [self log:[NSString stringWithFormat:@"DURATION: %.3fms\n", duration * 1000]];
    });
}


- (TestData *)generateTestObject:(NSInteger)key {
    TestData *obj = [TestData new];
    obj.key = key;
    obj.string = [NSString stringWithFormat:@"obj_%d", key];
    obj.array = @[@"1", @"2", @"3"];
    obj.dictionary = @{@"a" : @"apple"};
    obj.set = [NSSet setWithObjects:@"8", @"5", @"3", nil];
    obj.number = @(123123.345457);
    obj.value = [NSValue valueWithCGPoint:CGPointMake(123, 234)];
//    UIImage *image = [UIImage imageNamed:@"colorful"];
//    obj.data = UIImagePNGRepresentation(image);
    obj.boolValue = YES;
    obj.shortValue = SHRT_MAX;
    obj.intValue = key;
    obj.longValue = LONG_MAX;
    obj.longLongValue = LLONG_MAX;
    obj.uCharValue = UCHAR_MAX;
    obj.uShortValue = USHRT_MAX;
    obj.uIntValue = UINT32_MAX;
    obj.uLongValue = ULONG_MAX;
    obj.uLongLongValue = ULLONG_MAX;
    obj.doubleValue = DBL_MAX;
    obj.floatValue = FLT_MAX;
    
    return obj;
}


- (void)log:(NSString *)logInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *info = [NSMutableString stringWithString:self.logView.text];
        [info appendFormat:@"%@\n", logInfo];
        self.logView.text = info;
        [self.logView scrollRangeToVisible:NSMakeRange(info.length - 1, 1)];
    });
}

@end


