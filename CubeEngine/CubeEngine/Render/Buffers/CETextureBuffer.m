//
//  CETextureBuffer.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CETextureBuffer.h"

#warning add anisotropy filter for texture

@implementation CETextureBuffer {
    BOOL _hasMipmap;
}

+ (BOOL)supportAnisotropicFiltering {
    static NSNumber *supportAnisotropicFiltering = nil;
    if (!supportAnisotropicFiltering) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *extensionsString = [NSString stringWithCString:(char *)glGetString(GL_EXTENSIONS) encoding:NSUTF8StringEncoding];
            NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
            supportAnisotropicFiltering = @([extensionsNames containsObject:@"GL_EXT_texture_filter_anisotropic"]);
        });
    }
    return [supportAnisotropicFiltering boolValue];
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
        _hasMipmap = NO;
    }
    return self;
}

- (void)updateConfig:(CETextureBufferConfig *)config {
    if (!_ready) {
        _config = config;
        return;
    }
    
    if (_config != config) {
        _config.wrap_s = config.wrap_s;
        _config.wrap_t = config.wrap_t;
        _config.mag_filter = config.mag_filter;
        _config.min_filter = config.min_filter;
        _config.enableMipmap = config.enableMipmap;
        _config.mipmapLevel = config.mipmapLevel;
    }
    if (_textureBufferID) {
        glBindTexture(GL_TEXTURE_2D, _textureBufferID);
        [self setupTextureParameterWithConfig:_config];
        glBindTexture(GL_TEXTURE_2D, 0);
    }
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
    [self setupTextureParameterWithConfig:_config];
    glBindTexture(GL_TEXTURE_2D, 0);
    _ready = YES;
    return YES;
}


- (void)setupTextureParameterWithConfig:(CETextureBufferConfig *)config {
    if (config.mag_filter) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, config.mag_filter);
    }
    if (config.min_filter) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, config.min_filter);
    }
    if (config.wrap_s) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, config.wrap_s);
    }
    if (config.wrap_t) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, config.wrap_t);
    }
    if (config.enableMipmap) {
        if (_config.mipmapLevel > 0) {
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL_APPLE, config.mipmapLevel);
            if ([CETextureBuffer supportAnisotropicFiltering]) {
                if (_config.enableAnisotropicFiltering) {
                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, _config.mipmapLevel);
                } else {
                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1);
                }
            }
        }
        if (!_hasMipmap) {
            glGenerateMipmap(GL_TEXTURE_2D);
            _hasMipmap = YES;
        }
    } else {
        if ([CETextureBuffer supportAnisotropicFiltering]) {
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1);
        }
    }
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
        _mipmapLevel = 3;
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



