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

- (instancetype)initWithName:(NSString *)name{
    self = [super init];
    if (self) {
        _name = [name copy];
        _index = -1;
    }
    return self;
}

- (NSString *)dataType {
    NSAssert(false, @"Must implemented by subclass");
    return nil;
}


- (BOOL)setupIndexWithProgram:(CEProgram *)program {
    NSAssert(false, @"Must implemented by subclass");
    return NO;
}


@end
