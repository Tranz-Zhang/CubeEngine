//
//  CEDatabaseObject.h
//  CEDatabase
//
//  Created by chancezhang on 14-8-1.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BIND_OBJECT_ID(x) @property (nonatomic, assign) BOOL _binded_object_id_##x;
#define TABLE_VERSION(x) @property (nonatomic, assign) BOOL _table_version_##x;

/**
 数据库对象基类
 
 使用本数据库时必须继承CEDatabaseObject，CEDatabaseContext以子类中的property为数据库表的列名进行存储.
 
 @code
    例子：
    
    @interface MyObject : CEDatabaseObject

    BIND_OBJECT_ID(name) // 绑定name为关键字
    @property (strong) NSString *name;
    @property (strong) NSString *description;

    @end
    
    MyObject对应的表为:
 
           MyObject
     --------------------
    | name | description |
     --------------------
    | @“X” | @"XXXXXXXX" |
    ...
 
 @endcode
 
 */

@interface CEManagedObject : NSObject <NSCoding>

/**
 对象唯一标识，默认情况为自动赋值的NSNumber。
 
 可使用BIND_OBJECT_ID(property_name)将一个属性绑定到objectID，此时objectID的值为该属性的值
 @warning 使用BIND_OBJECT_ID()绑定的属性，必须为非空并且不能重复
 */
@property (nonatomic, readonly) id objectID;

- (NSSet *)allProperties;

@end







