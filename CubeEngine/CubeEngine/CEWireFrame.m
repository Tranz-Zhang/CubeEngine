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
        _vertexData = [self parseMesh:mesh];
    }
    return self;
}

- (NSDate *)parseMesh:(CEMesh *)mesh {
    if (!mesh.indicesCount || (mesh.indicesCount % 3 != 0) || !mesh.vertexDataType) {
        return nil;
    }
    NSData *vertexData = mesh.vertexData;
    NSMutableData *lineData = [NSMutableData data];
    NSMutableSet *insertedLineSet = [NSMutableSet set];
    NSRange readRange = NSMakeRange(0, 3 * sizeof(GLfloat));
    for (int i = 0; i < mesh.indicesCount; i += 3) {
        GLfloat vertexLocation[9]; // three vectex position
        [_vertexData getBytes:vertexLocation range:readRange];
        maxX = MAX(maxX, vertexLocation[0]);
        maxY = MAX(maxY, vertexLocation[1]);
        maxZ = MAX(maxZ, vertexLocation[2]);
        minX = MIN(minX, vertexLocation[0]);
        minY = MIN(minY, vertexLocation[1]);
        minZ = MIN(minZ, vertexLocation[2]);
        readRange.location += _vertexStride;
    }
}


#pragma mark - Rendering

- (void)setupArrayBuffersWithContext:(EAGLContext *)context {
    if (!_vertexBufferIndex && _vertexData.length) {
        glGenBuffers(1, &_vertexBufferIndex);
        if (_vertexBufferIndex) {
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIndex);
            glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);
        }
    }
}


@end
