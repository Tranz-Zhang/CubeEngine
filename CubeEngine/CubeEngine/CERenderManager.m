//
//  CERenderManager.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderManager.h"
#import "CEModel_Rendering.h"

// render
#import "CERenderer_V.h"
#import "CERenderer_Wireframe.h"
#import "CERenderer_AccessoryLine.h"


@implementation CERenderManager {
    EAGLContext *_context;
    CERenderer *_testRenderer;
    CERenderer *_wireframeRenderer;
    CERenderer_AccessoryLine *_accessoryLineRenderer;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [EAGLContext setCurrentContext:context];
        _testRenderer = [CERenderer_V new];
        [_testRenderer setupRenderer];
        _wireframeRenderer = [CERenderer_Wireframe new];
        [_wireframeRenderer setupRenderer];
        _accessoryLineRenderer = [CERenderer_AccessoryLine new];
        [_accessoryLineRenderer setupRenderer];
        
    }
    return self;
}


- (void)renderModels:(NSArray *)models {
    if (!models.count) return;
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // enable depth test
    glEnable(GL_DEPTH_TEST);
    
    for (CEModel *model in models) {
        // TODO: select render base on current model
        
        _testRenderer.cameraProjectionMatrix = _cameraProjectionMatrix;
        [_testRenderer renderObject:model];
        if (model.showWireframe && model.wireframeBuffer) {
            _wireframeRenderer.cameraProjectionMatrix = _cameraProjectionMatrix;
            [_wireframeRenderer renderObject:model];
        }
        if (model.showAccessoryLine) {
            _accessoryLineRenderer.cameraProjectionMatrix = _cameraProjectionMatrix;
            [_accessoryLineRenderer renderObject:model];
        }
    }
#if DEBUG
    [_accessoryLineRenderer renderWorldOriginCoordinate];
#endif
}

@end
