//
//  CEPointLight.h
//  CubeEngine
//
//  Created by chance on 4/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"

@interface CEPointLight : CELight

@property (nonatomic, assign) GLfloat attenuation;
@property (nonatomic, assign) GLint shiniess;
@property (nonatomic, assign) GLfloat specularItensity;

@end
