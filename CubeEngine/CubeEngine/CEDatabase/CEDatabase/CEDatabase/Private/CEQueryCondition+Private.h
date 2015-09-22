 //
//  CEQueryCondition+Private.h
//  CEDatabase
//
//  Created by chancezhang on 14-8-5.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import "CEQueryCondition.h"

@interface CEQueryCondition (Private)

// 获取查询条件sqlite语句
- (NSString *)getCmd;

// 获取sqlite语句参数
- (NSDictionary *)getArgumentDict;

@end
