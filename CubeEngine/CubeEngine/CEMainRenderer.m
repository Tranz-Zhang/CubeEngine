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
}


+ (instancetype)rendererWithConfig:(CEProgramConfig *)config {
    return [[self alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(CEProgramConfig *)config {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)setLights:(NSSet *)lights {
    if (_lights != lights) {
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
    
    // setup shadow mapping
    CELight *shadowLight;
    for (CELight *light in _lights) {
        if(light.enableShadow) {
            shadowLight = light;
            break;
        }
    }
    
    for (CEModel *model in objects) {
        [self recursiveRenderModel:model];
    }
}


- (void)recursiveRenderModel:(CEModel *)model {
    if (model.vertexBuffer) {
        [self renderModel:model];
    }
    for (CEModel *child in model.childObjects) {
        [self recursiveRenderModel:child];
    }
}


- (void)renderModel:(CEModel *)model {
    if (!model.vertexBuffer) {
        CEError(@"Empty vertexBuffer");
        return;
    }
    
    // setup vertex buffer
    if (![model.vertexBuffer setupBuffer] ||
        (model.indicesBuffer && ![model.indicesBuffer setupBuffer])) {
        return;
    }
    // prepare for rendering
    if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition withProgramIndex:_attribVec4Position] ||
        ![model.vertexBuffer prepareAttribute:CEVBOAttributeNormal withProgramIndex:_attribVec3Normal]){
        return;
    }
    if (model.indicesBuffer && ![model.indicesBuffer bindBuffer]) {
        return;
    }
    [_program use];
    
    // setup lighting uniforms !!!: must setup light before mvp matrix;
    glUniform1i(_uniIntLightCount, (GLint)_lights.count);
    for (CELight *light in _lights) {
        [light updateUniformsWithCamera:_camera];
        if (light.enabled && light.enableShadow && light.shadowMapBuffer) {
            glBindTexture(GL_TEXTURE_2D, light.shadowMapBuffer.textureId);
            glUniform1i(_uniTexShadowMapTexture, 0);
            GLKMatrix4 biasMatrix = GLKMatrix4Make(0.5, 0.0, 0.0, 0.0,
                                                   0.0, 0.5, 0.0, 0.0,
                                                   0.0, 0.0, 0.5, 0.0,
                                                   0.5, 0.5, 0.5, 1.0);
            GLKMatrix4 depthMVP = GLKMatrix4Multiply(light.lightViewMatrix, model.transformMatrix);
            depthMVP = GLKMatrix4Multiply(light.lightProjectionMatrix, depthMVP);
            depthMVP = GLKMatrix4Multiply(biasMatrix, depthMVP);
            glUniformMatrix4fv(_uniMtx4DepthBiasMVP, 1, GL_FALSE, depthMVP.m);
        }
    }
    
    // setup other uniforms
    glUniform4f(_uniVec4BaseColor, model.vec3BaseColor.r, model.vec3BaseColor.g,
                model.vec3BaseColor.b, model.vec3BaseColor.a);
    // we use eye space to do the calculation, so the eye direction is always (0, 0, 1)
    glUniform3f(_uniVec3EyeDirection, 0.0, 0.0, 1.0);
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    glUniformMatrix4fv(_uniMtx4MVPMatrix, 1, GL_FALSE, projectionMatrix.m);
    glUniformMatrix4fv(_uniMtx4MVMatrix, 1, GL_FALSE, modelViewMatrix.m);
    
    // setup normal matrix
    GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(modelViewMatrix);
    normalMatrix = GLKMatrix3InvertAndTranspose(normalMatrix, NULL);
    glUniformMatrix3fv(_uniMtx3NormalMatrix, 1, GL_FALSE, normalMatrix.m);
    
    glBindFramebuffer(GL_FRAMEBUFFER, [CEScene currentScene].renderCore.defaultFramebuffer);
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
}


@end


