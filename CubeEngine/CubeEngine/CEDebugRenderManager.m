//
//  CEDebugRenderManager.m
//  CubeEngine
//
//  Created by chance on 4/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEDebugRenderManager.h"
#import "CEModel_Rendering.h"
#import "CEWireframeRenderer.h"
#import "CEAssistRenderer.h"

@implementation CEDebugRenderManager {
    EAGLContext *_context;
    CEWireframeRenderer *_wireframeRenderer;
    CEAssistRenderer *_accessoryRenderer;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [EAGLContext setCurrentContext:context];
        _wireframeRenderer = [CEWireframeRenderer new];
        _wireframeRenderer.lineWidth = 1.0f;
        [_wireframeRenderer setupRenderer];
        _accessoryRenderer = [CEAssistRenderer new];
        [_accessoryRenderer setupRenderer];
    }
    return self;
}


- (void)renderWireframeForModels:(NSArray *)models {
    for (CEModel *model in models) {
        if (model.showWireframe && model.wireframeBuffer) {
            [_wireframeRenderer renderObject:model];
        }
        if (model.showAccessoryLine) {
            [_accessoryRenderer renderObject:model];
        }
    }
}

- (void)renderLights:(NSArray *)lights {
    for (CELight *light in lights) {
        [_accessoryRenderer renderLight:light];
    }
}

- (void)renderWorldSpaceCoordinates {
    [_accessoryRenderer renderWorldOriginCoordinate];
}

@end
