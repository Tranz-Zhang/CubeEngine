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



@end
