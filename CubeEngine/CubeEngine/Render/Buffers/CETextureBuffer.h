//
//  CETextureBuffer.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CETextureBufferConfig : NSObject

@property (nonatomic, assign) GLsizei width;
@property (nonatomic, assign) GLsizei height;

@property (nonatomic, assign) GLenum format;        // default: RGBA
@property (nonatomic, assign) GLenum internalFormat;// default: RGBA
@property (nonatomic, assign) GLenum texelType;     // default: GL_UNSIGNED_BYTE

@property (nonatomic, assign) GLenum mag_filter;    // default: GL_LINEAR
@property (nonatomic, assign) GLenum min_filter;    // default: GL_LINEAR
@property (nonatomic, assign) GLenum wrap_s;        // default: GL_CLAMP_TO_EDGE
@property (nonatomic, assign) GLenum wrap_t;        // default: GL_CLAMP_TO_EDGE

@property (nonatomic, assign) BOOL useMipmap;       // default: NO

@end


@interface CETextureBuffer : NSObject{
    NSData *_textureData;
    GLuint _textureBufferID;
    
    CETextureBufferConfig *_config;
    BOOL _ready;
}

@property (nonatomic, readonly) uint32_t resourceID;
@property (nonatomic, readonly) CETextureBufferConfig *config;
@property (nonatomic, readonly, getter=isReady) BOOL ready;

- (instancetype)initWithConfig:(CETextureBufferConfig *)config
                    resourceID:(uint32_t)resourceID;

- (instancetype)initWithConfig:(CETextureBufferConfig *)config
                  resourceID:(uint32_t)resourceID
                        data:(NSData *)textureData;


- (BOOL)setupBuffer;    // initializing a buffer block in video memory
- (void)destoryBuffer;  // delete a buffer from video memory

// load texture into specify texture index in program
- (BOOL)loadBufferToUnit:(GLuint)textureUnit;


@end

