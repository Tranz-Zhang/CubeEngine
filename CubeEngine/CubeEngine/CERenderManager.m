//
//  CERenderManager.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderManager.h"
#import "CERender_V.h"
#import "CEMesh_Rendering.h"

@implementation CERenderManager {
    EAGLContext *_context;
    CEBaseRender *_testRender;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        _testRender = [CERender_V new];
        [EAGLContext setCurrentContext:context];
        [_testRender prepareRender];
    }
    return self;
}


- (void)renderModels:(NSArray *)models {
    if (!models.count) return;
    [EAGLContext setCurrentContext:_context];
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClearDepthf(1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    // enable depth test
    glEnable(GL_DEPTH_TEST);
    
    for (CEModel *model in models) {
        // TODO: select render base on current model
        [model.mesh setupArrayBuffersWithContext:_context];
        _testRender.cameraProjectionMatrix = _cameraProjectionMatrix;
        [_testRender renderModel:model];
    }
}

@end
