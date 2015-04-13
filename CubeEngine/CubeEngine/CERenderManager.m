//
//  CERenderManager.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderManager.h"
#import "CERender_V.h"
#import "CEWireframeRenderer.h"
#import "CEMesh_Rendering.h"
#import "CEMesh_Wireframe.h"

@implementation CERenderManager {
    EAGLContext *_context;
    CERenderer *_testRenderer;
    CERenderer *_wireframeRenderer;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [EAGLContext setCurrentContext:context];
        _testRenderer = [CERender_V new];
        [_testRenderer setupRenderer];
        _wireframeRenderer = [CEWireframeRenderer new];
        [_wireframeRenderer setupRenderer];
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
        [model.mesh setupArrayBuffersWithContext:_context];
        _testRenderer.cameraProjectionMatrix = _cameraProjectionMatrix;
        [_testRenderer renderObject:model];
        
        if (model.mesh.showWireframe) {
            glLineWidth(2);
            [model.mesh setupWireframeArrayBufferWithContext:_context];
            _wireframeRenderer.cameraProjectionMatrix = _cameraProjectionMatrix;
            [_wireframeRenderer renderObject:model];
        }
    }
}

@end
