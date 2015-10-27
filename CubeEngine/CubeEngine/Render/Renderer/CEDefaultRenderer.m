//
//  CEDefaultRenderer.m
//  CubeEngine
//
//  Created by chance on 9/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEDefaultRenderer.h"
#import "CERenderer_privates.h"

#import "CEDefaultProgram.h"
#import "CEShaderBuilder.h"
#import "CEModel_Rendering.h"
#import "CELight_Rendering.h"
#import "CECamera_Rendering.h"
#import "CEShadowLight_Rendering.h"
#import "CETextureManager.h"

@implementation CEDefaultRenderer {
    CEShadowLight *_shadowLight;
}


+ (instancetype)rendererWithConfig:(CERenderConfig *)config {
    // build shader
    CEShaderBuilder *shaderBuilder = [CEShaderBuilder new];
    [shaderBuilder startBuildingNewShader];
    [shaderBuilder setMaterialType:config.materialType];
    if (config.enableNormalMapping) {
        [shaderBuilder enableNormalLightWithType:config.lightType];
    } else {
        [shaderBuilder enableLightWithType:config.lightType];
    }
    [shaderBuilder enableTexture:config.enableTexture];
    [shaderBuilder enableShadowMap:config.enableShadowMapping];
    CEShaderInfo *shaderInfo = [shaderBuilder build];
    if (!shaderInfo) {
        return nil;
    }
    // build program
    CEDefaultProgram *program = [CEDefaultProgram buildProgramWithShaderInfo:shaderInfo];
    if (!program) {
        return nil;
    }
    if (program.textureUnitCount > [CETextureManager maxTextureUnitCount]) {
        CEError(@"No enough texture units for program[%d > %d]", program.textureUnitCount,
                [CETextureManager maxTextureUnitCount]);
        return nil;
    }
    // build render
    CEDefaultRenderer *render = [[[self class] alloc] init];
    [render setShaderProgram:program];
    return render;
}


- (void)setMainLight:(CELight *)mainLight {
    if (_mainLight != mainLight) {
        _mainLight = mainLight;
        if ([_mainLight isKindOfClass:[CEShadowLight class]]) {
            _shadowLight = (CEShadowLight *)mainLight;
        }
    }
}


- (BOOL)onPrepareRendering {
    CEDefaultProgram *program = (CEDefaultProgram *)_program;
    if (_mainLight.enabled) {
        // !!!: transfer light position in view space
        if (_mainLight.lightInfo.lightType == CELightTypePoint ||
            _mainLight.lightInfo.lightType == CELightTypeSpot) {
            GLKVector4 lightPosition = GLKMatrix4MultiplyVector4(_mainLight.transformMatrix, GLKVector4Make(0, 0, 0, 1));
            lightPosition = GLKMatrix4MultiplyVector4(_camera.viewMatrix, lightPosition);
            _mainLight.lightInfo.lightPosition = lightPosition;
        }
        
        // !!!: transfer light direction in view space
        if (_mainLight.lightInfo.lightType == CELightTypeDirectional ||
            _mainLight.lightInfo.lightType == CELightTypeSpot) {
            GLKVector3 lightDirection = GLKVector3Make(-_mainLight.right.x, -_mainLight.right.y, -_mainLight.right.z);
            lightDirection = GLKMatrix4MultiplyVector3(_camera.viewMatrix, lightDirection);
            _mainLight.lightInfo.lightDirection = lightDirection;
        }
        
        program.mainLight.isEnabled.boolValue = _mainLight.lightInfo.isEnabled;
        program.mainLight.lightType.intValue = _mainLight.lightInfo.lightType;
        program.mainLight.lightPosition.vector4 = _mainLight.lightInfo.lightPosition;
        program.mainLight.lightDirection.vector3 = _mainLight.lightInfo.lightDirection;
        program.mainLight.lightColor.vector3 = _mainLight.lightInfo.lightColor;
        program.mainLight.attenuation.floatValue = _mainLight.lightInfo.attenuation;
        program.mainLight.spotConsCutOff.floatValue = _mainLight.lightInfo.spotCosCutOff;
        program.mainLight.spotExponent.floatValue = _mainLight.lightInfo.spotExponent;
    }
    
    // we use eye space to do the calculation, so the eye direction is always (0, 0, 1)
    program.eyeDirection.vector3 = GLKVector3Make(0.0, 0.0, 1.0);
    
    // shadow map setting
    if (program.shadowDarkness) {
        program.shadowDarkness.floatValue = 1.0 - _shadowLight.shadowDarkness;
    }
    
    return YES;
}


