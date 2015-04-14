//
//  CEVertexBuffer.m
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEVertexBuffer.h"

@implementation CEVertexBuffer {
    GLuint _vertexBufferIndex;
    NSDictionary *_attributeDict;
    NSDictionary *_offsetDict;
}

- (instancetype)initWithData:(NSData *)vertexBufferData
                  attributes:(NSArray *)attributes
{
    self = [super init];
    if (self) {
        _vertexData = [vertexBufferData copy];
        _vertexStride = 0;
        if (attributes.count) {
            NSMutableDictionary *attributeDirt = [NSMutableDictionary dictionary];
            NSMutableDictionary *offsetDirt = [NSMutableDictionary dictionary];
            GLsizei offset = 0;
            for (CEVBOAttribute *attrib in attributes) {
                GLsizei attributeSize = attrib.dataSize * attrib.dataCount;
                if (attributeSize) {
                    attributeDirt[@(attrib.name)] = attrib;
                    offsetDirt[@(attrib.name)] = @(offset);
                    offset += attributeSize;
                }
            }
            _attributeDict = [attributeDirt copy];
            _offsetDict = [offsetDirt copy];
            _vertexStride = offset;
        }
        // get vertex count
        if (_vertexData.length &&
            _vertexStride &&
            _vertexData.length % _vertexStride == 0) {
            _vertexCount = _vertexData.length / _vertexStride;
            
        } else {
            _vertexData = nil;
            _attributeDict = nil;
            _vertexStride = 0;
            CEError(@"Fail to initialize vertex buffer");
        }
        
        _ready = NO;
    }
    return self;
}

- (void)dealloc {
    if (_vertexBufferIndex) {
        glDeleteBuffers(1, &_vertexBufferIndex);
        _vertexBufferIndex = 0;
    }
}

// return attribute info with the given name, nil if attribute no found
- (CEVBOAttribute *)attributeWithName:(CEVBOAttributeName)name {
    return _attributeDict[@(name)];
}

- (GLuint)offsetOfAttribute:(CEVBOAttributeName)name {
    return [_offsetDict[@(name)] unsignedIntValue];
}


- (BOOL)setupBufferWithContext:(EAGLContext *)context {
    if (_ready) {
        return YES;
    }
    if (!_vertexData.length || !_attributeDict.count || !_vertexStride) {
        CEError(@"Invalid paramters");
        return NO;
    }
    // setup vertex buffer
    glGenBuffers(1, &_vertexBufferIndex);
    if (_vertexBufferIndex) {
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
        glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
        _ready = YES;
    }
    return YES;
}


- (BOOL)prepareAttribute:(CEVBOAttributeName)attribute withProgramIndex:(GLint)programIndex {
    if (!_ready) {
        return NO;
    }
    CEVBOAttribute *attrib = _attributeDict[@(attribute)];
    if (!attrib) {
        CEError(@"Can not find attribute");
        return NO;
    }
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
    const GLvoid *offsetPtr = CE_BUFFER_OFFSET([self offsetOfAttribute:attrib.name]);
    glVertexAttribPointer(programIndex, attrib.dataCount, attrib.dataType, GL_FALSE, _vertexStride, offsetPtr);
    return YES;
}





@end
