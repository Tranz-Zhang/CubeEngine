//
//  CEMainProgram.m
//  CubeEngine
//
//  Created by chance on 5/20/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMainProgram.h"
#import "CEShaders.h"

@implementation CEMainProgram

+ (instancetype)programWithConfig:(CEProgramConfig *)config {
    return [[[self class] alloc] initWithConfig:config];
}


- (instancetype)initWithConfig:(CEProgramConfig *)config {
    self = [super init];
    if (self) {
        _config = [config copy];
        [self setupProgram];
    }
    return self;
}


- (void)setupProgram {
    
}


#pragma mark - Parse Shaders
- (NSString *)vertexShaderWithConfig:(CEProgramConfig *)config {
    return nil;
}


- (NSString *)fragmentShaderWithConfig:(CEProgramConfig *)config {
    return nil;
}


@end

