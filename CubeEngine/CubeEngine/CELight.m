//
//  CELight.m
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"
#import "CEUtils.h"
#import "CELight_Rendering.h"

static NSInteger kMaxLightCount = 8;

@implementation CELight

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setLightColor:[UIColor whiteColor]];
        [self setAmbientColor:[UIColor colorWithWhite:0.1 alpha:1]];
    }
    return self;
}

+ (NSUInteger)maxLightCount {
    return kMaxLightCount;
}

+ (void)setMaxLightCount:(NSInteger)maxLightCount {
    if (maxLightCount > 0) {
        kMaxLightCount = maxLightCount;
    }
}

- (void)setUniformInfo:(CELightUniformInfo *)uniformInfo {
    if (_uniformInfo != uniformInfo) {
        _uniformInfo = uniformInfo;
        _hasLightChanged = YES;
    }
}

- (void)setLightColor:(UIColor *)lightColor {
    if (_lightColor != lightColor) {
        _lightColor = [lightColor copy];
        _lightColorV3 = CEVec3WithColor(lightColor);
        _hasLightChanged = YES;
    }
}

- (void)setAmbientColor:(UIColor *)ambientColor {
    if (_ambientColor != ambientColor) {
        _ambientColor = [ambientColor copy];
        _ambientColorV3 = CEVec3WithColor(ambientColor);
        _hasLightChanged = YES;
    }
}

- (void)setPosition:(GLKVector3)position {
    _hasChanged = !GLKVector3AllEqualToVector3(_position, position);
    [super setPosition:position];
}

- (void)updateUniforms {
    // MUST IMPLEMENT BY SUBCLASS
}


@end
