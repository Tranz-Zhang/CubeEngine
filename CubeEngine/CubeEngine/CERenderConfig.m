//
//  CERenderConfig.m
//  CubeEngine
//
//  Created by chance on 9/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderConfig.h"

@implementation CERenderConfig

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[CERenderConfig class]]) {
        return [self isEqualToConfig:object];
        
    } else {
        return NO;
    }
}


- (id)copyWithZone:(NSZone *)zone {
    CERenderConfig *copiedConfig = [[CERenderConfig allocWithZone:zone] init];
    copiedConfig.lightType = _lightType;
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
    hashValue += _lightType & 0x000F << 12;
    return hashValue;
}


- (BOOL)isEqualToConfig:(CERenderConfig *)config {
    return (config.lightType == _lightType &&
            config.enableShadowMapping == _enableShadowMapping &&
            config.enableTexture == _enableTexture &&
            config.enableNormalMapping == _enableNormalMapping);
}


@end
