//
//  CEPVRTextureBuffer.m
//  CubeEngine
//
//  Created by chance on 10/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEPVRTextureBuffer.h"

@implementation CEPVRTextureBuffer {
    NSArray *_dataBlocks;
    BOOL _hasMipmap;
}


- (instancetype)initWithConfig:(CETextureBufferConfig *)config
                    resourceID:(uint32_t)resourceID
                          data:(NSData *)textureData {
    self = [super init];
    if (self) {
        _resourceID = resourceID;
        _config = config;
        [self unpackPVRData:textureData];
    }
    return self;
}


- (void)unpackPVRData:(NSData *)data {
    if (data.length < sizeof(CEPVRTexHeader)) {
        return;
    }
    NSMutableArray *dataBlocks = [NSMutableArray array];
    
    CEPVRTexHeader *header = (CEPVRTexHeader *)data.bytes;
    _config.mipmapLevel = CFSwapInt32LittleToHost(header->numMipmaps);
    uint8_t *bytes = ((uint8_t *)data.bytes) + sizeof(CEPVRTexHeader);
    uint32_t dataLength = CFSwapInt32LittleToHost(header->dataLength);
    uint32_t dataOffset = 0, dataSize = 0;
    uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
    uint32_t width = _config.width, height = _config.height, bpp = 4;
    while (dataOffset < dataLength) {
        if (_config.internalFormat == GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG) {
            blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
            widthBlocks = width / 4;
            heightBlocks = height / 4;
            bpp = 4;
            
        } else {
            blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
            widthBlocks = width / 8;
            heightBlocks = height / 4;
            bpp = 2;
        }
        // Clamp to minimum number of blocks
        if (widthBlocks < 2) widthBlocks = 2;
        if (heightBlocks < 2) heightBlocks = 2;
        
        dataSize = widthBlocks * heightBlocks * ((blockSize  * bpp) / 8);
        
        [dataBlocks addObject:[NSData dataWithBytes:bytes + dataOffset length:dataSize]];
        
        dataOffset += dataSize;
        width = MAX(width >> 1, 1);
        height = MAX(height >> 1, 1);
        if (width < 32 || height < 32) {
            break;
        }
        
//        check the doc to figure out if this parsing is wrong!!!
    }
    
    _dataBlocks = dataBlocks.copy;
    if (dataBlocks.count > 1) {
        _hasMipmap = YES;
        _config.enableMipmap = YES;
        _config.mag_filter = GL_LINEAR;
        _config.min_filter = GL_LINEAR_MIPMAP_LINEAR;
    }
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
    }
    
    if (!_hasMipmap) {
        _config.min_filter = GL_LINEAR;
        _config.enableAnisotropicFiltering = NO;
    }
    // properties that can't changed in pvr texture
    _config.enableMipmap = _hasMipmap;
    _config.mipmapLevel = _dataBlocks.count;
    
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
        !_config.internalFormat ||
        !_dataBlocks.count) {
        return NO;
    }
    
    glGenTextures(1, &_textureBufferID);
    glBindTexture(GL_TEXTURE_2D, _textureBufferID);
    uint32_t width = _config.width;
    uint32_t height = _config.height;
    for (int i = 0; i < _dataBlocks.count; i++) {
        NSData *textureData = _dataBlocks[i];
        glCompressedTexImage2D(GL_TEXTURE_2D, i, _config.internalFormat, width, height, 0, textureData.length, textureData.bytes);
        GLenum error = glGetError();
        if (error != GL_NO_ERROR) { // once fail to setup, PVR Texture can no longer be used.
            CEError(@"ERROR: Fail to setup PVR texture.");
            glDeleteTextures(1, &_textureBufferID);
            _textureBufferID = 0;
            _dataBlocks = nil;
            return NO;
        }
        width = MAX(width >> 1, 1);
        height = MAX(height >> 1, 1);
    }
    [self setupTextureParameterWithConfig:_config];
    glBindTexture(GL_TEXTURE_2D, 0);
    _ready = YES;
    return _ready;
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
    if ([CETextureBuffer supportAnisotropicFiltering]) {
        if (_hasMipmap && config.enableMipmap &&
            _config.enableAnisotropicFiltering) {
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, _dataBlocks.count);
        } else {
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1);
        }
    }
}


@end
