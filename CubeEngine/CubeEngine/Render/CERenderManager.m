//
//  CERenderManager.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderManager.h"

#import "CETextureManager.h"

// rendering methods
#import "CEScene_Rendering.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"
#import "CELight_Rendering.h"
#import "CEShadowLight_Rendering.h"

// main renderer
#import "CEDefaultRenderer.h"
#import "CEAlphaTestRenderer.h"
#import "CETransparentRenderer.h"
#import "CEShadowMapRenderer.h"
#import "CERenderConfig.h"

// debug renderer
#import "CEWireframeRenderer.h"
#import "CEAssistRenderer.h"

// test



@interface CERenderGroup : NSObject

@property (nonatomic, assign) uint32_t renderPriority;
@property (nonatomic, strong) CERenderConfig *renderConfig;
@property (nonatomic, strong) NSMutableArray *renderObjects;

@end

@implementation CERenderGroup

@end


@implementation CERenderManager {
    EAGLContext *_context;
    NSMutableDictionary *_rendererDict; // @{@(CERenderConfig.hash) : CEMainRenderer}
    
    // shadow map renderer
    BOOL _enableShadowMapping;
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
    }
    
    return self;
}


- (void)renderCurrentScene {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CEScene *scene = [CEScene currentScene];
    [EAGLContext setCurrentContext:scene.context];
    
    // 1. prepare render objects
    for (CEModel *model in scene.allModels) {
        for (CERenderObject *renderObject in model.renderObjects) {
            // load buffer
            if (!renderObject.vertexBuffer.isReady) {
                [renderObject.vertexBuffer setupBuffer];
            }
            if (!renderObject.indiceBuffer.isReady) {
                [renderObject.indiceBuffer setupBuffer];
            }
            renderObject.modelMatrix = model.transformMatrix;
        }
    }
    
    // 2.check if need render shadow map
    _enableShadowMapping = [self renderShadowMapForScene:scene];
    
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
        renderer.mainLight = group.renderConfig.lightType != CELightTypeNone ? scene.mainLight : nil;
        if (_enableShadowMapping) {
            renderer.shadowMapTextureID = _shadowMapRenderer.shadowMapTextureID;
        }
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
            if (!renderObject.vertexBuffer.isReady ||
                !renderObject.indiceBuffer.isReady) {
                CEPrintf("WARNING: Fail to load buffer for render object");
                continue;
            }
            
            // setup config
            CERenderConfig *config = [CERenderConfig new];
            config.materialType = renderObject.material.materialType;
            config.enableTexture = renderObject.material.diffuseTextureID ? YES : NO;
            if (lightType != CELightTypeNone &&
                [renderObject.vertexBuffer.attributes containsObject:@(CEVBOAttributeNormal)]) {
                config.lightType = lightType;
            } else {
                config.lightType = CELightTypeNone;
            }
            config.enableNormalMapping = renderObject.material.normalTextureID ? YES : NO;
            config.enableShadowMapping = _enableShadowMapping;
            
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
        if (group1.renderPriority < group2.renderPriority) {
            return NSOrderedAscending;
        } else if (group1.renderPriority > group2.renderPriority) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return renderGroups.copy;
}


- (CEDefaultRenderer *)rendererWithConfig:(CERenderConfig *)config {
    CEDefaultRenderer *render = _rendererDict[@(config.hash)];
    if (!render) {
        switch (config.materialType) {
            case CEMaterialSolid:
                render = [CEDefaultRenderer rendererWithConfig:config];
                break;
                
            case CEMaterialTransparent:
                render = [CETransparentRenderer rendererWithConfig:config];
                break;
                
            case CEMaterialAlphaTested:
                render = [CEAlphaTestRenderer rendererWithConfig:config];
                break;
                
            default:
                break;
        }
        
#if DEBUG
        NSAssert(render, @"FAIL TO CREATE RENDER");
#endif
        if (render) {
            _rendererDict[@(config.hash)] = render;
        }
    }

    return render;
}


#pragma mark - Shadow Mapping

// check if should render shadow for current scene
- (BOOL)renderShadowMapForScene:(CEScene *)scene {
    if (![scene.mainLight isKindOfClass:[CEShadowLight class]]) {
        return NO;
    }
    CEShadowLight *shadowLight = (CEShadowLight *)scene.mainLight;
    if (!shadowLight.enableShadow) {
        return NO;
    }
    // get models which cast shadow
    NSMutableArray *shadowModels = [NSMutableArray array];
    NSMutableArray *renderObjects = [NSMutableArray array];
    for (CEModel *model in scene.allModels) {
        if (model.enableShadow) {
            [shadowModels addObject:model];
            [renderObjects addObjectsFromArray:model.renderObjects];
        }
    }
    if (!shadowModels.count || !renderObjects.count) return NO;
    // get shadow map renderer
    if (!_shadowMapRenderer) {
        _shadowMapRenderer = [CEShadowMapRenderer renderer];
        _shadowMapRenderer.camera = scene.camera;
    }
    // update light view matrix
    [shadowLight updateLightVPMatrixWithModels:shadowModels];
    _shadowMapRenderer.mainLight = shadowLight;
    
    BOOL isOK = [_shadowMapRenderer renderObjects:renderObjects];
    return isOK;
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







