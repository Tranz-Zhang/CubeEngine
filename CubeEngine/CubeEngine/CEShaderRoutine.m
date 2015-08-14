//
//  CEShaderRoutine.m
//  CubeEngine
//
//  Created by chance on 8/11/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderRoutine.h"

@implementation CEShaderRoutine

- (instancetype)init {
    self = [super init];
    if (self) {
        _subRoutines = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Methods which can be implemented by subclass

- (NSString *)vertexShaderVariables {
    return nil;
}

- (NSString *)vertexShaderImplementation {
    return nil;
}


- (NSString *)fragmentShaderVariables {
    return nil;
}

- (NSString *)fragmentShaderImplementation {
    return nil;
}


- (void)addSubRoutine:(CEShaderRoutine *)subRoutine {
    if (subRoutine) {
        [_subRoutines addObject:subRoutine];
    }
}



@end






