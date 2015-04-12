//
//  CEMesh_Wireframe.h
//  CubeEngine
//
//  Created by chance on 4/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMesh.h"

@interface CEMesh ()

// wireframe indices buffer info
@property (nonatomic, readonly) GLuint wireframeIndicesBufferIndex;
@property (nonatomic, readonly) NSData *wireframeIndicesData;
@property (nonatomic, readonly) GLsizei wireframeIndicesCount;
@property (nonatomic, readonly) CEIndicesDataType wireframeIndicesDataType;

// setup vertex buffer in opengles
- (void)setupWireframeArrayBufferWithContext:(EAGLContext *)context;

// 设置vertexBuffer中的属性信息
- (BOOL)prepareWireframeDrawingWithPositionIndex:(GLint)positionIndex;

@end
