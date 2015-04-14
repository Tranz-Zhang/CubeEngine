//
//  CEMesh_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMesh.h"

@interface CEMesh ()

// vertex buffer info
@property (nonatomic, readonly) GLuint vertexBufferIndex;
@property (nonatomic, readonly) NSData *vertexData;
@property (nonatomic, readonly) CEVertexDataType vertexDataType;
@property (nonatomic, readonly) GLsizei vertexStride;

// indices buffer info
@property (nonatomic, readonly) GLuint indicesBufferIndex;
@property (nonatomic, readonly) NSData *indicesData;
@property (nonatomic, readonly) GLsizei indicesCount;
@property (nonatomic, readonly) CEIndicesDataType indicesDataType;

// setup vertex buffer in opengles
- (void)setupArrayBuffersWithContext:(EAGLContext *)context;

// 设置vertexBuffer中的属性信息
// glVertexAttribPointer([Position]/[TextureCoord]/[Normal], ...)
- (BOOL)prepareDrawingWithPositionIndex:(GLint)positionIndex
                      textureCoordIndex:(GLint)textureCoordIndex
                            normalIndex:(GLint)normalIndex;

- (BOOL)prepareAttributeWithPositionIndex:(GLint)positionIndex;
- (BOOL)prepareAttributeWithTextureCoordIndex:(GLint)textureCoordIndex;
- (BOOL)prepareAttributeWithNormalIndex:(GLint)normalIndex;

// a more common method to setup attribute vertex info
- (BOOL)prepareAttribute:(int)attribute withProgramIndex:(GLint)programIndex;

// ? should the super class deal with vertex buffer

/**
 subclass offer vertex base infos, and the super use these info to deal with initialization.
 
 - (NSData *)vertexBufferData;
 - (NSArray *)vertexBufferElementLayout;
 
 */

/**
 CEVertexBufferLayout
 - attributeName
 - attributeCount
 - attribyteSize
 */

#warning change to three methods


@end
