//
//  CEView.m
//  CubeEngine
//
//  Created by chance on 5/5/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEView.h"
#import "CEView_Rendering.h"

@implementation CEView


+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupLayer];
    }
    return self;
}


- (void)setupLayer {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking   : @NO,
                                     kEAGLDrawablePropertyColorFormat       : kEAGLColorFormatRGBA8};
    eaglLayer.contentsScale = [UIScreen mainScreen].scale;
}


- (void)setRenderCore:(CERenderCore *)renderCore {
    if (_renderCore != renderCore) {
        _renderCore = renderCore;
        [EAGLContext setCurrentContext:_renderCore.context];
        [_renderCore resizeFromLayer:(CAEAGLLayer *)self.layer];
        glViewport(0, 0, _renderCore.width, _renderCore.height);
    }
}


- (void)display {
    [_renderCore.context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:_renderCore.context];
    [_renderCore resizeFromLayer:(CAEAGLLayer *)self.layer];
    glViewport(0, 0, _renderCore.width, _renderCore.height);
}

@end
