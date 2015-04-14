//
//  CEIndicesBuffer.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMaxIndicesCount 65535

/**
 Representing a indices buffer in GPU, a data buffer in CPU.
 */
@interface CEIndicesBuffer : NSObject

@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic, readonly) GLsizei indicesCount;
@property (nonatomic, readonly) GLuint indicesBufferIndex;
@property (nonatomic, readonly) GLenum indicesDataType; // GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE

- (instancetype)initWithData:(NSData *)bufferData indicesCount:(NSInteger)indicesCount;

- (BOOL)setupBufferWithContext:(EAGLContext *)context;
- (BOOL)prepareForRendering;


@end
