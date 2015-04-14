//
//  CEVertexBuffer.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEVBOAttribute.h"

/**
 Representing a vertex buffer in GPU, a data buffer in CPU.
 */

@interface CEVertexBuffer : NSObject

@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic, readonly) NSData *vertexData;
@property (nonatomic, readonly) GLsizei vertexCount;
@property (nonatomic, readonly) GLsizei vertexStride;
@property (nonatomic, readonly) GLuint vertexBufferIndex;

/**
 Initialization
 
 @param vertexBufferData
    data of vertex buffer
 @param attribute
    A array of CEVertexBufferAttributeInfo.
 */
- (instancetype)initWithData:(NSData *)vertexData attributes:(NSArray *)attributes;

// return attribute info
- (CEVBOAttribute *)attributeWithName:(CEVBOAttributeName)name;

/**
 return the offset bit of the given attribute in one vertex element
 example:|     position    |   texture  |      normal     |
         |1.0f, 1.0f, 1.0f,| 2.0f, 2.0f,| 3.0f, 3.0f, 3.0f|
 
 position offset: 0
 texture offset:  12
 normal offset:   20
 */
- (GLuint)offsetOfAttribute:(CEVBOAttributeName)name;


// ceate vertex buffer and pass the vertex data to the buffer.
- (BOOL)setupBufferWithContext:(EAGLContext *)context;

// bind current vertex buffer and setup attribute infos of the vertex buffer by call glVertexAttribPointer()
- (BOOL)prepareAttribute:(CEVBOAttributeName)attribute withProgramIndex:(GLint)programIndex;

@end
