//
//  CEWireFrame_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEWireFrame.h"

@interface CEWireFrame ()

// vertex buffer
@property (nonatomic, readonly) NSData *vertexData;
@property (nonatomic, readonly) GLuint vertexBufferIndex;
@property (nonatomic, readonly) CEVertexDataType vertexDataType;
@property (nonatomic, readonly) GLsizei vertexStride;

// indices buffer info
@property (nonatomic, readonly) GLuint indicesBufferIndex;
@property (nonatomic, readonly) NSData *indicesData;
@property (nonatomic, readonly) GLsizei indicesCount;
@property (nonatomic, readonly) CEIndicesDataType indicesDataType;

// setup vertex buffer in opengles
- (void)setupArrayBuffersWithContext:(EAGLContext *)context;

- (BOOL)prepareDrawingWithPositionIndex:(GLint)positionIndex;

@end