- (BOOL)renderObject:(CERenderObject *)object {
    if (!object.vertexBuffer || !object.indiceBuffer || !object.material) {
        CEError(@"Invalid render object");
        return NO;
    }
    
    if (![object.vertexBuffer loadBuffer] ||
        ![object.indiceBuffer loadBuffer]) {
        CEError(@"Render object fail to load buffer");
        [object.indiceBuffer unloadBuffer];
        [object.vertexBuffer unloadBuffer];
        return NO;
    }
    CEDefaultProgram *program = (CEDefaultProgram *)_program;
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, object.modelMatrix);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    program.modelViewProjectionMatrix.matrix4 = modelViewProjectionMatrix;
    
    // setup material
    if (object.material) {
        program.diffuseColor.vector4 = GLKVector4MakeWithVector3(object.material.diffuseColor, 1.0);
        program.specularColor.vector3 = object.material.specularColor;
        program.ambientColor.vector3 = object.material.ambientColor;
        program.shininessExponent.floatValue = object.material.shininessExponent;
    }
    
    // setup texture
    if (object.material.diffuseTextureID && program.diffuseTexture) {
        uint32_t textureUnit = [[CETextureManager sharedManager] prepareTextureWithID:object.material.diffuseTextureID];
        program.diffuseTexture.textureUnit = textureUnit;
    }
    
    // setup light
    if (_mainLight.enabled) {
        // setup normal matrix
        GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(modelViewMatrix, NULL);
        program.normalMatrix.matrix3 = GLKMatrix4GetMatrix3(normalMatrix);
        
        // setup model view matrix for specify lights
        if (_mainLight.lightInfo.lightType == CELightTypePoint ||
            _mainLight.lightInfo.lightType == CELightTypeSpot) {
            program.modelViewMatrix.matrix4 = modelViewMatrix;
        }
        
        // normal mapping
        if (object.material.normalTextureID && program.normalTexture) {
            uint32_t textureUnit = [[CETextureManager sharedManager] prepareTextureWithID:object.material.normalTextureID];
            program.normalTexture.textureUnit = textureUnit;
        }
        
        // setup shadow mapping
        if (program.shadowMapTexture && _shadowMapTextureID) {
            uint32_t textureUnit = [[CETextureManager sharedManager] prepareTextureWithID:_shadowMapTextureID];
            program.shadowMapTexture.textureUnit = textureUnit;
        }
        if (program.depthBiasMVP) {
            GLKMatrix4 biasMatrix = GLKMatrix4Make(0.5, 0.0, 0.0, 0.0,
                                                   0.0, 0.5, 0.0, 0.0,
                                                   0.0, 0.0, 0.5, 0.0,
                                                   0.5, 0.5, 0.5, 1.0);
            GLKMatrix4 depthMVP = GLKMatrix4Multiply(_shadowLight.lightViewMatrix, object.modelMatrix);
            depthMVP = GLKMatrix4Multiply(_shadowLight.lightProjectionMatrix, depthMVP);
            depthMVP = GLKMatrix4Multiply(biasMatrix, depthMVP);
            program.depthBiasMVP.matrix4 = depthMVP;
        }
    }
    
    glDrawElements(object.indiceBuffer.drawMode,
                   object.indiceBuffer.indiceCount,
                   object.indiceBuffer.primaryType, 0);
    [object.indiceBuffer unloadBuffer];
    [object.vertexBuffer unloadBuffer];
    
    return YES;
}


- (void)onFinishRendering:(BOOL)hasRenderAllObjects {
    // do nothing
}


@end

