//
//  CERenderManager.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderManager.h"
#import "CEScene_Rendering.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"

// renderer
#import "CEBaseRenderer.h"
#import "CERenderer_V.h"
#import "CERenderer_V_VN.h"

// debug renderer
#import "CEWireframeRenderer.h"
#import "CEAssistRenderer.h"

@implementation CERenderManager {
    EAGLContext *_context;
    CEBaseRenderer *_testRenderer;
    
    // debug renderer
    CEWireframeRenderer *_wireframeRenderer;
    CEAssistRenderer *_assistRenderer;
}

- (instancetype)initWithContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    return self;
}


- (void)renderCurrentScene {
    CEScene *scene = [CEScene currentScene];
    [EAGLContext setCurrentContext:scene.context];
    glClearColor(scene.vec4BackgroundColor.r, scene.vec4BackgroundColor.g, scene.vec4BackgroundColor.b, scene.vec4BackgroundColor.a);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        
    for (CEModel *model in scene.allModels) {
        CERenderer *renderer = [self getRendererWithModel:model];
        [renderer renderObject:model];
    }
    if (scene.enableDebug) {
        [self renderDebugScene];
    }
}


- (CERenderer *)getRendererWithModel:(CEModel *)model {
    CEScene *scene = [CEScene currentScene];
    if (!_testRenderer) {
        [EAGLContext setCurrentContext:_context];
        _testRenderer = [CEBaseRenderer new];
        _testRenderer.maxLightCount = scene.maxLightCount;
        [_testRenderer setupRenderer];
    }
    _testRenderer.camera = scene.camera;
    _testRenderer.lights = scene.allLights;
    
    return _testRenderer;
}

#pragma mark - Debug renderer
- (void)renderDebugScene {
    CEScene *scene = [CEScene currentScene];
    // render wireframe add assist info
    for (CEModel *model in scene.allModels) {
        if (model.showWireframe && model.wireframeBuffer) {
            [[self wireframeRenderer] renderObject:model];
        }
        if (model.showAccessoryLine) {
            [[self assistRender] renderObject:model];
        }
    }
    
    // render light object
    for (CELight *light in scene.allLights) {
        [[self assistRender] renderLight:light];
    }
    
    // render world coordinate
    [[self assistRender] renderWorldOriginCoordinate];
}


- (CEWireframeRenderer *)wireframeRenderer {
    if (!_wireframeRenderer) {
        _wireframeRenderer = [CEWireframeRenderer new];
        _wireframeRenderer.lineWidth = 1.0f;
        [_wireframeRenderer setupRenderer];
    }
    _wireframeRenderer.camera = [CEScene currentScene].camera;
    return _wireframeRenderer;
}


- (CEAssistRenderer *)assistRender {
    if (!_assistRenderer) {
        _assistRenderer = [CEAssistRenderer new];
        [_assistRenderer setupRenderer];
    }
    _assistRenderer.camera = [CEScene currentScene].camera;
    return _assistRenderer;
}


@end









