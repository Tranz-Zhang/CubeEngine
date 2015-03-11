//
//  CEObject.m
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEModel.h"
#import "CEModel_Rendering.h"

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

#pragma mark - Rendering
- (void)generateVertexBufferInContext:(EAGLContext *)context {
    if (!_vertexBufferIndex && _vertexData.length) {
        [EAGLContext setCurrentContext:context];
        glGenBuffers(1, &_vertexBufferIndex);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
        glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
    }
}


- (GLKMatrix4)transformMatrix {
#warning Consider offer center transfrom
    @synchronized(self) {
        GLKMatrix4 tranformMatrix = GLKMatrix4MakeTranslation(_location.x,
                                                              _location.y,
                                                              _location.z);
        if (_rotationPivot) {
            tranformMatrix = GLKMatrix4Rotate(tranformMatrix,
                                              GLKMathDegreesToRadians(_rotationDegree),
                                              _rotationPivot & CERotationPivotX ? 1 : 0,
                                              _rotationPivot & CERotationPivotY ? 1 : 0,
                                              _rotationPivot & CERotationPivotZ ? 1 : 0);
        }
        if (_scale != 1) {
            GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(_scale, _scale, _scale);
            GLKMatrix4 adjustMatrix = GLKMatrix4MakeTranslation(-1, 0, 0);
            GLKMatrix4 transposeAdjustMatrix = GLKMatrix4Invert(adjustMatrix, NULL);
            tranformMatrix = GLKMatrix4Multiply(transposeAdjustMatrix, GLKMatrix4Multiply(scaleMatrix, GLKMatrix4Multiply(adjustMatrix, tranformMatrix)));
        }
        return tranformMatrix;
    }
}



@end


