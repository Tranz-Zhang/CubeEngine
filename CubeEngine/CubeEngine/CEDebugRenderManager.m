//
//  CEDebugRenderManager.m
//  CubeEngine
//
//  Created by chance on 4/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEDebugRenderManager.h"
#import "CEModel_Rendering.h"
#import "CERenderer_Wireframe.h"
#import "CERenderer_AccessoryLine.h"

@implementation CEDebugRenderManager {
    EAGLContext *_context;
    CERenderer_Wireframe *_wireframeRenderer;
    CERenderer_AccessoryLine *_accessoryRenderer;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [EAGLContext setCurrentContext:context];
        _wireframeRenderer = [CERenderer_Wireframe new];
        _wireframeRenderer.lineWidth = 1.0f;
        [_wireframeRenderer setupRenderer];
        _accessoryRenderer = [CERenderer_AccessoryLine new];
        [_accessoryRenderer setupRenderer];
    }
    return self;
}

- (void)setCamera:(CECamera *)camera {
    if (_camera != camera) {
        _camera = camera;
        _accessoryRenderer.camera = camera;
        _wireframeRenderer.camera = camera;
    }
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
