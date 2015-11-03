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

// texture filter
@property (nonatomic, assign) GLenum mag_filter;    // default: GL_LINEAR
@property (nonatomic, assign) GLenum min_filter;    // default: GL_LINEAR
@property (nonatomic, assign) GLenum wrap_s;        // default: GL_CLAMP_TO_EDGE
@property (nonatomic, assign) GLenum wrap_t;        // default: GL_CLAMP_TO_EDGE

// mipmap
@property (nonatomic, assign) BOOL enableMipmap;                // default: NO
@property (nonatomic, assign) BOOL enableAnisotropicFiltering;  // default: NO
@property (nonatomic, assign) GLint mipmapLevel;                // default: 3

@end


@interface CETextureBuffer : NSObject {
    GLuint _textureBufferID;
    uint32_t _resourceID;
    
    CETextureBufferConfig *_config;
    BOOL _ready;
}

@property (nonatomic, readonly) uint32_t resourceID;
@property (nonatomic, readonly) CETextureBufferConfig *config;
@property (nonatomic, readonly, getter=isReady) BOOL ready;

+ (BOOL)supportAnisotropicFiltering;

- (instancetype)initWithConfig:(CETextureBufferConfig *)config
                    resourceID:(uint32_t)resourceID;

- (instancetype)initWithConfig:(CETextureBufferConfig *)config
                  resourceID:(uint32_t)resourceID
                        data:(NSData *)textureData;

/** 
 update config of texture 
 @note: only #texture filter# params and #mipmap# params can be changed after texture buffer is setup
 */
- (void)updateConfig:(CETextureBufferConfig *)config;


/** load the texture into GPU */
- (BOOL)setupBuffer;

/** remove the texture from GPU */
- (void)destoryBuffer;

// load texture into specify texture index in program
- (BOOL)loadBufferToUnit:(GLuint)textureUnit;


@end

