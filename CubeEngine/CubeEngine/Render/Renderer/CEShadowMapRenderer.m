//
//  CEShadowMapRenderer.m
//  CubeEngine
//
//  Created by chance on 10/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowMapRenderer.h"
#import "CERenderer_privates.h"
#import "CEUtils.h"
#import "CEShaderBuilder.h"
#import "CEDefaultProgram.h"
#import "CETextureManager.h"
#import "CEDepthTextureBuffer.h"
#import "CEShadowLight_Rendering.h"


@implementation CEShadowMapRenderer {
    BOOL _isReady;
    CEDepthTextureBuffer *_textureBuffer;
    GLKMatrix4 _lightVPMatrix;
}


+ (instancetype)renderer {
    // build shader
    CEShaderBuilder *shaderBuilder = [CEShaderBuilder new];
    [shaderBuilder startBuildingNewShader];
    CEShaderInfo *shaderInfo = [shaderBuilder build];
    if (!shaderInfo) {
        return nil;
    }
    // build program
    CEDefaultProgram *program = [CEDefaultProgram buildProgramWithShaderInfo:shaderInfo];
    if (!program) {
        return nil;
    }
    // build render
    CEShadowMapRenderer *render = [[CEShadowMapRenderer alloc] init];
    [render setShaderProgram:program];
    return render;

}


- (instancetype)init {
    self = [super init];
    if (self) {
        _isReady = [self setupTextureBuffer];
    }
    return self;
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


- (BOOL)onPrepareRendering {
    if (!_isReady || ![_mainLight isKindOfClass:[CEShadowLight class]]) return NO;
    [_textureBuffer beginRendering];
    CEShadowLight *shadowLight = (CEShadowLight *)_mainLight;
    _lightVPMatrix = GLKMatrix4Multiply(shadowLight.lightProjectionMatrix, shadowLight.lightViewMatrix);
    return YES;
}


- (BOOL)renderObject:(CERenderObject *)object {
    CEDefaultProgram *program = (CEDefaultProgram *)_program;
    
    if (![object.vertexBuffer loadBuffer] ||
        ![object.indiceBuffer loadBuffer]) {
        CEError(@"Fail to load renderObject's buffer for shadow mapping");
        [object.indiceBuffer unloadBuffer];
        [object.vertexBuffer unloadBuffer];
        return NO;
    }
    program.modelViewProjectionMatrix.matrix4 = GLKMatrix4Multiply(_lightVPMatrix, object.modelMatrix);
    glDrawElements(object.indiceBuffer.drawMode,
                   object.indiceBuffer.indiceCount,
                   object.indiceBuffer.primaryType, 0);
    [object.indiceBuffer unloadBuffer];
    [object.vertexBuffer unloadBuffer];
    
    return YES;
}


- (void)onFinishRendering:(BOOL)hasRenderAllObjects {
    [_textureBuffer endRendering];
}


@end


