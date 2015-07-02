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
}

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, copy) UIColor *lightColor; // default is withte


@end
