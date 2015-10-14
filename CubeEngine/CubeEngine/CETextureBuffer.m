//
//  CETextureBuffer.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CETextureBuffer.h"

@implementation CETextureBuffer {
    NSData *_textureData;
    GLuint _textureBufferID;
}


- (instancetype)initWithConfig:(CETextureBufferConfig *)config resourceID:(uint32_t)resourceID {
    return [self initWithConfig:config resourceID:resourceID data:nil];
}

- (instancetype)initWithConfig:(CETextureBufferConfig *)config
                    resourceID:(uint32_t)resourceID
                          data:(NSData *)textureData {
    self = [super init];
    if (self) {
        _resourceID = resourceID;
        _config = config;
        _textureData = textureData;
    }
    return self;
}


- (BOOL)setupBuffer {
    if (_ready) return YES;
    if (!_config ||
        _config.width * _config.height == 0 ||
        !_config.texelType ||
        !_config.format ||
        !_config.internalFormat) {
        return NO;
    }
    glGenTextures(1, &_textureBufferID);
    glBindTexture(GL_TEXTURE_2D, _textureBufferID);
    glTexImage2D(GL_TEXTURE_2D, 0, _config.internalFormat, _config.width, _config.height, 0, _config.format, _config.texelType, _textureData.bytes);
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
    glBindTexture(GL_TEXTURE_2D, 0);
    _ready = YES;
    return YES;
}


- (void)destoryBuffer {
    if (_textureBufferID) {
        glDeleteTextures(1, &_textureBufferID);
        _textureBufferID = 0;
    }
    _ready = NO;
}


- (BOOL)loadBufferToUnit:(GLuint)textureUnit {
    if (!_ready) return NO;
    glActiveTexture(GL_TEXTURE0 + textureUnit);
    glBindTexture(GL_TEXTURE_2D, _textureBufferID);
    return YES;
}


@end



@implementation CETextureBufferConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _mag_filter = GL_LINEAR;
        _min_filter = GL_LINEAR;
        _wrap_s = GL_CLAMP_TO_EDGE;
        _wrap_t = GL_CLAMP_TO_EDGE;
    }
    return self;
}


- (void)setMag_filter:(GLenum)mag_filter {
    if (mag_filter == GL_LINEAR || mag_filter == GL_NEAREST) {
        _mag_filter = mag_filter;
    }
}

- (void)setMin_filter:(GLenum)min_filter {
    if (min_filter == GL_LINEAR ||
        min_filter == GL_NEAREST ||
        min_filter == GL_NEAREST_MIPMAP_NEAREST ||
        min_filter == GL_LINEAR_MIPMAP_NEAREST ||
        min_filter == GL_NEAREST_MIPMAP_LINEAR ||
        min_filter == GL_LINEAR_MIPMAP_LINEAR) {
        _min_filter = min_filter;
    }
}

- (void)setWrap_s:(GLenum)wrap_s {
    if (wrap_s == GL_CLAMP_TO_EDGE ||
        wrap_s == GL_REPEAT ||
        wrap_s == GL_MIRRORED_REPEAT) {
        _wrap_s = wrap_s;
    }
}

- (void)setWrap_t:(GLenum)wrap_t {
    if (wrap_t == GL_CLAMP_TO_EDGE ||
        wrap_t == GL_REPEAT ||
        wrap_t == GL_MIRRORED_REPEAT) {
        _wrap_t = wrap_t;
    }
}

@end



