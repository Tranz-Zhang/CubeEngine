//
//  CEVertexDataBuffer.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "CEVBOAttribute.h"

/**
 represent a vertex buffer in opengles
 */
@interface CEVertexBuffer : NSObject

- (instancetype)initWithData:(NSData *)vertexData
                  attributes:(NSArray *)attributes;

@property (nonatomic, readonly) NSArray *attributes;
@property (nonatomic, readonly) uint32_t attributesType;
@property (nonatomic, readonly) uint32_t vertexCount;
@property (nonatomic, readonly, getter=isReady) BOOL ready;


- (BOOL)setupBuffer;    // initializing a buffer block in video memory
- (void)destoryBuffer;  // delete a buffer from video memory

- (BOOL)loadBuffer;     // bind current buffer
- (void)unloadBuffer;   // unbind current buffer

@end
