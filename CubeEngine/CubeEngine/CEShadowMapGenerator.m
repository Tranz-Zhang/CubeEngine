//
//  CEShadowMapGenerator.m
//  CubeEngine
//
//  Created by chance on 5/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowMapGenerator.h"
#import "CEScene_Rendering.h"
#import "CEProgram.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"
#import "CELight_Rendering.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

NSString *const kShaderMapVertexShader = CE_SHADER_STRING
(
 attribute vec4 position;
 uniform mat4 projection;
 
 void main () {
     gl_Position = projection * position;
 }
 );

NSString *const kShaderMapFragmentSahder = CE_SHADER_STRING
(
 void main() {
     gl_FragColor = vec4(1.0);
 }
 );


@implementation CEShadowMapGenerator {
    __weak EAGLContext *_context;
    CEProgram *_program;
    GLuint _frameBuffer;
    GLuint _colorRenderBuffer;
    GLint _attributePosition;
    GLint _attributeNormal;
    GLint _uniformProjection;
}

- (instancetype)initWithLight:(CELight *)light textureSize:(CGSize)size inContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _light = light;
        _context = context;
        _textureSize = size;
        
        // generate framebuffer
        glGenFramebuffers(1, &_frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        
        // generate texture
        glGenTextures(1, &_depthTexture);
        glBindTexture(GL_TEXTURE_2D, _depthTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, (GLsizei)_textureSize.width, (GLsizei)_textureSize.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _depthTexture, 0);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        GLenum error;
        if( (error=glCheckFramebufferStatus(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE)  {
            NSLog(@"Failed to make complete framebuffer object 0x%X", error);
            [self deleteBuffers];
        }
        
        [self setupProgram];
        glBindFramebuffer(GL_FRAMEBUFFER, [CEScene currentScene].renderCore.defaultFramebuffer);
    }
    return self;
}

- (void)dealloc {
    [self deleteBuffers];
}


- (void)deleteBuffers {
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_depthTexture) {
        glDeleteTextures(1, &_depthTexture);
        _depthTexture = 0;
    }
}

- (BOOL)setupProgram {
    _program = [[CEProgram alloc] initWithVertexShaderString:kShaderMapVertexShader
                                        fragmentShaderString:kShaderMapFragmentSahder];
    [_program addAttribute:@"position"];
    BOOL isOK = [_program link];
    if (isOK) {
        _attributePosition = [_program attributeIndex:@"position"];
        _uniformProjection = [_program uniformIndex:@"projection"];
        
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


- (BOOL)generateShadowMapWithModels:(NSSet *)models camera:(CECamera *)camera  {
    if (!_context || !_frameBuffer || !_depthTexture || !_program) {
        return NO;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    [_program use];
    for (CEModel *model in models) {
        // setup vertex buffer
        if (![model.vertexBuffer setupBuffer] ||
            (model.indicesBuffer && ![model.indicesBuffer setupBuffer])) {
            continue;
        }
        // prepare for rendering
        if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition
                                 withProgramIndex:_attributePosition]){
            continue;
        }
        if (model.indicesBuffer && ![model.indicesBuffer bindBuffer]) {
            continue;
        }
        
        #warning If the shadow map doesn't look right, check this projectionMatrix
        GLfloat value = camera.orthoBoxWidth;
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-value, value, -value / camera.aspect, value / camera.aspect, 0.1, 60);
        GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_light.lightViewMatrix, model.transformMatrix);
        _depthMVP = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
        glUniformMatrix4fv(_uniformProjection, 1, 0, _depthMVP.m);
        
        if (model.indicesBuffer) { // glDrawElements
            glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
            
        } else { // glDrawArrays
            glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
        }
    }    
    return YES;
}

@end
