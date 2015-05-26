//
//  CEProgramConfig.m
//  CubeEngine
//
//  Created by chance on 5/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEProgramConfig.h"

@implementation CEProgramConfig

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[CEProgramConfig class]]) {
        return [self isEqualToConfig:object];
        
    } else {
        return NO;
    }
}


- (id)copyWithZone:(NSZone *)zone {
    CEProgramConfig *copiedConfig = [[CEProgramConfig allocWithZone:zone] init];
    copiedConfig.lightCount = _lightCount;
    copiedConfig.enableShadowMapping = _enableShadowMapping;
    copiedConfig.enableNormalMapping = _enableNormalMapping;
    copiedConfig.enableTexture = _enableTexture;
    return copiedConfig;
}


- (NSUInteger)hash {
    NSUInteger hashValue = _lightCount * 1000;
    hashValue += _enableTexture ? 100 : 0;
    hashValue += _enableShadowMapping ? 10 : 0;
    hashValue += _enableNormalMapping ? 1 : 0;
    return hashValue;
}


- (BOOL)isEqualToConfig:(CEProgramConfig *)config {
    return (config.lightCount == _lightCount &&
            config.enableTexture == _enableTexture &&
            config.enableShadowMapping == _enableShadowMapping &&
            config.enableNormalMapping == _enableNormalMapping);
}


@end
