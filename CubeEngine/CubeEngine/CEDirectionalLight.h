//
//  CEDirectionalLight.h
//  CubeEngine
//
//  Created by chance on 4/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowLight.h"

@interface CEDirectionalLight : CEShadowLight

@property (nonatomic, readonly) GLKVector3 lightDirection; // == CEObject.right
@property (nonatomic, assign) GLint shiniess;

@end
