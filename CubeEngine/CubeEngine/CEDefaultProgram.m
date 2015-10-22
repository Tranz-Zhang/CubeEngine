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
    _modelViewProjectionMatrix = (CEUniformMatrix4 *)[self uniformVariableWithName:@"MVPMatrix" type:@"mat4"];
    _diffuseColor =     (CEUniformVector4 *)[self uniformVariableWithName:@"DiffuseColor" type:@"vec4"];
    
    // light
    _normalMatrix =     (CEUniformMatrix3 *)[self uniformVariableWithName:@"NormalMatrix" type:@"mat3"];
    _modelViewMatrix =  (CEUniformMatrix4 *)[self uniformVariableWithName:@"MVMatrix" type:@"mat4"];
    _eyeDirection =     (CEUniformVector3 *)[self uniformVariableWithName:@"EyeDirection" type:@"vec3"];
    _specularColor =    (CEUniformVector3 *)[self uniformVariableWithName:@"SpecularColor" type:@"vec3"];
    _ambientColor =     (CEUniformVector3 *)[self uniformVariableWithName:@"AmbientColor" type:@"vec3"];
    _shininessExponent = (CEUniformFloat *)[self uniformVariableWithName:@"ShininessExponent" type:@"float"];
    _mainLight =        (CEUniformLightInfo *)[self uniformVariableWithName:@"MainLight" type:@"LightInfo"];
    
    // texture
    _diffuseTexture = (CEUniformSampler2D *)[self uniformVariableWithName:@"DiffuseTexture" type:@"sampler2D"];
    
    // normal mapping
    _normalTexture = (CEUniformSampler2D *)[self uniformVariableWithName:@"NormalMapTexture" type:@"sampler2D"];
    
    // shadow map
    _depthBiasMVP =     (CEUniformMatrix4 *)[self uniformVariableWithName:@"DepthBiasMVP" type:@"mat4"];
    _shadowDarkness =   (CEUniformFloat *)[self uniformVariableWithName:@"ShadowDarkness" type:@"float"];
    _shadowMapTexture = (CEUniformSampler2D *)[self uniformVariableWithName:@"ShadowMapTexture" type:@"sampler2D"];
}


@end

