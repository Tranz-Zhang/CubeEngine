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
    _modelViewProjectionMatrix =    (CEUniformMatrix4 *)[self uniformWithName:@"MVPMatrix"      type:@"mat4"];
    _diffuseColor =                 (CEUniformVector4 *)[self uniformWithName:@"DiffuseColor"   type:@"vec4"];
    
    // light
    _normalMatrix =         (CEUniformMatrix3 *)[self uniformWithName:@"NormalMatrix"       type:@"mat3"];
    _modelViewMatrix =      (CEUniformMatrix4 *)[self uniformWithName:@"MVMatrix"           type:@"mat4"];
    _eyeDirection =         (CEUniformVector3 *)[self uniformWithName:@"EyeDirection"       type:@"vec3"];
    _specularColor =        (CEUniformVector3 *)[self uniformWithName:@"SpecularColor"      type:@"vec3"];
    _ambientColor =         (CEUniformVector3 *)[self uniformWithName:@"AmbientColor"       type:@"vec3"];
    _shininessExponent =    (CEUniformFloat *)  [self uniformWithName:@"ShininessExponent"  type:@"float"];
    _mainLight =          (CEUniformLightInfo *)[self uniformWithName:@"MainLight"          type:@"LightInfo"];
    
    // texture
    _diffuseTexture =   (CEUniformSampler2D *)  [self uniformWithName:@"DiffuseTexture"     type:@"sampler2D"];
    
    // normal mapping
    _normalTexture =    (CEUniformSampler2D *)  [self uniformWithName:@"NormalMapTexture"   type:@"sampler2D"];
    
    // shadow map
    _depthBiasMVP =     (CEUniformMatrix4 *)    [self uniformWithName:@"DepthBiasMVP"       type:@"mat4"];
    _shadowDarkness =   (CEUniformFloat *)      [self uniformWithName:@"ShadowDarkness"     type:@"float"];
    _shadowMapTexture = (CEUniformSampler2D *)  [self uniformWithName:@"ShadowMapTexture"   type:@"sampler2D"];
    
    // transparency
    _transparency =     (CEUniformFloat *)      [self uniformWithName:@"Transparency"       type:@"float"];
}


@end

