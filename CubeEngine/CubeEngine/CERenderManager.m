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
#import "CELight_Rendering.h"

// renderer
#import "CEBaseRenderer.h"
#import "CEShadowRenderer.h"
#import "CEShadowMapRenderer.h"
#import "CERenderer_V.h"
#import "CERenderer_V_VN.h"

// debug renderer
#import "CEWireframeRenderer.h"
#import "CEAssistRenderer.h"
#import "CETextureRenderer.h"

// test
#import "CEMainProgram.h"
#import "CEMainRenderer.h"


@implementation CERenderManager {
    EAGLContext *_context;
    CEBaseRenderer *_defaultRenderer;
    CEShadowMapRenderer *_shadowMapRenderer;
    
    CEShadowRenderer *_testShadowMapRenderer;
    CEBaseRenderer *_testBaseRenderer;
    CETextureRenderer *_testTextureRenderer;
    CEMainRenderer *_mainRenderer;
    
    // debug renderer
    CEWireframeRenderer *_wireframeRenderer;
    CEAssistRenderer *_assistRenderer;
    
}


- (instancetype)initWithContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        [self testProgramGeneration];
    }
    
    return self;
}


- (void)testProgramGeneration {
    printf("testProgramGeneration... ");
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [EAGLContext setCurrentContext:_context];
    CEProgramConfig *config = [CEProgramConfig new];
    CEMainProgram *program = [CEMainProgram programWithConfig:config];
    config.lightCount = 2;
    program = [CEMainProgram programWithConfig:config];
    config.enableTexture = YES;
    program = [CEMainProgram programWithConfig:config];
    config.enableNormalMapping = YES;
    program = [CEMainProgram programWithConfig:config];
    config.shadowMappingCount = 2;
    program = [CEMainProgram programWithConfig:config];
    printf("%.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
}


- (void)renderCurrentScene {
    CEScene *scene = [CEScene currentScene];
    [EAGLContext setCurrentContext:scene.context];
    
    // try render shadow mapp if needed
    [self renderShadowMapsForScene:scene];
    
    glBindFramebuffer(GL_FRAMEBUFFER, scene.renderCore.defaultFramebuffer);
    glClearColor(scene.vec4BackgroundColor.r, scene.vec4BackgroundColor.g, scene.vec4BackgroundColor.b, scene.vec4BackgroundColor.a);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, scene.renderCore.width, scene.renderCore.height);
    
#if 0
    // TODO: sort model with materials
    CERenderer *renderer = [self getTestShadowRenderer];
    [renderer renderObjects:scene.allModels];
#else
    CEMainRenderer *renderer = [self testMainRenderer];
    [renderer renderObjects:[self visibleModelsInScene:scene]];
#endif
    
    // render debug info
    if (scene.enableDebug) {
        [self renderDebugScene];
    }
}


- (CERenderer *)getRendererWithModel:(CEModel *)model {
    CEScene *scene = [CEScene currentScene];
    if (!_defaultRenderer) {
        [EAGLContext setCurrentContext:_context];
        _defaultRenderer = [CEBaseRenderer new];
        _defaultRenderer.maxLightCount = scene.maxLightCount;
        _defaultRenderer.context = scene.context;
        [_defaultRenderer setupRenderer];
    }
    _defaultRenderer.camera = scene.camera;
    _defaultRenderer.lights = scene.allLights;
    
    return _defaultRenderer;
}


- (NSSet *)visibleModelsInScene:(CEScene *)scene {
    NSMutableSet *models = [NSMutableSet set];
    for (CEModel *model in scene.allModels) {
        [self addVisiableModel:model toSet:models];
    }
    return [models copy];
}


- (void)addVisiableModel:(CEModel *)model toSet:(NSMutableSet *)models {
    for (CEModel *child in model.childObjects) {
        [self addVisiableModel:child toSet:models];
    }
    if (model.vertexBuffer) {
        [models addObject:model];
    }
}


#pragma mark - Test Renderer


- (CEBaseRenderer *)getTestBaseRenderer {
    CEScene *scene = [CEScene currentScene];
    if (!_testBaseRenderer) {
        [EAGLContext setCurrentContext:_context];
        _testBaseRenderer = [[CEBaseRenderer alloc] init];
        _testBaseRenderer.context = scene.context;
        [_testBaseRenderer setupRenderer];
    }
    _testBaseRenderer.lights = scene.allLights;
    _testBaseRenderer.camera = scene.camera;
    
    return _testBaseRenderer;
}


