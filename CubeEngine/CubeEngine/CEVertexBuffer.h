//
//  CEVertexBuffer.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEVertexBufferAttributeInfo.h"

/**
 Representing a vertex buffer in GPU, a data buffer in CPU.
 */

@interface CEVertexBuffer : NSObject

@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic, readonly) GLsizei vertexCount;

/**
 Initialization
 
 @param vertexBufferData
    data of vertex buffer
 @param attribute
    A array of CEVertexBufferAttributeInfo.
 */
- (instancetype)initWithData:(NSData *)vertexBufferData attributes:(NSArray *)attributes;

- (BOOL)setupBufferWithContext:(EAGLContext *)context;
- (BOOL)prepareAttribute:(CEAttributeName)attribute withProgramIndex:(GLint)programIndex;
- (GLuint)vertexBufferIndexForAttribute:(CEAttributeName)attribute;

@end
