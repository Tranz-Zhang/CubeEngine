//
//  CERenderContext.m
//  CubeEngine
//
//  Created by chance on 5/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderCore.h"

@implementation CERenderCore {
    GLsizei _width;
    GLsizei _height;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [EAGLContext setCurrentContext:context];
        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffers(1, &_defaultFramebuffer);
        NSAssert( _defaultFramebuffer, @"Can't create default frame buffer");
        glGenRenderbuffers(1, &_colorRenderbuffer);
        NSAssert( _colorRenderbuffer, @"Can't create default render buffer");
        
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
        self.enableDepthBuffer = YES;
        self.enableStencilBuffer = NO;
    }
    return self;
}

- (void)dealloc {
    if (_defaultFramebuffer) {
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        if (_colorRenderbuffer) {
            glDeleteRenderbuffers(1, &_colorRenderbuffer);
            _colorRenderbuffer = 0;
        }
        if (_depthRenderbuffer) {
            glDeleteRenderbuffers(1, &_depthRenderbuffer);
            _depthRenderbuffer = 0;
        }
        if (_stencilRenderBuffer) {
            glDeleteRenderbuffers(1, &_stencilRenderBuffer);
            _stencilRenderBuffer = 0;
        }
        
        glDeleteFramebuffers(1, &_defaultFramebuffer);
        _defaultFramebuffer = 0;
    }
}

#pragma mark - Setters & Getters

- (void)setEnableDepthBuffer:(BOOL)enableDepthBuffer {
    if (_enableDepthBuffer != enableDepthBuffer) {
        _enableDepthBuffer = enableDepthBuffer;
        [EAGLContext setCurrentContext:_context];
        if (_enableDepthBuffer) {
            glEnable(GL_DEPTH_TEST);
        } else {
            glDisable(GL_DEPTH_TEST);
        }
    }
}

- (void)setEnableStencilBuffer:(BOOL)enableStencilBuffer {
    if (_enableStencilBuffer != enableStencilBuffer) {
        _enableStencilBuffer = enableStencilBuffer;
        [EAGLContext setCurrentContext:_context];
        if (_enableStencilBuffer) {
            glEnable(GL_STENCIL_TEST);
        } else {
            glDisable(GL_STENCIL_TEST);
        }
    }
}

#pragma mark - API

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {
    // Allocate color buffer backing based on the current layer size
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    if( ! [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer] )  {
        CEError(@"failed to call context");
    }
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    
    if (_enableDepthBuffer) {
        if(!_depthRenderbuffer) {
            glGenRenderbuffers(1, &_depthRenderbuffer);
            NSAssert(_depthRenderbuffer, @"Can't create depth buffer");
        }
        
        glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
        // bind color buffer
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    }
    
    if (_enableStencilBuffer) {
#warning Wrong implementation, use GL_DEPTH24_STENCIL8_OES
        if (!_stencilRenderBuffer) {
            glGenRenderbuffers(1, &_stencilRenderBuffer);
            NSAssert(_depthRenderbuffer, @"Can't create stencil buffer");
        }
        
        glBindRenderbuffer(GL_RENDERBUFFER, _stencilRenderBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8, _width, _height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _stencilRenderBuffer);
        // bind color buffer
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    }
    
    GLenum error;
    if( (error=glCheckFramebufferStatus(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE)  {
        NSLog(@"Failed to make complete framebuffer object 0x%08X", error);
        return NO;
    }
    
    return YES;
}

@end


