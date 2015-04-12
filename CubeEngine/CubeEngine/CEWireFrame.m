//
//  CEMeshWireFrame.m
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEWireFrame.h"
#import "CEWireFrame_Rendering.h"
#import "CEMesh_Rendering.h"


@implementation CEWireFrame

- (instancetype)initWithMesh:(CEMesh *)mesh
{
    self = [super init];
    if (self) {
        _vertexData = [mesh.vertexData copy];
        _vertexDataType = mesh.vertexDataType;
        _vertexStride = mesh.vertexStride;
        _indicesDataType = CEIndicesDataType_UShort;
        [self parseMesh:mesh];
    }
    return self;
}

- (void)parseMesh:(CEMesh *)mesh {
    if (!mesh.indicesCount || (mesh.indicesCount % 3 != 0) || !mesh.vertexDataType) {
        return;
    }
    NSData *indicesData = mesh.indicesData;
    NSMutableData *lineIndicesData = [NSMutableData data];
    unsigned int indicesCount = 0;
    NSMutableSet *insertedLineSet = [NSMutableSet set];
    int stride = 3 * (mesh.indicesDataType == CEIndicesDataType_UByte ? sizeof(unsigned char) : sizeof(unsigned short));
    NSRange readRange = NSMakeRange(0, stride);
    for (int i = 0; i < mesh.indicesCount; i += 3) {
        unsigned short indices[3];
        if (mesh.indicesDataType == CEIndicesDataType_UByte) {
            Byte tmpIndices[3];
            [indicesData getBytes:tmpIndices range:readRange];
            indices[0] = tmpIndices[0];
            indices[1] = tmpIndices[1];
            indices[2] = tmpIndices[2];
            
        } else {
            [indicesData getBytes:indices range:readRange];
        }
        
        // change to line indices
        for (int i = 0; i < 3; i++) {
            unsigned short index0 = indices[i];
            unsigned short index1 = indices[(i + 1) % 3];
            NSString *lineId = [NSString stringWithFormat:@"%d%d", index0 + index1, abs(index0 - index1)];
            if (![insertedLineSet containsObject:lineId]) {
                [lineIndicesData appendBytes:&index0 length:sizeof(unsigned short)];
                [lineIndicesData appendBytes:&index1 length:sizeof(unsigned short)];
                [insertedLineSet addObject:lineId];
                indicesCount += 2;
            }
        }
        
        readRange.location += stride;
    }
    
    // TODO: check if should change ushort to ubyte!!!
    
    _indicesDataType = CEIndicesDataType_UShort;
    _indicesData = [lineIndicesData copy];
    _indicesCount = indicesCount;
}


- (NSString *)lineIndentifierWithPoint0:(int)p0 point1:(int)p1 {
    return [NSString stringWithFormat:@"%d%d", p0 + p1, abs(p0 - p1)];
}


#pragma mark - Rendering

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
}


- (BOOL)prepareDrawingWithPositionIndex:(GLint)positionIndex {
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
    return YES;
}


@end
