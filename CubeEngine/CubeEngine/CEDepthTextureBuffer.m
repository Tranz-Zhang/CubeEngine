//
//  CERenderableTextureBuffer.m
//  CubeEngine
//
//  Created by chance on 10/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEDepthTextureBuffer.h"

@implementation CEDepthTextureBuffer {
    GLuint _frameBufferID;
}


- (BOOL)setupBuffer {
    if (_ready) return YES;
    if (!_config ||
        _config.width * _config.height == 0) {
        return NO;
    }
    
    // generate framebuffer
    glGenFramebuffers(1, &_frameBufferID);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferID);
    
    glGenTextures(1, &_textureBufferID);
    glBindTexture(GL_TEXTURE_2D, _textureBufferID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, _config.width, _config.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT, 0);
    
    if (_config.mag_filter) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _config.mag_filter);
    }
    if (_config.min_filter) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _config.min_filter);
    }
    if (_config.wrap_s) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _config.wrap_s);
    }
    if (_config.wrap_t) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _config.wrap_t);
    }
    if (_config.useMipmap) {
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _textureBufferID, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GLenum error;
    if( (error=glCheckFramebufferStatus(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE)  {
        NSLog(@"Failed to make complete framebuffer object 0x%X", error);
        [self destoryBuffer];
        _ready = NO;
        
    } else {
        _ready = YES;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    return _ready;
}

- (void)destoryBuffer {
    if (_frameBufferID) {
        glDeleteFramebuffers(1, &_frameBufferID);
        _frameBufferID = 0;
    }
    if (_textureBufferID) {
        glDeleteTextures(1, &_textureBufferID);
        _textureBufferID = 0;
    }
    _ready = NO;
}


- (BOOL)beginRendering {
    if (!_ready) return NO;
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferID);
    glClear(GL_DEPTH_BUFFER_BIT);
    glViewport(1, 1, _config.width - 2, _config.height - 2);
    return YES;
}


- (void)endRendering {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}


@end
