//
//  CEIndiceBuffer.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 represent a indice buffer in opengles, offering essential information for drawing indices.
 */
@interface CEIndiceBuffer : NSObject

@property (nonatomic, readonly) uint32_t indiceCount;
@property (nonatomic, readonly) GLenum primaryType; // GL_UNSIGNED_SHORT or GL_UNSIGNED_BYTE
@property (nonatomic, readonly) GLenum drawMode;    // GL_TRIANGLES or GL_TRIANGLE_STRIP
@property (nonatomic, readonly, getter=isReady) BOOL ready;

- (instancetype)initWithData:(NSData *)indiceData
                 indiceCount:(uint32_t)indiceCount
                 primaryType:(GLenum)primaryType
                    drawMode:(GLenum)drawMode;


- (BOOL)setupBuffer;    // initializing a buffer block in video memory
- (void)destoryBuffer;  // delete a buffer from video memory

- (BOOL)loadBuffer;     // bind current buffer
- (void)unloadBuffer;   // unbind current buffer

@end
