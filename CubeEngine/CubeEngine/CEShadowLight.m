//
//  CEShadowLight.m
//  CubeEngine
//
//  Created by chance on 6/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowLight.h"
#import "CEShadowLight_Rendering.h"

@implementation CEShadowLight

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shadowDarkness = 0.5;
    }
    return self;
}

- (void)setEnableShadow:(BOOL)enableShadow {
    if (_enableShadow != enableShadow) {
        _enableShadow = enableShadow;
        if (enableShadow && !_shadowMapBuffer) {
            _shadowMapBuffer = [[CEShadowMapBuffer alloc] initWithTextureSize:CGSizeMake(kDefaultTextureSize, kDefaultTextureSize)];
            
        } else if (!enableShadow && _shadowMapBuffer) {
            _shadowMapBuffer = nil;
        }
    }
}


- (void)setShadowDarkness:(float)shadowDarkness {
    _shadowDarkness = MIN(MAX(shadowDarkness, 0.0), 1.0);
}


@end
