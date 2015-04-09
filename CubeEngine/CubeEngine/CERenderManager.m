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
    for (CEModel *model in models) {
        // TODO: select render base on current model
        [model.mesh setupArrayBuffersWithContext:_context];
        [_testRender renderModel:model];
    }
}

@end
