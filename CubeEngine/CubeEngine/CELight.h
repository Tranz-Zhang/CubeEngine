//
//  CELight.h
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObject.h"

@interface CELight : CEObject {
    GLKVector3 _lightColorV3;
    GLKVector3 _ambientColorV3;
    GLKMatrix4 _lightViewMatrix;
    GLKMatrix4 _lightProjectionMatrix;
}

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign) BOOL enableShadow; // indicates if this light cast shadow on objects
@property (nonatomic, copy) UIColor *lightColor; // default is withte
@property (nonatomic, copy) UIColor *ambientColor; // default is 0.2*White


@end
