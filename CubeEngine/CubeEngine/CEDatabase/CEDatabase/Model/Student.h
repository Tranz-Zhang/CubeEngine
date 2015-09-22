//
//  Student.h
//  FMDatabaseDevelopment
//
//  Created by chancezhang on 14-7-29.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import "CEManagedObject.h"
#import <objc/runtime.h>


@interface Student : CEManagedObject

@property (nonatomic, strong) NSString *name DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSMutableString *mutableString;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSNumber *number;

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat grade;

@property BOOL boolValue;
@property char charValue;
@property short shortValue;
@property long longValue;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) int intValue;
@property (nonatomic, assign) long long longLongValue;
@property (nonatomic, assign) float floatValue;
@property (nonatomic, assign) unsigned int unsignedIntValue;
@property (nonatomic, assign) unsigned long long unsignedLongLongValue;

@end




