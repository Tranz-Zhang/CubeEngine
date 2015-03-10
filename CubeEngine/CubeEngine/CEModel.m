//
//  CEObject.m
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEModel.h"
#import "CEObject_Rendering.h"

@implementation CEModel {
    NSData *_vertexData;
    CEVertextDataType _dataType;
    GLuint _vertexBufferIndex;
}

- (instancetype)initWithVertexData:(NSData *)vertexData
                          dataType:(CEVertextDataType)dataType
{
    self = [super init];
    if (self) {
        _vertexData = vertexData;
        _location = GLKVector3Make(0, 0, 0);
        _scale = 1;
        _vertexBufferIndex = 0;
    }
    return self;
}


- (void)dealloc {
    if (_vertexBufferIndex) {
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
        glBufferData(GL_ARRAY_BUFFER, 0, NULL, GL_STATIC_DRAW);
        glDeleteBuffers(1, &_vertexBufferIndex);
    }
}


- (void)setRotation:(GLfloat)rotationDegree onPivot:(CERotationPivot)rotationPivot {
    @synchronized(self) {
        _rotationDegree = rotationDegree;
        _rotationPivot = rotationPivot;
    }
}

- (GLuint)vertexBufferIndex {
    if (!_vertexBufferIndex && _vertexData.length) {
        glGenBuffers(1, &_vertexBufferIndex);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
        glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
    }
    return _vertexBufferIndex;
}


@end
