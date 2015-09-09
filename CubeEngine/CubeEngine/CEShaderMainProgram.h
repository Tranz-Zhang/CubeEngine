//
//  CEShaderMainProgram.h
//  CubeEngine
//
//  Created by chance on 9/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProgram.h"

@interface CEShaderMainProgram : CEShaderProgram

// basic
@property (nonatomic, readonly) CEAttributeVector4 *vertexPosition;
@property (nonatomic, readonly) CEUniformMatrix4 *modelViewProjectionMatrix;
@property (nonatomic, readonly) CEUniformVector4 *diffuseColor;

// light
@property (nonatomic, readonly) CEAttributeVector3 *vertexNormal;
@property (nonatomic, readonly) CEUniformMatrix3 *normalMatrix;
@property (nonatomic, readonly) CEUniformMatrix4 *modelViewMatrix;
@property (nonatomic, readonly) CEUniformVector3 *eyeDirection;
@property (nonatomic, readonly) CEUniformVector3 *specularColor;
@property (nonatomic, readonly) CEUniformVector3 *ambientColor;
@property (nonatomic, readonly) CEUniformFloat *shininessExponent;
@property (nonatomic, readonly) CEUniformLightInfo *lightInfo;


@end

