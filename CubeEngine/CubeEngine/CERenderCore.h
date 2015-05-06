//
//  CERenderContext.h
//  CubeEngine
//
//  Created by chance on 5/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

/**
 Response for creating and managing default framebuffer
 */
@interface CERenderCore : NSObject

@property (nonatomic, readonly) EAGLContext *context;
@property (nonatomic, readonly) GLsizei width;
@property (nonatomic, readonly) GLsizei height;

@property (nonatomic, readonly) GLuint defaultFramebuffer;
@property (nonatomic, readonly) GLuint colorRenderbuffer;
@property (nonatomic, readonly) GLuint depthRenderbuffer;
@property (nonatomic, readonly) GLuint stencilRenderBuffer;

@property (nonatomic, assign) BOOL enableDepthBuffer;   // default is YES
@property (nonatomic, assign) BOOL enableStencilBuffer; // default is NO

- (instancetype)initWithContext:(EAGLContext *)context;

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

@end

