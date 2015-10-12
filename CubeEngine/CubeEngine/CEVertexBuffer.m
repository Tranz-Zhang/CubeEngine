//
//  CEVertexDataBuffer.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEVertexBuffer.h"
#import "CEVBOAttribute.h"

@implementation CEVertexBuffer {
    NSData *_vertexData;
    GLuint _vertexArrayId;
    GLuint _vertexBufferId;
}


- (instancetype)initWithData:(NSData *)vertexData attributes:(NSArray *)attributes {
    self = [super init];
    if (self) {
        _vertexData = vertexData;
        _attributes = [attributes copy];
        _attributesType = [CEVBOAttribute attributesTypeWithNames:attributes];
    }
    return self;
}


- (void)dealloc {
    [self destoryBuffer];
    _vertexData = nil;
}


- (BOOL)setupBuffer {
    if (_ready) return YES;
    if (!_vertexData.length || !_attributes.count) {
        return NO;
    }
    
    // gen vertex array object
    glGenVertexArraysOES(1, &_vertexArrayId);
    if (!_vertexArrayId) {
        return NO;
    }
    glBindVertexArrayOES(_vertexArrayId);
    
    // generate vertex buffer
    glGenBuffers(1, &_vertexBufferId);
    if (!_vertexBufferId) {
        [self destoryBuffer];
        return NO;
    }
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferId);
    glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
    
    // setup attribute pointer
    NSArray *attributeInfos = [CEVBOAttribute attributesWithNames:_attributes];
    for (CEVBOAttribute *attributeInfo in attributeInfos) {
        glEnableVertexAttribArray(attributeInfo.name);
        glVertexAttribPointer(attributeInfo.name,
                              attributeInfo.primaryCount,
                              attributeInfo.primaryType,
                              GL_FALSE,
                              attributeInfo.elementStride,
                              CE_BUFFER_OFFSET(attributeInfo.elementOffset));
    }
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    
    _ready = YES;
    return YES;
}


- (void)destoryBuffer {
    if (_vertexArrayId) {
        glDeleteVertexArraysOES(1, &_vertexArrayId);
        _vertexArrayId = 0;
    }
    if (_vertexBufferId) {
        glDeleteBuffers(1, &_vertexBufferId);
        _vertexBufferId = 0;
    }
    _ready = NO;
}


- (BOOL)loadBuffer {
    if (!_ready) return NO;
    glBindVertexArrayOES(_vertexArrayId);
    return YES;
}


- (void)unloadBuffer {
    glBindVertexArrayOES(0);
}


@end
