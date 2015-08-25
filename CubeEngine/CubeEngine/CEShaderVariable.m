//
//  CEShaderVariable.m
//  CubeEngine
//
//  Created by chance on 8/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderVariable

- (instancetype)initWithName:(NSString *)name precision:(NSString *)precision {
    self = [super init];
    if (self) {
        _name = [name copy];
        _precision = precision;
        _index = -1;
    }
    return self;
}

- (NSString *)declaration {
    NSAssert(false, @"Must implemented by subclass");
    return nil;
}


@end
