//
//  CEDefaultRenderer.m
//  CubeEngine
//
//  Created by chance on 9/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEDefaultRenderer.h"

#import "CEDefaultProgram.h"
#import "CEShaderBuilder.h"
#import "CEModel_Rendering.h"
#import "CELight_Rendering.h"
#import "CECamera_Rendering.h"
#import "CEShadowLight_Rendering.h"

@implementation CEDefaultRenderer {
    CEDefaultProgram *_program;
    CEShadowLight *_shadowLight;
}


+ (instancetype)rendererWithConfig:(CERenderConfig *)config {
    CEShaderBuilder *shaderBuilder = [CEShaderBuilder new];
    [shaderBuilder startBuildingNewShader];
    [shaderBuilder enableLightWithType:config.lightType];
    [shaderBuilder enableTexture:config.enableTexture];
    [shaderBuilder enableNormalMap:config.enableNormalMapping];
    [shaderBuilder enableShadowMap:config.enableShadowMapping];
    CEShaderInfo *shaderInfo = [shaderBuilder build];
    if (!shaderInfo) {
        return nil;
    }
    CEDefaultProgram *program = [CEDefaultProgram buildProgramWithShaderInfo:shaderInfo];
    if (!program) {
        return nil;
    }
    CEDefaultRenderer *render = [[CEDefaultRenderer alloc] initWithProgram:program];
    return render;
}


- (instancetype)initWithProgram:(CEDefaultProgram *)program {
    self = [super init];
    if (self) {
        _program = program;
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
    [_program use];
    [self setupLightInfosForRendering];
    for (CEModel *model in objects) {
        [self renderModel:model];
    }
}

- (void)setupLightInfosForRendering {
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
        
        _program.mainLight.isEnabled.boolValue = _mainLight.lightInfo.isEnabled;
        _program.mainLight.lightType.intValue = _mainLight.lightInfo.lightType;
        _program.mainLight.lightPosition.vector4 = _mainLight.lightInfo.lightPosition;
        _program.mainLight.lightDirection.vector3 = _mainLight.lightInfo.lightDirection;
        _program.mainLight.lightColor.vector3 = _mainLight.lightInfo.lightColor;
        _program.mainLight.attenuation.floatValue = _mainLight.lightInfo.attenuation;
        _program.mainLight.spotConsCutOff.floatValue = _mainLight.lightInfo.spotCosCutOff;
        _program.mainLight.spotExponent.floatValue = _mainLight.lightInfo.spotExponent;
    }
    
    
    // we use eye space to do the calculation, so the eye direction is always (0, 0, 1)
    _program.eyeDirection.vector3 = GLKVector3Make(0.0, 0.0, 1.0);
    
    // shadow map setting
    if (_shadowLight.enableShadow && _shadowLight.shadowMapBuffer) {
        _program.shadowDarkness.floatValue = 1.0 - _shadowLight.shadowDarkness;
        _program.shadowMapTexture.textureID = _shadowLight.shadowMapBuffer.textureId;
        
    } else {
        _program.shadowDarkness.floatValue = 0.0;
        _program.shadowMapTexture.textureID = 0.0;
    }
    
}


- (void)renderModel:(CEModel *)model {
#warning TODO: order this thing!
    
    if (!model.vertexBuffer) {
        CEError(@"Empty vertexBuffer");
        return;
    }
    
    if (model.indicesBuffer && ![model.indicesBuffer bindBuffer]) {
        CEError(@"Empty indices buffer");
        return;
    }
    
    if (model.material) {
        _program.diffuseColor.vector4 = GLKVector4MakeWithVector3(model.material.diffuseColor, 1.0);
    }
    
    // setup vertex buffer
    if (![model.vertexBuffer setupBuffer] ||
        (model.indicesBuffer && ![model.indicesBuffer setupBuffer])) {
        CEError(@"Fail to setup buffer");
        return;
    }
    // prepare for rendering
    _program.vertexPosition.attribute = [model.vertexBuffer attributeWithName:CEVBOAttributePosition];
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    _program.modelViewProjectionMatrix.matrix4 = modelViewProjectionMatrix;
    
    CEVBOAttribute *normalAttrib = [model.vertexBuffer attributeWithName:CEVBOAttributeNormal];
    _program.vertexNormal.attribute = normalAttrib;
    
    // setup normal matrix
    GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(modelViewMatrix);
    normalMatrix = GLKMatrix3InvertAndTranspose(normalMatrix, NULL);
    _program.normalMatrix.matrix3 = normalMatrix;
    
    // setup model view matrix for specify lights
    if (_mainLight.lightInfo.lightType == CELightTypePoint ||
        _mainLight.lightInfo.lightType == CELightTypeSpot) {
        _program.modelViewMatrix.matrix4 = modelViewMatrix;
    }
    
    // setup material
    if (model.material) {
        _program.specularColor.vector3 = model.material.specularColor;
        _program.ambientColor.vector3 = model.material.ambientColor;
        _program.shininessExponent.floatValue = model.material.shininessExponent;
    }
    
    // texture
    if (_program.textureCoordinate) {
        CEVBOAttribute *textureCoordAttri = [model.vertexBuffer attributeWithName:CEVBOAttributeUV];
        _program.textureCoordinate.attribute = textureCoordAttri;
    }
    if (_program.diffuseTexture) {
        _program.diffuseTexture.textureID = model.texture.name;
    }
    
    // shadow map
    if (_program.depthBiasMVP) {
        GLKMatrix4 biasMatrix = GLKMatrix4Make(0.5, 0.0, 0.0, 0.0,
                                               0.0, 0.5, 0.0, 0.0,
                                               0.0, 0.0, 0.5, 0.0,
                                               0.5, 0.5, 0.5, 1.0);
        GLKMatrix4 depthMVP = GLKMatrix4Multiply(_shadowLight.lightViewMatrix, model.transformMatrix);
        depthMVP = GLKMatrix4Multiply(_shadowLight.lightProjectionMatrix, depthMVP);
        depthMVP = GLKMatrix4Multiply(biasMatrix, depthMVP);
        _program.depthBiasMVP.matrix4 = depthMVP;        
    }
    
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
}



@end

