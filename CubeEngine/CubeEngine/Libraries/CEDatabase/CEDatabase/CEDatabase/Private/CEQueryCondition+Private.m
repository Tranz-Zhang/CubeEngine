//
//  CEQueryCondition+Private.m
//  CEDatabase
//
//  Created by chancezhang on 14-8-5.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import "CEQueryCondition+Private.h"

@implementation CEQueryCondition (Private)

// 获取查询条件sqlite语句
- (NSString *)getCmd {
    NSMutableArray *cmds = [NSMutableArray arrayWithCapacity:3];
    if (_whereCmd) [cmds addObject:_whereCmd];
    if (_orderCmd) [cmds addObject:_orderCmd];
    if (_limitCmd) [cmds addObject:_limitCmd];
    return cmds.count ? [cmds componentsJoinedByString:@" "] : nil;
}

// 获取sqlite语句参数
- (NSDictionary *)getArgumentDict {
    return _argumentsDict.count ? _argumentsDict.copy : nil;
}

@end
