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

@property (nonatomic, assign) BOOL enableShadow; // indicates if this light cast shadow on objects

@end
