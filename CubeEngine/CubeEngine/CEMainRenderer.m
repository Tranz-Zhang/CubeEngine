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
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"

@implementation CEMainRenderer {
    CEMainProgram *_program;
    CEProgramConfig *_config;
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


- (void)setLights:(NSSet *)lights {
    if (_lights != lights) {
        if (lights.count != _program.uniLightInfos.count) {
            CEWarning(@"light's count dismatch!!!");
        }
        _lights = [lights copy];
        int idx = 0;
        for (CELight *light in _lights) {
            if (idx < _program.uniLightInfos.count) {
                light.uniformInfo = _program.uniLightInfos[idx];
            }
            idx++;
        }
    }
}


- (void)renderObjects:(NSSet *)objects {
    if (!_program || !_camera) {
        CEError(@"Invalid renderer environment");
        return;
    }
    [_program use];
    
    // setup model irrelevant properties
    if (_config.lightCount) {
        // setup lighting uniforms !!!: must setup light before mvp matrix;
        for (CELight *light in _lights) {
            [light updateUniformsWithCamera:_camera];
            
            // shadowm mapping code
//            if (light.enabled && light.enableShadow && light.shadowMapBuffer) {
//                glBindTexture(GL_TEXTURE_2D, light.shadowMapBuffer.textureId);
//                glUniform1i(_uniTexShadowMapTexture, 0);
//                GLKMatrix4 biasMatrix = GLKMatrix4Make(0.5, 0.0, 0.0, 0.0,
//                                                       0.0, 0.5, 0.0, 0.0,
//                                                       0.0, 0.0, 0.5, 0.0,
//                                                       0.5, 0.5, 0.5, 1.0);
//                GLKMatrix4 depthMVP = GLKMatrix4Multiply(light.lightViewMatrix, model.transformMatrix);
//                depthMVP = GLKMatrix4Multiply(light.lightProjectionMatrix, depthMVP);
//                depthMVP = GLKMatrix4Multiply(biasMatrix, depthMVP);
//                glUniformMatrix4fv(_uniMtx4DepthBiasMVP, 1, GL_FALSE, depthMVP.m);
//            }
        }
        
        // we use eye space to do the calculation, so the eye direction is always (0, 0, 1)
        [_program setEyeDirection:GLKVector3Make(0.0, 0.0, 1.0)];
    }
    
    for (CEModel *model in objects) {
        [self renderModel:model];
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
    
    [_program setBaseColor:model.vec3BaseColor];
    
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
        if (![_program setNormalAttribute:[model.vertexBuffer attributeWithName:CEVBOAttributeNormal]]) {
            CEError(@"Fail to set normal attribute");
            return;
        }
        [_program setModelViewMatrix:modelViewMatrix];
        
        // setup normal matrix
        GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(modelViewMatrix);
        normalMatrix = GLKMatrix3InvertAndTranspose(normalMatrix, NULL);
        [_program setNormalMatrix:normalMatrix];
    }
    
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
}




@end





