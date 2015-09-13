//
//  CEShaderMainProgram.m
//  CubeEngine
//
//  Created by chance on 9/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEDefaultProgram.h"
#import "CEShaderProgram_privates.h"

@implementation CEDefaultProgram

- (void)onProgramSetup {
    // basic
    _vertexPosition =   (CEAttributeVector4 *)[self outputVariableWithName:@"VertexPosition" type:@"vec4"];
    _modelViewProjectionMatrix = (CEUniformMatrix4 *)[self outputVariableWithName:@"MVPMatrix" type:@"mat4"];
    _diffuseColor =     (CEUniformVector4 *)[self outputVariableWithName:@"DiffuseColor" type:@"vec4"];
    
    // light
    _vertexNormal =     (CEAttributeVector3 *)[self outputVariableWithName:@"VertexNormal" type:@"vec3"];
    _normalMatrix =     (CEUniformMatrix3 *)[self outputVariableWithName:@"NormalMatrix" type:@"mat3"];
    _modelViewMatrix =  (CEUniformMatrix4 *)[self outputVariableWithName:@"MVMatrix" type:@"mat4"];
    _eyeDirection =     (CEUniformVector3 *)[self outputVariableWithName:@"EyeDirection" type:@"vec3"];
    _specularColor =    (CEUniformVector3 *)[self outputVariableWithName:@"SpecularColor" type:@"vec3"];
    _ambientColor =     (CEUniformVector3 *)[self outputVariableWithName:@"AmbientColor" type:@"vec3"];
    _shininessExponent = (CEUniformFloat *)[self outputVariableWithName:@"ShininessExponent" type:@"float"];
    _mainLight =        (CEUniformLightInfo *)[self outputVariableWithName:@"MainLight" type:@"LightInfo"];
}


@end

