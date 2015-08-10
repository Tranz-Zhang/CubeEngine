//
//  CEShaderStruct.m
//  CubeEngine
//
//  Created by chance on 8/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderStruct.h"

@implementation CEShaderStruct

+ (instancetype)structWithName:(NSString *)name variables:(NSArray *)variables {
    if (!name.length || !variables.count) {
        return nil;
    }
    return [[CEShaderStruct alloc] initWithName:name variables:variables];
}


- (instancetype)initWithName:(NSString *)name variables:(NSArray *)variables {
    self = [super init];
    if (self) {
        _name = [name copy];
        _variables = [variables copy];
    }
    return self;
}

@end
