//
//  CETestRenderer.m
//  CubeEngine
//
//  Created by chance on 9/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CETestRenderer.h"
#import "CEShaderMainProgram.h"
#import "CEShaderBuilder.h"
#import "CEModel_Rendering.h"
#import "CELight_Rendering.h"
#import "CECamera_Rendering.h"

@implementation CETestRenderer {
    CEShaderMainProgram *_program;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        CEShaderBuilder *shaderBuilder = [CEShaderBuilder new];
        [shaderBuilder startBuildingNewShader];
        CEShaderInfo *shaderInfo = [shaderBuilder build];
        _program = [CEShaderMainProgram buildProgramWithShaderInfo:shaderInfo];
    }
    return self;
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
    
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
}



@end
