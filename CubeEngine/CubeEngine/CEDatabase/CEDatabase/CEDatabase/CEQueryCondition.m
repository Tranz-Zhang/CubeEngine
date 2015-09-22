//
//  CEQueryCondition.m
//  CEDatabase
//
//  Created by chancezhang on 14-7-30.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import "CEQueryCondition.h"
#import "CEDatabasePrivateCommon.h"

#define WHERE_ARGUMENTS_PREFIX @"__where_arg_"

static NSRegularExpression *_valueBlockRegex; // [=><]\s*.*
static NSRegularExpression *_blankPrefixRegex; // [=><]\s*

@implementation CEQueryCondition
- (instancetype)init
{
    self = [super init];
    if (self) {
        _argumentsDict = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return self;
}

/** 设置查询条件 */
- (void)setConditionWithFormat:(NSString *)formatCondition, ... {
    // clean up
    [_argumentsDict removeAllObjects];
    _whereCmd = nil;
    if (!formatCondition) return;
    
    // setup confition
    formatCondition = [formatCondition stringByReplacingOccurrencesOfString:@"==" withString:@" = "];
    formatCondition = [formatCondition stringByReplacingOccurrencesOfString:@"&&" withString:@" AND "];
    formatCondition = [formatCondition stringByReplacingOccurrencesOfString:@"||" withString:@" OR "];
    formatCondition = [formatCondition stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    int argumentCount = 0;
    NSMutableString *cmd = [NSMutableString stringWithFormat:@"WHERE %@", formatCondition];
    // 查找formatCondition中的%@字符，替换成sqlite索引字段
    NSRange searchRange = NSMakeRange(0, cmd.length);
    while (searchRange.location != NSNotFound) {
        NSRange argRange = [cmd rangeOfString:@"%@" options:0 range:searchRange];
        if (argRange.location != NSNotFound) {
            [cmd replaceCharactersInRange:argRange
                               withString:[NSString stringWithFormat:@":%@%d", WHERE_ARGUMENTS_PREFIX, argumentCount]];
            argumentCount++;
        }
        searchRange = NSMakeRange(NSMaxRange(argRange), cmd.length - NSMaxRange(argRange));
    }
    
    // get argument list
    va_list args;
    va_start(args, formatCondition);
    NSArray *argumentList = [self getArgumentList:args argumentCount:argumentCount];
    va_end(args);
    
    if (argumentList.count != argumentCount) { //错误：参数不匹配
        CEDatabaseLog(@"CEQueryCondition ERROR: Arguments does not match!!!");
        return;
    }
    
    NSMutableDictionary *argumentDict = [NSMutableDictionary dictionary];
    for(int i = 0; i < argumentCount; i++) {
        NSString *key = [NSString stringWithFormat:@"%@%d", WHERE_ARGUMENTS_PREFIX, i];
        [argumentDict setObject:argumentList[i] forKey:key];
    }
    _argumentsDict = argumentDict;
    _whereCmd = cmd.copy;
    
//    NSLog(@"QueryCondition:%@\n%@", _whereCmd, _argumentsDict);
}

- (NSArray *)getArgumentList:(va_list)args argumentCount:(int)count{
    NSMutableArray *argList = [NSMutableArray array];
    id arg = nil;
    for (int i = 0; i < count; i++) {
        arg = va_arg(args, id);
        
        /*
         除去NSString, NSData, NSDate, NSNumber外其余OC类型转成NSData
         */
        if ([arg isKindOfClass:[NSString class]] ||
            [arg isKindOfClass:[NSData class]] ||
            [arg isKindOfClass:[NSDate class]] ||
            [arg isKindOfClass:[NSNumber class]]) {
            [argList addObject:arg];
            
        } else {
            NSData *argData = [NSKeyedArchiver archivedDataWithRootObject:arg];
            [argList addObject:argData];
        }
    }
    return argList.copy;
}


- (NSString *)processConditionCmd:(NSString *)conditionCmd {
    if (!conditionCmd.length) return nil;
    
    NSMutableString *cmd = conditionCmd.mutableCopy;
    
    NSRange valueBlockRange = [[self valueBlockRegex] rangeOfFirstMatchInString:cmd options:0 range:NSMakeRange(0, cmd.length)];
    if (valueBlockRange.location == NSNotFound) return nil;
    
    
    return nil;
}


- (NSRegularExpression *)valueBlockRegex {
    if (!_valueBlockRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *regex = @"[=><]\\s*.*";
            NSError *error;
            _valueBlockRegex = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
            if (error) {
                CEDatabaseLog(@"NSRegularExpression Error:%@", error);
                _valueBlockRegex = nil;
            }
        });
    }
    return _valueBlockRegex;
}


- (NSRegularExpression *)blankPrefixRegex {
    if (!_blankPrefixRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *regex = @"[=><]\\s*";
            NSError *error;
            _blankPrefixRegex = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
            if (error) {
                CEDatabaseLog(@"NSRegularExpression Error:%@", error);
                _blankPrefixRegex = nil;
            }
        });
    }
    return _blankPrefixRegex;
}



/** 设置排序 */
- (void)setSortOrderWithProperties:(NSArray *)peoperties isAscending:(BOOL)accending {
    _orderCmd = nil;
    if (!peoperties.count) return;
    
    NSMutableString *cmd = [NSMutableString stringWithString:@"ORDER BY "];
    for (NSString *propertyName in peoperties) {
        [cmd appendString:propertyName];
        if (propertyName != peoperties.lastObject) {
            [cmd appendString:@", "];
        }
    }
    [cmd appendString:accending ? @" ASC" : @" DESC"];
    _orderCmd = cmd.copy;
}


// 设置查询范围
- (void)setRange:(NSRange)range {
    _limitCmd = nil;
    
    NSMutableArray *cmds = [NSMutableArray arrayWithCapacity:2];
    // add limit
    if (range.length != CENotUsed) {
        [cmds addObject:[NSString stringWithFormat:@"LIMIT %lu", (unsigned long)range.length]];
    }
    // add offset
    if (range.location != CENotUsed &&
        range.location != 0) {
        [cmds addObject:[NSString stringWithFormat:@"OFFSET %lu", (unsigned long)range.location]];
    }
    _limitCmd = cmds.count ? [cmds componentsJoinedByString:@" "] : nil;
}



@end


