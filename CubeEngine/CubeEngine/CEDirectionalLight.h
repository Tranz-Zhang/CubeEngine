//
//  CEDirectionalLight.h
//  CubeEngine
//
//  Created by chance on 4/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"

@interface CEDirectionalLight : CELight

@property (nonatomic, readonly) GLKVector3 lightDirection; // == CEObject.right
@property (nonatomic, assign) GLint shiniess;

@end
