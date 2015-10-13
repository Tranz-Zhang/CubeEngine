//
//  CETextureBuffer.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CETextureBufferConfig : NSObject

@property (nonatomic, assign) GLenum mag_filter; // default: GL_LINEAR
@property (nonatomic, assign) GLenum min_filter; // default: GL_LINEAR
@property (nonatomic, assign) GLenum wrap_s; // default: GL_CLAMP_TO_EDGE
@property (nonatomic, assign) GLenum wrap_t; // default: GL_CLAMP_TO_EDGE

@end


@interface CETextureBuffer : NSObject

@property (nonatomic, readonly) uint32_t resourceID;
@property (nonatomic, readonly) GLsizei width;
@property (nonatomic, readonly) GLsizei height;
@property (nonatomic, readonly) CETextureBufferConfig *config;
@property (nonatomic, readonly, getter=isReady) BOOL ready;

// texture properties
@property (nonatomic, assign) GLenum filterMode;
@property (nonatomic, assign) GLenum wrapMode;

- (instancetype)initWithSize:(CGSize)textureSize;

- (instancetype)initWithSize:(CGSize)textureSize
                      config:(CETextureBufferConfig *)config;

- (instancetype)initWithSize:(CGSize)textureSize
                      config:(CETextureBufferConfig *)config
                  resourceID:(uint32_t)resourceID
                        data:(NSData *)textureData;


- (BOOL)setupBuffer;    // initializing a buffer block in video memory
- (void)destoryBuffer;  // delete a buffer from video memory

// load texture into specify texture index in program
- (BOOL)loadBufferToIndex:(GLuint)textureIndex;


@end

