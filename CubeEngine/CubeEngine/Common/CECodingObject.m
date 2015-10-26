//
//  CECodingObject.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <objc/runtime.h>
#import "CECodingObject.h"

static NSDictionary *_propertyNamesDict;

@implementation CECodingObject

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    // get properties
    if (self = [super init]) {
        NSSet *properties = [self allProperties];
        @try {
            for (NSString *propertyName in properties) {
                id decodedObject = [aDecoder decodeObjectForKey:propertyName];
                [self setValue:decodedObject forKey:propertyName];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSSet *properties = [self allProperties];
    @try {
        for (NSString *propertyName in properties) {
            id encodeObject = [self valueForKey:propertyName];
            [aCoder encodeObject:encodeObject forKey:propertyName];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}


- (NSSet *)allProperties {
    NSMutableSet *properties = [NSMutableSet set];
    Class clazz = [self class];
    while ([clazz isSubclassOfClass:[CECodingObject class]]) {
        [properties unionSet:[self propertyNamesInClass:clazz]];
        clazz = [clazz superclass];
    }
    return properties;
}


- (NSSet *)propertyNamesInClass:(Class)clazz {
    NSSet *propertyNames = _propertyNamesDict[[clazz description]];
    if (propertyNames) {
        return propertyNames;
    }
    
    // get property names
    if (!_propertyNamesDict) {
        _propertyNamesDict = [NSMutableDictionary dictionary];
    }
    
    u_int count;
    objc_property_t* propertyArray = class_copyPropertyList(clazz, &count);
    NSMutableSet *properties = [NSMutableSet setWithCapacity:count];
    for (int i = 0; i < count; i++) {
        const char* cPropertyName = property_getName(propertyArray[i]);
        NSString *propertyName = [NSString stringWithCString:cPropertyName encoding:NSUTF8StringEncoding];
        [properties addObject:propertyName];
    }
    
    propertyNames = properties.copy;
    [_propertyNamesDict setValue:propertyNames forKey:[clazz description]];
    return propertyNames;
}


#pragma mark - Archive
// 从指定文件读取类
+ (instancetype)objectFromFile:(NSString *)filePath {
    if (!filePath.length) return nil;
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}


// 保存到指定文件
- (BOOL)saveToFile:(NSString *)filePath {
    if (!filePath.length) return NO;
    return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}


@end

