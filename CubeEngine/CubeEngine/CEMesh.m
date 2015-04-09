//
//  CEMesh.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMesh.h"
#import "CEMesh_Rendering.h"

@implementation CEMesh {
    GLsizei _vertexStride;   // 每组vertex大小
}

- (instancetype)initWithVertexData:(NSData *)vertexData
                    vertexDataType:(CEVertexDataType)vertexDataType {
    return [self initWithVertexData:vertexData vertexDataType:vertexDataType
                        indicesData:nil indicesDataType:0];
}

- (instancetype)initWithVertexData:(NSData *)vertexData
                    vertexDataType:(CEVertexDataType)vertexDataType
                       indicesData:(NSData *)indicesData
                   indicesDataType:(CEIndicesDataType)indicesDataType {
    
    self = [super init];
    if (self) {
        if (vertexDataType != CEVertexDataType_Unknown) {
            _vertexData = [vertexData copy];
            _vertexDataType = vertexDataType;
            _indicesData = [indicesData copy];
            _indicesDataType = indicesDataType;
            
            [self setupMesh];
        }
    }
    return self;
}


- (void)dealloc {
    if (_vertexBufferIndex) {
        glDeleteBuffers(1, &_vertexBufferIndex);
        _vertexBufferIndex = 0;
    }
    
    if (_indicesBufferIndex) {
        glDeleteBuffers(1, &_indicesBufferIndex);
        _indicesBufferIndex = 0;
    }
}


- (void)setupMesh {
    // vertex info
    _vertexStride = [self bytesPerVertexForDataType:_vertexDataType];
    if (_vertexData.length % _vertexStride) {
        CEError(@"Wrong vertext size");
        return;
    }
    int vertexCount = (int)(_vertexData.length / _vertexStride);
    
    // calculate model size
    NSRange readRange = NSMakeRange(0, 3 * sizeof(GLfloat));
    GLfloat maxX = FLT_MIN, maxY = FLT_MIN, maxZ = FLT_MIN;
    GLfloat minX = FLT_MAX, minY = FLT_MAX, minZ = FLT_MAX;
    for (int i = 0; i < vertexCount; i++) {
        GLfloat vertexLocation[3];
        [_vertexData getBytes:vertexLocation range:readRange];
        maxX = MAX(maxX, vertexLocation[0]);
        maxY = MAX(maxY, vertexLocation[1]);
        maxZ = MAX(maxZ, vertexLocation[2]);
        minX = MIN(minX, vertexLocation[0]);
        minY = MIN(minY, vertexLocation[1]);
        minZ = MIN(minZ, vertexLocation[2]);
        readRange.location += _vertexStride;
    }
    
    // original offset
    _offsetFromOrigin = GLKVector3Make((maxX + minX) / 2,
                                       (maxY + minY) / 2,
                                       (maxZ + minZ) / 2);
    _bounds = GLKVector3Make(maxX - minX, maxY - minY, maxZ - minZ);

    // indices info
    if (_indicesData.length) {
        _indicesCount = (GLsizei)_indicesData.length / [self bytesForIndicesDataType:_indicesDataType];
        
    } else { // auto generate indices data
        _indicesDataType = vertexCount < 256 ? CEIndicesDataType_UByte : CEIndicesDataType_UShort;
        int dataSize = vertexCount * (vertexCount < 256 ? sizeof(GLbyte) : sizeof(GLushort));
        NSMutableData *indicesData = [NSMutableData dataWithCapacity:dataSize];
        for (int i = 0; i < vertexCount; i++) {
            if (_indicesDataType == CEIndicesDataType_UByte) {
                GLbyte idx = i;
                [indicesData appendBytes:&idx length:sizeof(idx)];
                
            } else {
                GLushort idx = i;
                [indicesData appendBytes:&idx length:sizeof(idx)];
            }
        }
        _indicesData = [indicesData copy];
        _indicesCount = vertexCount;
    }
}


#pragma mark - Rendering Extension
- (void)setupArrayBuffersWithContext:(EAGLContext *)context {
    // setup vertex buffer
    if (!_vertexBufferIndex && _vertexData.length) {
        glGenBuffers(1, &_vertexBufferIndex);
        if (_vertexBufferIndex) {
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
            glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
            
        }
    }
    // setup indices buffer
    if (!_indicesBufferIndex && _indicesData.length) {
        glGenBuffers(1, &_indicesBufferIndex);
        if (_indicesBufferIndex) {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBufferIndex);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indicesData.length, _indicesData.bytes, GL_STATIC_DRAW);
        }
    }
    #warning ???: should we release data after creation?
}

- (BOOL)prepareDrawingWithPositionIndex:(GLint)positionIndex
                      textureCoordIndex:(GLint)textureCoordIndex
                            normalIndex:(GLint)normalIndex {
    if (_vertexDataType == CEVertexDataType_Unknown ||
        !_vertexBufferIndex ||
        !_indicesBufferIndex ||
        !_vertexStride) {
        return NO;
    }
    
    // setup indices buffer
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indicesBufferIndex);
    if (positionIndex >= 0 && _vertexStride) {
        glVertexAttribPointer(positionIndex, 3, GL_FLOAT, GL_FALSE, _vertexStride, CE_BUFFER_OFFSET(0));
        glEnableVertexAttribArray(positionIndex);
    }
    if (textureCoordIndex >= 0 &&
        (_vertexDataType == CEVertexDataType_V_VT ||
         _vertexDataType == CEVertexDataType_V_VT_VN)) {
        glVertexAttribPointer(textureCoordIndex, 2, GL_FLOAT, GL_FALSE, _vertexStride, CE_BUFFER_OFFSET(3 * sizeof(GLfloat)));
        glEnableVertexAttribArray(textureCoordIndex);
    }
    if (normalIndex >= 0) {
        if (_vertexDataType == CEVertexDataType_V_VN) {
            glVertexAttribPointer(normalIndex, 3, GL_FLOAT, GL_FALSE, _vertexStride, CE_BUFFER_OFFSET(3 * sizeof(GLfloat)));
            glEnableVertexAttribArray(normalIndex);
            
        } else if (_vertexDataType == CEVertexDataType_V_VT_VN) {
            glVertexAttribPointer(normalIndex, 3, GL_FLOAT, GL_FALSE, _vertexStride, CE_BUFFER_OFFSET(5 * sizeof(GLfloat)));
            glEnableVertexAttribArray(normalIndex);
        }
    }
    
    return YES;
}


#pragma mark - Others


- (GLsizei)bytesPerVertexForDataType:(CEVertexDataType)dataType {
    switch (dataType) {
        case CEVertexDataType_V:
            return 3 * sizeof(GLfloat);
        case CEVertexDataType_V_VT:
            return 5 * sizeof(GLfloat);
        case CEVertexDataType_V_VN:
            return 6 * sizeof(GLfloat);
        case CEVertexDataType_V_VT_VN:
            return 8 * sizeof(GLfloat);
            
        case CEVertexDataType_Unknown:
        default:
            return -1;
    }
}

- (GLsizei)bytesForIndicesDataType:(CEIndicesDataType)dataType {
    switch (dataType) {
        case CEIndicesDataType_UByte:
            return sizeof(GLubyte);
        case CEIndicesDataType_UShort:
            return sizeof(GLushort);
        default:
            return -1;
    }
}

@end
