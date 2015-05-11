//
//  CEShadowMapBuffer.m
//  CubeEngine
//
//  Created by chance on 5/11/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowMapBuffer.h"

@implementation CEShadowMapBuffer {
    GLuint _frameBuffer;
}

- (instancetype)initWithTextureSize:(CGSize)textureSize
{
    self = [super init];
    if (self) {
        _textureSize = textureSize;
    }
    return self;
}


- (void)dealloc {
    [self cleanUp];
}


- (void)cleanUp {
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_textureId) {
        glDeleteTextures(1, &_textureId);
        _textureId = 0;
    }
    _ready = NO;
}


- (BOOL)setupBuffer {
    if (_ready) return YES;
    if (!_textureSize.width || !_textureSize.height) {
        CEError(@"Invalid texture size");
        return NO;
    }
    
    // generate framebuffer
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // generate texture
    glGenTextures(1, &_textureId);
    glBindTexture(GL_TEXTURE_2D, _textureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, (GLsizei)_textureSize.width, (GLsizei)_textureSize.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _textureId, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GLenum error;
    if( (error=glCheckFramebufferStatus(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE)  {
        NSLog(@"Failed to make complete framebuffer object 0x%X", error);
        [self cleanUp];
        _ready = NO;
        
    } else {
        _ready = YES;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    return _ready;
}

- (void)prepareBuffer {
    if (_ready) {
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        glClear(GL_DEPTH_BUFFER_BIT);
        glViewport(0, 0, _textureSize.width, _textureSize.height);
    }
}


@end
