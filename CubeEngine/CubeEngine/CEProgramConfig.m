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
    int hashValue = 0;
    
    //8bit for bool property
    hashValue += (_enableTexture ? 1 : 0) << 0;
    hashValue += (_enableNormalMapping ? 1 : 0) << 1;
    hashValue += (_enableShadowMapping ? 1 : 0) << 2;
    // 6 x 4bit for value property
    hashValue += _lightCount & 0x000F << 8;
    return hashValue;
}


- (BOOL)isEqualToConfig:(CEProgramConfig *)config {
    return (config.lightCount == _lightCount &&
            config.enableShadowMapping == _enableShadowMapping &&
            config.enableTexture == _enableTexture &&
            config.enableNormalMapping == _enableNormalMapping);
}


@end