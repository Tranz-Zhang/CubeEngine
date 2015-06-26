//
//  CEIndicesBuffer.m
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEIndicesBuffer.h"
#import "CEUtils.h"

@implementation CEIndicesBuffer {
    NSData *_indicesBufferData;
    GLsizei _dataSize;
}


- (instancetype)initWithData:(NSData *)bufferData indicesCount:(NSInteger)indicesCount {
    self = [super init];
    if (self) {
        if (bufferData.length &&
            indicesCount > 0 &&
            bufferData.length % indicesCount == 0) {
            _dataSize = (GLsizei)bufferData.length / indicesCount;
        }
        if (_dataSize == 1 || _dataSize == 2 || _dataSize == 4) {
            NSData *compressData = nil;
            CompressIndicesData(bufferData, &compressData, &_dataSize);
            if (compressData) {
                _indicesBufferData = [compressData copy];
                _indicesCount = (GLsizei)indicesCount;
                _indicesDataType = (_dataSize == 1 ? GL_UNSIGNED_BYTE : GL_UNSIGNED_SHORT);
            }
        }
    }
    return self;
}

- (void)dealloc {
    if (_indicesBufferIndex) {
        glDeleteBuffers(1, &_indicesBufferIndex);
        _indicesBufferIndex = 0;
    }
}


- (BOOL)setupBuffer {
    if (_ready) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBufferIndex);
        return YES;
    }
    if (!_indicesBufferData.length || !_indicesCount || !_dataSize) {
        CEError(@"Invalid paramters");
        return NO;
    }
    // setup vertex buffer
    glGenBuffers(1, &_indicesBufferIndex);
    if (_indicesBufferIndex) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBufferIndex);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indicesBufferData.length, _indicesBufferData.bytes, GL_STATIC_DRAW);
        _ready = YES;
    }
    return YES;
}


- (BOOL)bindBuffer {
    if (_ready) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBufferIndex);
    }
    return _ready;
}

@end
