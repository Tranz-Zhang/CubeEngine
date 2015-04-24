//
//  CERenderManager.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderManager.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"

// render
#import "CEBaseRenderer.h"
#import "CERenderer_V.h"
#import "CERenderer_V_VN.h"
#import "CERenderer_Dev.h"
#import "CERenderer_DirectionalLight.h"
#import "CERenderer_PointLight.h"


@implementation CERenderManager {
    EAGLContext *_context;
    CEBaseRenderer *_testRenderer;
    
    GLfloat _backgroundRed;
    GLfloat _backgroundGreen;
    GLfloat _backgroundBlue;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [EAGLContext setCurrentContext:context];
        _testRenderer = [CEBaseRenderer new];
//        _testRenderer = [CERenderer_DirectionalLight shareRenderer];
//        _testRenderer = [CERenderer_V_VN new];
        [_testRenderer setupRenderer];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = [backgroundColor copy];
        CGFloat red, green, blue;
        [backgroundColor getRed:&red green:&green blue:&blue alpha:NULL];
        _backgroundRed = red;
        _backgroundGreen = green;
        _backgroundBlue = blue;
    }
}

- (void)setLights:(NSArray *)lights {
    if (_lights != lights) {
        _lights = [lights copy];
        _testRenderer.lights = lights;
    }
}

- (void)renderModels:(NSArray *)models {
    glClearColor(_backgroundRed, _backgroundGreen, _backgroundBlue, 1.0);
//    glClearDepthf(0.9978f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // enable depth test
    glEnable(GL_DEPTH_TEST);
//    glDepthFunc(GL_NEVER);
        
    for (CEModel *model in models) {
        // TODO: select render base on current model
        _testRenderer.camera = _camera;
        [_testRenderer renderObject:model];
    }
}

@end
