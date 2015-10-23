//
//  CEVertexBuffer.m
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEVertexBuffer_DEPRECATED.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@implementation CEVertexBuffer_DEPRECATED {
    GLuint _vertexBufferIndex;
    NSDictionary *_attributeDict;
    NSDictionary *_offsetDict;
}


- (instancetype)initWithData:(NSData *)vertexBufferData
                  attributes:(NSArray *)attributes
{
    self = [super init];
    if (self) {
        [self updateVertexData:vertexBufferData attributes:attributes];
    }
    return self;
}


- (void)dealloc {
    if (_vertexBufferIndex) {
        glDeleteBuffers(1, &_vertexBufferIndex);
        _vertexBufferIndex = 0;
    }
}

- (BOOL)updateVertexData:(NSData *)vertexData attributes:(NSArray *)attributes {
    _vertexData = [vertexData copy];
    _vertexStride = 0;
    if (attributes.count) {
        NSMutableDictionary *attributeDirt = [NSMutableDictionary dictionary];
        NSMutableDictionary *offsetDirt = [NSMutableDictionary dictionary];
        GLsizei offset = 0;
        for (CEVBOAttribute *attrib in attributes) {
            GLsizei attributeSize = attrib.primarySize * attrib.primaryCount;
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
        _vertexCount = (int)_vertexData.length / _vertexStride;
        _ready = NO;
        
    } else {
        _vertexData = nil;
        _attributeDict = nil;
        _vertexStride = 0;
        CEError(@"Fail to initialize vertex buffer");
        return NO;
        
    }
    
    return YES;
}

// return attribute info with the given name, nil if attribute no found
- (CEVBOAttribute *)attributeWithName:(CEVBOAttributeName)name {
    return _attributeDict[@(name)];
}

- (GLuint)offsetOfAttribute:(CEVBOAttributeName)name {
    return [_offsetDict[@(name)] unsignedIntValue];
}


- (BOOL)setupBuffer {
    if (_ready) {
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
        return YES;
    }
    if (!_vertexData.length || !_attributeDict.count || !_vertexStride) {
        CEError(@"Invalid paramters");
        return NO;
    }
    // setup vertex buffer
    if (!_vertexBufferIndex) {
        glGenBuffers(1, &_vertexBufferIndex);
    }
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
    glEnableVertexAttribArray(programIndex);
    glVertexAttribPointer(programIndex, attrib.primaryCount, attrib.primaryType, GL_FALSE, _vertexStride, offsetPtr);
    return YES;
}


- (BOOL)prepareAttribute:(CEVBOAttributeName)attribute {
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
    glEnableVertexAttribArray(attribute);
    glVertexAttribPointer(attribute, attrib.primaryCount, attrib.primaryType, GL_FALSE, _vertexStride, offsetPtr);
    return YES;
}


@end
