//
//  CEDatabaseObject.m
//  CEDatabase
//
//  Created by chancezhang on 14-8-1.
//  Copyright (c) 2014年 Bychance. All rights reserved.
//

#import <objc/runtime.h>
#import "CEManagedObject.h"

static NSDictionary *_propertyNamesDict;

@implementation CEManagedObject

- (id)initWithCoder:(NSCoder *)aDecoder {
    // get properties
    if (self = [super init]) {
        NSSet *properties = [self allProperties];
        for (NSString *propertyName in properties) {
            id decodedObject = [aDecoder decodeObjectForKey:propertyName];
            [self setValue:decodedObject forKey:propertyName];
        }
        
    }
    
    return self;
}



- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSSet *properties = [self allProperties];
    for (NSString *propertyName in properties) {
        id encodeObject = [self valueForKey:propertyName];
        [aCoder encodeObject:encodeObject forKey:propertyName];
    }
}


- (NSSet *)allProperties {
    NSMutableSet *properties = [NSMutableSet set];
    Class clazz = [self class];
    while ([clazz isSubclassOfClass:[CEManagedObject class]]) {
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


@end
