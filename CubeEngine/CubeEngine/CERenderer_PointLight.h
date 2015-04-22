//
//  CERenderer_PointLight.h
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"

@interface CERenderer_PointLight : CERenderer

+ (instancetype)shareRenderer;

@property (nonatomic, assign) GLKVector4 vertexColor;
@property (nonatomic, assign) GLKVector3 ambientColor;
@property (nonatomic, assign) GLKVector3 lightColor;
@property (nonatomic, assign) GLKVector3 lightLocation;

@property (nonatomic, assign) GLfloat constantAttenuation;
@property (nonatomic, assign) GLfloat linearAttenuation;
@property (nonatomic, assign) GLfloat quadraticAttenuation;

@property (nonatomic, assign) GLint shiniess;
@property (nonatomic, assign) GLfloat strength;

@end

