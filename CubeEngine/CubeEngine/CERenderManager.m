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
#import "CEShadowLight_Rendering.h"

// renderer
#import "CEMainRenderer.h"
#import "CEShadowMapRenderer.h"

// debug renderer
#import "CEWireframeRenderer.h"
#import "CEAssistRenderer.h"
#import "CETextureRenderer.h"

// test
#import "CEMainProgram.h"


@implementation CERenderManager {
    EAGLContext *_context;
    NSMutableDictionary *_rendererDict; // @{CEProgramConfig:CEMainRenderer}
    CEMainRenderer *_mainRenderer;
    CEShadowMapRenderer *_shadowMapRenderer;
    
    // debug renderer
    CEWireframeRenderer *_wireframeRenderer;
    CEAssistRenderer *_assistRenderer;
    
}


- (instancetype)initWithContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        _rendererDict = [NSMutableDictionary dictionary];
        [self testProgramGeneration];
    }
    
    return self;
}

- (void)renderCurrentScene {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CEScene *scene = [CEScene currentScene];
    [EAGLContext setCurrentContext:scene.context];
    
    // 1. get all visiable objects(without empty group)
    NSMutableSet *allModels = [NSMutableSet set];
    for (CEModel *model in scene.allModels) {
        [self recursiveAddVisiableModel:model toSet:allModels];
    }
    
    // 2. check if need render shadow map
    CEShadowLight *shadowLight = nil;
    NSMutableSet *shadowModels = [NSMutableSet set];
    for (CELight *light in scene.allLights) {
        if ([light isKindOfClass:[CEShadowLight class]] &&
            [(CEShadowLight *)light enableShadow] &&
            [(CEShadowLight *)light isEnabled]) {
            shadowLight = (CEShadowLight *)light;
            break;
        }
    }
    for (CEModel *model in allModels) {
        if (model.castShadows) {
            [shadowModels addObject:model];
        }
    }
    if (shadowLight && shadowModels.count) { // try render shadow mapp if needed
        [self renderShadowMapsWithShadowLight:shadowLight shadowModels:shadowModels];
    }
    
    // 3 .sort render objects
    CEProgramConfig *baseConfig = [CEProgramConfig new];
    baseConfig.enableShadowMapping = (shadowLight && shadowModels.count);
    baseConfig.lightCount = (int)scene.allLights.count;
    NSMutableDictionary *sortedRenderObjectDict = [NSMutableDictionary dictionary];
    for (CEModel *model in allModels) {
        CEProgramConfig *modelConfig = baseConfig.copy;
        modelConfig.enableTexture = model.material.textureMap.length ? YES : NO;
        modelConfig.enableNormalMapping = model.material.normalMap.length ? YES : NO;
        NSMutableSet *modelsForConfig = sortedRenderObjectDict[modelConfig];
        if (!modelsForConfig) {
            modelsForConfig = [NSMutableSet set];
            sortedRenderObjectDict[modelConfig] = modelsForConfig;
        }
        [modelsForConfig addObject:model];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, scene.renderCore.defaultFramebuffer);
    glClearColor(scene.vec4BackgroundColor.r, scene.vec4BackgroundColor.g, scene.vec4BackgroundColor.b, scene.vec4BackgroundColor.a);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, scene.renderCore.width, scene.renderCore.height);
    [sortedRenderObjectDict enumerateKeysAndObjectsUsingBlock:^(CEProgramConfig *config, NSSet *models, BOOL *stop) {
        CEMainRenderer *render = [self rendererWithConfig:config];
        render.camera = scene.camera;
        render.lights = scene.allLights;
        render.shadowLight = shadowLight;
        [render renderObjects:models];
    }];
    
    // 4. render debug info
    if (scene.enableDebug) {
        [self renderDebugSceneWithObjects:allModels];
    }
    printf("render duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
}

