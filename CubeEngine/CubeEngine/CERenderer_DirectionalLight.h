//
//  CERenderer_DirectionalLight.h
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"

@interface CERenderer_DirectionalLight : CERenderer

+ (instancetype)shareRenderer;

@property (nonatomic, assign) GLKVector4 vertexColor;
@property (nonatomic, assign) GLKVector3 ambientColor;
@property (nonatomic, assign) GLKVector3 lightColor;
@property (nonatomic, assign) GLKVector3 lightDirection;
@property (nonatomic, assign) GLKVector3 halfVector;
@property (nonatomic, assign) GLint shiniess;
@property (nonatomic, assign) GLfloat strength;

@end
