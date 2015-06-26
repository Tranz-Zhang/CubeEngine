//
//  CEShadowLight.h
//  CubeEngine
//
//  Created by chance on 6/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"

// light which able to cast shadow
@interface CEShadowLight : CELight {
    GLKMatrix4 _lightViewMatrix;
    GLKMatrix4 _lightProjectionMatrix;
}

// indicates if this light cast shadow on objects
@property (nonatomic, assign) BOOL enableShadow;

// range:[0.0f - 1.0f], indicates how dark the shadow will be. default is 0.5
@property (nonatomic, assign) float shadowDarkness;


@end