/*
// return @{CEProgramConfig:@[CEModels]}
- (NSDictionary *)calculateRenderObjectsWithBaseConfig:(CEProgramConfig *)baseConfig {
    CEScene *scene = [CEScene currentScene];
    // calcualte all visiable model without empty groups
    NSMutableSet *allModels = [NSMutableSet set];
    for (CEModel *model in scene.allModels) {
        [self recursiveAddVisiableModel:model toSet:allModels];
    }
    // check shadowmap config
    CEProgramConfig *baseConfig = [CEProgramConfig new];
    baseConfig.lightCount = scene.allLights.count;
    BOOL enableModelShadow = NO;
    for (CEModel *model in allModels) {
        if (model.castShadows) {
            enableModelShadow = YES;
            break;
        }
    }
    if (enableModelShadow) {
        for (CELight *light in scene.allLights) {
            if (light.enableShadow) {
                baseConfig.shadowMappingCount += 1;
            }
        }
    }
    
    // sort models by different config
    NSMutableDictionary *configModelDict = [NSMutableDictionary dictionary];
    for (CEModel *model in allModels) {
        CEProgramConfig *modelConfig = baseConfig.copy;
        modelConfig.enableTexture = model.material.textureMap.length ? YES : NO;
        modelConfig.enableNormalMapping = model.material.normalMap.length ? YES : NO;
        NSMutableSet *modelsForConfig = configModelDict[modelConfig];
        if (!modelsForConfig) {
            modelsForConfig = [NSMutableSet set];
            configModelDict[modelConfig] = modelsForConfig;
        }
        [modelsForConfig addObject:model];
    }
    return [configModelDict copy];
}
//*/

- (void)recursiveAddVisiableModel:(CEModel *)model toSet:(NSMutableSet *)models {
    for (CEModel *child in model.childObjects) {
        [self recursiveAddVisiableModel:child toSet:models];
    }
    if (model.vertexBuffer) {
        [models addObject:model];
    }
}


- (CEMainRenderer *)rendererWithConfig:(CEProgramConfig *)config {
    CEMainRenderer *render = _rendererDict[config];
    if (!render) {
        render = [CEMainRenderer rendererWithConfig:config];
        _rendererDict[config] = render;
    }
#if DEBUG
    NSAssert(render, @"FAIL TO CREATE RENDER");
#endif
    return render;
}



#pragma mark - Test Renderer

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
    config.enableShadowMapping = YES;
    program = [CEMainProgram programWithConfig:config];
    printf("%.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
}


#pragma mark - Shadow Mapping

- (void)renderShadowMapsWithShadowLight:(CEShadowLight *)shadowLight shadowModels:(NSSet *)shadowModels {
    if (!shadowLight || !shadowModels.count) {
        // no need to render shadow maps
        return;
    }
    
    // check shadow map renderer
    if (!_shadowMapRenderer) {
        _shadowMapRenderer = [[CEShadowMapRenderer alloc] init];
    }
    
    // render shadow maps
    [shadowLight.shadowMapBuffer setupBuffer];
    [shadowLight.shadowMapBuffer prepareBuffer];
    [shadowLight updateLightVPMatrixWithModels:shadowModels];
    _shadowMapRenderer.lightVPMatrix = GLKMatrix4Multiply(shadowLight.lightProjectionMatrix, shadowLight.lightViewMatrix);
    [_shadowMapRenderer renderShadowMapWithObjects:shadowModels];
}



#pragma mark - Debug renderer
- (void)renderDebugSceneWithObjects:(NSSet *)objects {
    // render wireframe add assist info
    [[self wireframeRenderer] renderWireframeForObjects:objects];
    [[self assistRender] renderBoundsForObjects:objects];
    [[self assistRender] renderLights:[CEScene currentScene].allLights];
    [[self assistRender] renderWorldOriginCoordinate];
}


- (CEWireframeRenderer *)wireframeRenderer {
    if (!_wireframeRenderer) {
        _wireframeRenderer = [CEWireframeRenderer new];
        _wireframeRenderer.lineWidth = 1.0f;
    }
    _wireframeRenderer.camera = [CEScene currentScene].camera;
    return _wireframeRenderer;
}


- (CEAssistRenderer *)assistRender {
    if (!_assistRenderer) {
        _assistRenderer = [CEAssistRenderer new];
    }
    _assistRenderer.camera = [CEScene currentScene].camera;
    return _assistRenderer;
}




@end







