//
//  CEShadowMapRenderer.m
//  CubeEngine
//
//  Created by chance on 10/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowMapRenderer.h"
#import "CEUtils.h"
#import "CEProgram.h"
#import "CETextureManager.h"
#import "CEDepthTextureBuffer.h"
#import "CEModel_Rendering.h"
#import "CEShadowLight_Rendering.h"



NSString *const kShadowMapVertexShader = CE_SHADER_STRING
(
 attribute highp vec4 VertexPosition;
 uniform highp mat4 MVPMatrix;
 
 void main () {
     gl_Position = MVPMatrix * VertexPosition;
 }
);

NSString *const kShadowMapFragmentSahder = CE_SHADER_STRING
(
 void main() {
     gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
 }
);


@implementation CEShadowMapRenderer {
    CEProgram *_program;
    GLint _attributePosition;
    GLint _uniformMVPMatrix;
    
    CEDepthTextureBuffer *_textureBuffer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self setupRenderer] &&
            [self setupTextureBuffer]) {
            _isReady = YES;
            
        } else {
            _isReady = NO;
        }
    }
    return self;
}

- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    
    _program = [[CEProgram alloc] initWithVertexShaderString:kShadowMapVertexShader
                                        fragmentShaderString:kShadowMapFragmentSahder];
    [_program addAttribute:@"VertexPosition" atIndex:CEVBOAttributePosition];
    BOOL isOK = [_program link];
    if (isOK) {
        _attributePosition = [_program attributeIndex:@"VertexPosition"];
        _uniformMVPMatrix = [_program uniformIndex:@"MVPMatrix"];
        
    } else {
        // print error info
        NSString *progLog = [_program programLog];
        CEError(@"Program link log: %@", progLog);
        NSString *fragLog = [_program fragmentShaderLog];
        CEError(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [_program vertexShaderLog];
        CEError(@"Vertex shader compile log: %@", vertLog);
        _program = nil;
        NSAssert(0, @"Fail to Compile Program");
    }
    
    return isOK;
}


- (BOOL)setupTextureBuffer {
    CETextureBufferConfig *config = [CETextureBufferConfig new];
    config.width = 512;
    config.height = 512;
    NSString *bufferName = [NSString stringWithFormat:@"shadow_map_%p", self];
    _textureBuffer = [[CEDepthTextureBuffer alloc] initWithConfig:config resourceID:CEHashValueWithString(bufferName)];
    if ([_textureBuffer setupBuffer] &&
        [[CETextureManager sharedManager] manageTextureBuffer:_textureBuffer]) {
        return YES;
    }
    return NO;
}


- (uint32_t)shadowMapTextureID {
    if (_isReady && _textureBuffer) {
        return _textureBuffer.resourceID;
    }
    return 0;
}


- (BOOL)renderShadowMapWithModels:(NSArray *)shadowModels
                      shadowLight:(CEShadowLight *)shadowLight {
    if (!shadowLight.enableShadow) {
        return NO;
    }
    
    // update lightViewMatrix
    [shadowLight updateLightVPMatrixWithModels:shadowModels];
    GLKMatrix4 lightVPMatrix = GLKMatrix4Multiply(shadowLight.lightProjectionMatrix, shadowLight.lightViewMatrix);
    // render shadow map
    [_textureBuffer beginRendering];
    [_program use];
    for (CEModel *model in shadowModels) {
        if (!model.enableShadow) {
            continue;
        }
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(lightVPMatrix, model.transformMatrix);
        glUniformMatrix4fv(_uniformMVPMatrix, 1, GL_FALSE, mvpMatrix.m);
        for (CERenderObject *object in model.renderObjects) {
            if (![object.vertexBuffer loadBuffer] ||
                ![object.indiceBuffer loadBuffer]) {
                CEError(@"Fail to load renderObject's buffer for shadow mapping");
                continue;
            }
            glDrawElements(object.indiceBuffer.drawMode,
                           object.indiceBuffer.indiceCount,
                           object.indiceBuffer.primaryType, 0);
            [object.indiceBuffer unloadBuffer];
            [object.vertexBuffer unloadBuffer];
        }
    }
    [_textureBuffer endRendering];
    return YES;
}


@end


