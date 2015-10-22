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

#import "CEMainRenderer.h"
#import "CEShadowMapRenderer.h"
#import "CETextureManager.h"

// new renderer
#import "CEDefaultRenderer.h"
#import "CERenderConfig.h"

// debug renderer
#import "CEWireframeRenderer.h"
#import "CEAssistRenderer.h"
#import "CETextureRenderer.h"

// test
#import "CEMainProgram.h"



@interface CERenderGroup : NSObject

@property (nonatomic, assign) uint32_t renderPriority;
@property (nonatomic, strong) CERenderConfig *renderConfig;
@property (nonatomic, strong) NSMutableArray *renderObjects;

@end

@implementation CERenderGroup

@end


@implementation CERenderManager {
    EAGLContext *_context;
    NSMutableDictionary *_rendererDict; // @{CEProgramConfig:CEMainRenderer}
    
    // special renderer
    CEShadowMapRenderer *_shadowMapRenderer DEPRECATED_ATTRIBUTE;
    CEWireframeRenderer *_wireframeRenderer;
    CEAssistRenderer *_assistRenderer;
}


- (instancetype)initWithContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        _rendererDict = [NSMutableDictionary dictionary];
    }
    
    return self;
}


- (void)renderCurrentScene {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CEScene *scene = [CEScene currentScene];
    [EAGLContext setCurrentContext:scene.context];

    // 2.check if need render shadow map
    
    // 3.sort render objects
    NSArray *renderGroups = [self sortRenderGroupsWithModels:scene.allModels];
    glBindFramebuffer(GL_FRAMEBUFFER, scene.renderCore.defaultFramebuffer);
    glClearColor(scene.vec4BackgroundColor.r, scene.vec4BackgroundColor.g, scene.vec4BackgroundColor.b, scene.vec4BackgroundColor.a);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, scene.renderCore.width, scene.renderCore.height);
    for (CERenderGroup *group in renderGroups) {
        CEDefaultRenderer *renderer = [self rendererWithConfig:group.renderConfig];
        if (!renderer) continue;
        
        renderer.camera = scene.camera;
        renderer.mainLight = scene.mainLight;
        // normally render a object
        [renderer renderObjects:group.renderObjects];
    }
    
    if (scene.enableDebug) {
        [self renderDebugSceneWithObjects:scene.allModels];
    }
    printf("render duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
}


/**
 sort models into render groups
 */
- (NSArray *)sortRenderGroupsWithModels:(NSArray *)models {
    // @{CERenderConfig : CERenderGroup}
    NSMutableDictionary *renderGroupDict = [NSMutableDictionary dictionary];
    CELightType lightType = [CEScene currentScene].mainLight ? [CEScene currentScene].mainLight.lightInfo.lightType : CELightTypeNone;
    
    for (CEModel *model in models) {
        for (CERenderObject *renderObject in model.renderObjects) {
            // load buffer
            if (!renderObject.vertexBuffer.isReady) {
                [renderObject.vertexBuffer setupBuffer];
            }
            if (!renderObject.indiceBuffer.isReady) {
                [renderObject.indiceBuffer setupBuffer];
            }
            if (!renderObject.vertexBuffer.isReady ||
                !renderObject.indiceBuffer.isReady) {
                CEPrintf("WARNING: Fail to load buffer for render object");
                continue;
            }
            renderObject.modelMatrix = model.transformMatrix;
            
            // setup config
            CERenderConfig *config = [CERenderConfig new];
            config.materialType = renderObject.material.materialType;
            config.enableTexture = renderObject.material.diffuseTextureID ? YES : NO;
            config.lightType = lightType;
            config.enableNormalMapping = renderObject.material.normalTextureID ? YES : NO;
            
            CERenderGroup *group = renderGroupDict[config];
            if (!group) {
                group = [CERenderGroup new];
                group.renderConfig = config;
                group.renderObjects = [NSMutableArray array];
                group.renderPriority = config.materialType;
                renderGroupDict[config] = group;
            }
            [(NSMutableArray *)group.renderObjects addObject:renderObject];
        }
    }
    
    NSArray *renderGroups = [renderGroupDict allValues];
    // sort groups by renderMode
    renderGroups = [renderGroups sortedArrayUsingComparator:^NSComparisonResult(CERenderGroup *group1, CERenderGroup *group2) {
        return group2.renderPriority - group1.renderPriority;
    }];
    
    return renderGroups.copy;
}


- (CEDefaultRenderer *)rendererWithConfig:(CERenderConfig *)config {
    CEDefaultRenderer *render = _rendererDict[config];
    if (!render) {
        render = [CEDefaultRenderer rendererWithConfig:config];
#if DEBUG
        NSAssert(render, @"FAIL TO CREATE RENDER");
#endif
        if (render) {
            _rendererDict[config] = render;
        }
    }

    return render;
}


#pragma mark - Test Renderer

- (void)testProgramGeneration {
    printf("testProgramGeneration... ");
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [EAGLContext setCurrentContext:_context];
    CEProgramConfig *config = [CEProgramConfig new];
    CEMainProgram *program = [CEMainProgram programWithConfig:config];
    config.lightCount = 1;
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

- (void)renderShadowMapsWithShadowLight:(CEShadowLight *)shadowLight
                           shadowModels:(NSArray *)shadowModels {
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
- (void)renderDebugSceneWithObjects:(NSArray *)objects {
    // render wireframe add assist info
    [[self wireframeRenderer] renderWireframeForModels:objects];
    [[self assistRender] renderBoundsForObjects:objects];
    [[self assistRender] renderWorldOriginCoordinate];
    if ([CEScene currentScene].mainLight) {
        [[self assistRender] renderLights:@[[CEScene currentScene].mainLight]];
    }
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







