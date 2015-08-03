//
//  CEDefaultRenderer.m
//  CubeEngine
//
//  Created by chance on 5/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMainRenderer.h"
#import "CEScene_Rendering.h"
#import "CEMainProgram.h"
#import "CELight_Rendering.h"
#import "CEShadowLight_Rendering.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"
#import "CEShadowLight.h"


@implementation CEMainRenderer {
    CEMainProgram *_program;
    CEProgramConfig *_config;
    CEShadowLight *_shadowLight;
}


+ (instancetype)rendererWithConfig:(CEProgramConfig *)config {
    return [[self alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(CEProgramConfig *)config {
    self = [super init];
    if (self) {
        _config = config.copy;
        _program = [CEMainProgram programWithConfig:config];
    }
    return self;
}

- (void)setMainLight:(CELight *)mainLight {
    if (_mainLight != mainLight) {
        _mainLight = mainLight;
        if ([_mainLight isKindOfClass:[CEShadowLight class]]) {
            _shadowLight = (CEShadowLight *)mainLight;
        }
    }
}


- (void)renderObjects:(NSArray *)objects {
    if (!_program || !_camera) {
        CEError(@"Invalid renderer environment");
        return;
    }
    [_program beginRendering];
    
    [self setupLightInfosForRendering];
    for (CEModel *model in objects) {
        [self renderModel:model];
    }
    
    [_program endRendering];
}

- (void)setupLightInfosForRendering {
    if (!_config.lightCount) {
        return;
    }
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
        
        [_program setMainLightUniforms:_mainLight.lightInfo];
    }
    
    // we use eye space to do the calculation, so the eye direction is always (0, 0, 1)
    [_program setEyeDirection:GLKVector3Make(0.0, 0.0, 1.0)];
    
    // shadow map setting
    if (_shadowLight.enableShadow && _shadowLight.shadowMapBuffer) {
        [_program setShadowDarkness:1.0 - _shadowLight.shadowDarkness];
        [_program setShadowMapTexture:_shadowLight.shadowMapBuffer.textureId];
        
    } else if (_config.enableShadowMapping) {
        [_program setShadowMapTexture:0.0];
        [_program setShadowDarkness:1.0];
    }
}


- (void)renderModel:(CEModel *)model {
    if (!model.vertexBuffer) {
        CEError(@"Empty vertexBuffer");
        return;
    }
    
    if (model.indicesBuffer && ![model.indicesBuffer bindBuffer]) {
        CEError(@"Empty indices buffer");
        return;
    }
    
    if (model.material) {
        [_program setDiffuseColor:GLKVector4MakeWithVector3(model.material.diffuseColor, 1.0)];
    }
    
    // setup vertex buffer
    if (![model.vertexBuffer setupBuffer] ||
        (model.indicesBuffer && ![model.indicesBuffer setupBuffer])) {
        CEError(@"Fail to setup buffer");
        return;
    }
    // prepare for rendering
    if (![_program setPositionAttribute:[model.vertexBuffer attributeWithName:CEVBOAttributePosition]]) {
        CEError(@"Fail to set position attribute");
        return;
    }
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    [_program setModelViewProjectionMatrix:modelViewProjectionMatrix];
    
    if (_config.lightCount) {
        CEVBOAttribute *normalAttrib = [model.vertexBuffer attributeWithName:CEVBOAttributeNormal];
        if (!normalAttrib || ![_program setNormalAttribute:normalAttrib]) {
            CEError(@"Fail to set normal attribute");
            return;
        }
        
        // setup model view matrix for specify lights
        if (_mainLight.lightInfo.lightType == CELightTypePoint ||
            _mainLight.lightInfo.lightType == CELightTypeSpot) {
            [_program setModelViewMatrix:modelViewMatrix];
        }
        
        // setup material
        if (model.material) {
            [_program setSpecularColor:model.material.specularColor];
            [_program setAmbientColor:model.material.ambientColor];
            [_program setShininessExponent:model.material.shininessExponent];
        }
        
        // setup normal matrix
        GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(modelViewMatrix);
        normalMatrix = GLKMatrix3InvertAndTranspose(normalMatrix, NULL);
        [_program setNormalMatrix:normalMatrix];
        
        // setup normal mapping
        if (_config.enableNormalMapping && model.normalMap) {
            [_program setTangentAttribute:[model.vertexBuffer attributeWithName:CEVBOAttributeTangent]];
            [_program setNormalMapTexture:model.normalMap.name];
        }
        
        // setup shadow mapping
        if (_shadowLight.enableShadow) {
            GLKMatrix4 biasMatrix = GLKMatrix4Make(0.5, 0.0, 0.0, 0.0,
                                                   0.0, 0.5, 0.0, 0.0,
                                                   0.0, 0.0, 0.5, 0.0,
                                                   0.5, 0.5, 0.5, 1.0);
            GLKMatrix4 depthMVP = GLKMatrix4Multiply(_shadowLight.lightViewMatrix, model.transformMatrix);
            depthMVP = GLKMatrix4Multiply(_shadowLight.lightProjectionMatrix, depthMVP);
            depthMVP = GLKMatrix4Multiply(biasMatrix, depthMVP);
            [_program setDepthBiasModelViewProjectionMatrix:depthMVP];
        }
    }
    
    // TODO: add model texture and normal texture
    if (_config.enableTexture) {
        CEVBOAttribute *textureCoordAttri = [model.vertexBuffer attributeWithName:CEVBOAttributeTextureCoord];
        if (model.texture && textureCoordAttri) {
            [_program setTextureCoordinateAttribute:textureCoordAttri];
            [_program setDiffuseTexture:model.texture.name];
            
        } else {
            [_program setTextureCoordinateAttribute:nil];
            [_program setDiffuseTexture:0];
        }
    }
    
    // transparency
    if (_config.renderMode == CERenderModeTransparent) {
        [_program setTransparency:model.material.transparency];
    }
    
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
}




@end