- (CEShadowRenderer *)getTestShadowRenderer {
    CEScene *scene = [CEScene currentScene];
    if (!_testShadowMapRenderer) {
        [EAGLContext setCurrentContext:_context];
        _testShadowMapRenderer = [[CEShadowRenderer alloc] init];
        _testShadowMapRenderer.context = scene.context;
        [_testShadowMapRenderer setupRenderer];
    }
    
    _testShadowMapRenderer.lights = scene.allLights;
    _testShadowMapRenderer.camera = scene.camera;
    
    return _testShadowMapRenderer;
}


- (CETextureRenderer *)getTestTextureRenderer {
    CEScene *scene = [CEScene currentScene];
    if (!_testTextureRenderer) {
        [EAGLContext setCurrentContext:_context];
        _testTextureRenderer = [[CETextureRenderer alloc] init];
        _testTextureRenderer.context = scene.context;
        [_testTextureRenderer setupRenderer];
    }
    
    _testTextureRenderer.lights = scene.allLights;
    _testTextureRenderer.camera = scene.camera;
    
    return _testTextureRenderer;
}

- (CEMainRenderer *)testMainRenderer {
    CEScene *scene = [CEScene currentScene];
    if (!_mainRenderer) {
        [EAGLContext setCurrentContext:_context];
        CEProgramConfig *config = [CEProgramConfig new];
        config.lightCount = 0;
        config.shadowMappingCount = 0;
        config.enableNormalMapping = NO;
        config.enableTexture = NO;
        _mainRenderer = [CEMainRenderer rendererWithConfig:config];
    }
    _mainRenderer.lights = scene.allLights;
    _mainRenderer.camera = scene.camera;
    return _mainRenderer;
}


#pragma mark - Shadow Mapping
- (void)renderShadowMapsForScene:(CEScene *)scene {
    // check if need render shadow map
    NSMutableSet *shadowLights = [NSMutableSet set];
    NSMutableSet *shadowModels = [NSMutableSet set];
    for (CELight *light in scene.allLights) {
        if (light.enabled && light.enableShadow) {
            [shadowLights addObject:light];
        }
    }
    for (CEModel *model in scene.allModels) {
        if (model.castShadows) {
            [shadowModels addObject:model];
        }
    }
    if (!shadowLights.count || !shadowModels.count) {
        // no need to render shadow maps
        return;
    }
    
    // check shadow map renderer
    if (!_shadowMapRenderer) {
        _shadowMapRenderer = [[CEShadowMapRenderer alloc] init];
        _shadowMapRenderer.context = scene.context;
        [_shadowMapRenderer setupRenderer];
    }
    _shadowMapRenderer.camera = scene.camera;
    
    // render shadow maps
    for (CELight *light in shadowLights) {
        [light.shadowMapBuffer setupBuffer];
        [light.shadowMapBuffer prepareBuffer];
        [light updateLightVPMatrixWithModels:shadowModels];
        _shadowMapRenderer.lightVPMatrix = GLKMatrix4Multiply(light.lightProjectionMatrix, light.lightViewMatrix);
        [_shadowMapRenderer renderObjects:shadowModels];
    }
}


#pragma mark - Debug renderer
- (void)renderDebugScene {
    CEScene *scene = [CEScene currentScene];
    // render wireframe add assist info
    [[self wireframeRenderer] renderObjects:scene.allModels];
    [[self assistRender] renderObjects:scene.allModels];
    [[self assistRender] renderLights:scene.allLights];
    [[self assistRender] renderWorldOriginCoordinate];
}


- (CEWireframeRenderer *)wireframeRenderer {
    if (!_wireframeRenderer) {
        _wireframeRenderer = [CEWireframeRenderer new];
        _wireframeRenderer.lineWidth = 1.0f;
        _wireframeRenderer.context = [CEScene currentScene].context;
        [_wireframeRenderer setupRenderer];
    }
    _wireframeRenderer.camera = [CEScene currentScene].camera;
    return _wireframeRenderer;
}


- (CEAssistRenderer *)assistRender {
    if (!_assistRenderer) {
        _assistRenderer = [CEAssistRenderer new];
        _assistRenderer.context = [CEScene currentScene].context;
        [_assistRenderer setupRenderer];
    }
    _assistRenderer.camera = [CEScene currentScene].camera;
    return _assistRenderer;
}




@end







