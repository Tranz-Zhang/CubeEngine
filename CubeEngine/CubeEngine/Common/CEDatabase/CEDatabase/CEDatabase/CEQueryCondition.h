//
//  CEQueryCondition.h
//  CEDatabase
//
//  Created by chancezhang on 14-7-30.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 数据库查询条件
 */

@interface CEQueryCondition : NSObject {
    NSString *_whereCmd;
    NSString *_orderCmd;
    NSString *_limitCmd;
    NSMutableDictionary *_argumentsDict;
}

/** 
 设置查询条件

 1.支持的操作符有:>, <, ==, >=, <=

 2.两个条件之间可以用 && 或 || 组合起来

 3.只支持Objective-C类型的对比，例如数字类参数必须转换成NSNumber
 
 @code
 // 普通写法
 [...Format:@"stringValue == %@", @"hello"];
 
 // 多条件写法
 [...Format:@"stringValue == %@ && numValue >= %@", @"hello", @(123)];
 
 // 以NSArray, NSDictionary, NSValue, NSData等为参数
 [...Format:@"array_property == %@", @[@"array1", @"array2"]];
 
 // 若不使用%@，则在对比字符时须添加''
 [...Format:@"stringValue == 'string' && intValue = 1"];
 @endcode
 */
- (void)setConditionWithFormat:(NSString *)formatCondition, ... NS_FORMAT_FUNCTION(1,2);


/** 
 设置排序
 @param properties 排序属性名称,有优先级
 @param isAscending 排序顺序 YES:升序 NO:降序
 */

- (void)setSortOrderWithProperties:(NSArray *)peoperties isAscending:(BOOL)accending;


/** 设置查询范围
 在符合查询条件的数据中按range限制查询结果的范围
 
 @param range.location 查询结果的起始位置,即偏移值，不需要时填写CENotUsed
 @param range.length 查询结果长度，不需要时填写CENotUsed
 */
enum {CENotUsed = NSIntegerMax};
- (void)setRange:(NSRange)range;


@end



