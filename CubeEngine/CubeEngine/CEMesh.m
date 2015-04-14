//
//  CEMesh.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMesh.h"
#import "CEMesh_Rendering.h"
#import "CEMesh_Wireframe.h"
#import "CEUtils.h"

@implementation CEMesh

#pragma mark - Init

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
        if (vertexDataType != CEVertexDataTypeUnknown) {
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
        NSData *compressedData = nil;
        GLsizei elementSize = _indicesDataType;
        CompressIndicesData(_indicesData, &compressedData, &elementSize);
        if (compressedData) {
            _indicesData = compressedData;
            _indicesDataType = elementSize;
        }
        
    } else { // auto generate indices data
        _indicesDataType = vertexCount < 256 ? CEIndicesDataTypeU8 : CEIndicesDataTypeU16;
        int stride = vertexCount < 256 ? sizeof(GLbyte) : sizeof(GLushort);
        NSMutableData *indicesData = [NSMutableData dataWithCapacity:stride * vertexCount];
        for (int index = 0; index < vertexCount; index++) {
            [indicesData appendBytes:&index length:stride];
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
    if (_vertexDataType == CEVertexDataTypeUnknown ||
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



#pragma mark - Wireframe
- (void)setShowWireframe:(BOOL)showWireframe {
    if (showWireframe != _showWireframe) {
        _showWireframe = showWireframe;
        if (showWireframe && !_wireframeIndicesData) {
            // 性能上考虑，这里即使取消显示线框，线框的索引数据依然会保存直到mesh销毁
            [self parseWireframeIndices];
        }
    }
}


- (void)parseWireframeIndices {
    if (!_indicesCount || (_indicesCount % 3 != 0) || !_vertexDataType) {
        return;
    }
    NSMutableData *lineIndicesData = [NSMutableData data];
    unsigned int indicesCount = 0;
    NSMutableSet *insertedLineSet = [NSMutableSet set];
    int stride = (_indicesDataType == CEIndicesDataTypeU8 ? sizeof(GLubyte) : sizeof(GLushort));
    NSRange readRange = NSMakeRange(0, stride);
    for (int i = 0; i < _indicesCount; i += 3) {
        GLuint indices[3];
        for (int i = 0; i < 3; i++) {
            [_indicesData getBytes:(indices + i) range:readRange];
            readRange.location += stride;
        }
        
        // change to line indices
        for (int i = 0; i < 3; i++) {
            GLuint index0 = indices[i];
            GLuint index1 = indices[(i + 1) % 3];
            NSString *lineId = [NSString stringWithFormat:@"%d%d", index0 + index1, abs(index0 - index1)];
            if (![insertedLineSet containsObject:lineId]) {
                [lineIndicesData appendBytes:&index0 length:stride];
                [lineIndicesData appendBytes:&index1 length:stride];
                [insertedLineSet addObject:lineId];
                indicesCount += 2;
            }
        }
    }
    
    // TODO: check if should change ushort to ubyte!!!
    _wireframeIndicesDataType = _indicesDataType;
    _wireframeIndicesData = [lineIndicesData copy];
    _wireframeIndicesCount = indicesCount;
}


- (void)setupWireframeArrayBufferWithContext:(EAGLContext *)context {
    // setup wireframe buffer
    if (_showWireframe && !_wireframeIndicesBufferIndex && _wireframeIndicesData.length) {
        glGenBuffers(1, &_wireframeIndicesBufferIndex);
        if (_wireframeIndicesBufferIndex) {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wireframeIndicesBufferIndex);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, _wireframeIndicesData.length,
                         _wireframeIndicesData.bytes, GL_STATIC_DRAW);
        }
    }
}


- (BOOL)prepareWireframeDrawingWithPositionIndex:(GLint)positionIndex {
    if (_vertexDataType == CEVertexDataTypeUnknown ||
        !_vertexBufferIndex ||
        !_wireframeIndicesBufferIndex ||
        !_vertexStride) {
        return NO;
    }
    
    // setup indices buffer
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _wireframeIndicesBufferIndex);
    if (positionIndex >= 0 && _vertexStride) {
        glVertexAttribPointer(positionIndex, 3, GL_FLOAT, GL_FALSE, _vertexStride, CE_BUFFER_OFFSET(0));
        glEnableVertexAttribArray(positionIndex);
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
            
        case CEVertexDataTypeUnknown:
        default:
            return -1;
    }
}


- (GLsizei)bytesForIndicesDataType:(CEIndicesDataType)dataType {
    switch (dataType) {
        case CEIndicesDataTypeU8:
            return sizeof(GLubyte);
        case CEIndicesDataTypeU16:
            return sizeof(GLushort);
        default:
            return -1;
    }
}


@end
