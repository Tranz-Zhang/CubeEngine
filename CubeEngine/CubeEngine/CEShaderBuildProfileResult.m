//
//  CEShaderBuildContainer.m
//  CubeEngine
//
//  Created by chance on 9/2/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderBuildProfileResult.h"

@implementation CEShaderBuildProfileResult

- (instancetype)init {
    self = [super init];
    if (self) {
        _attributes = [NSMutableArray array];
        _uniforms = [NSMutableArray array];
        _varyings = [NSMutableArray array];
        _structs = [NSMutableArray array];
    }
    return self;
}

@end
