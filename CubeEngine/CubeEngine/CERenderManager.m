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

@property (nonatomic, strong) CERenderConfig *renderConfig;
@property (nonatomic, strong) NSArray *renderObjects;

@end

@implementation CERenderGroup

@end


@implementation CERenderManager {
    EAGLContext *_context;
    NSMutableDictionary *_rendererDict; // @{CEProgramConfig:CEMainRenderer}
    BOOL _enableBlending;
    
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
    }
    
    return self;
}


- (void)renderCurrentScene {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CEScene *scene = [CEScene currentScene];
    [EAGLContext setCurrentContext:scene.context];
    
    // 1. get all visiable objects(without empty group)
    NSMutableArray *allModels = [NSMutableArray array];
    for (CEModel *model in scene.allModels) {
        [self recursiveAddVisiableModel:model toList:allModels];
    }
    
    // 2. check if need render shadow map
    CEShadowLight *shadowLight = nil;
    NSMutableArray *shadowModels = [NSMutableArray array];
    if ([scene.mainLight isKindOfClass:[CEShadowLight class]] &&
        [(CEShadowLight *)scene.mainLight enableShadow] &&
        [(CEShadowLight *)scene.mainLight isEnabled]) {
        shadowLight = (CEShadowLight *)scene.mainLight;
    }
    for (CEModel *model in allModels) {
        if (model.castShadows) {
            [shadowModels addObject:model];
        }
    }
    if (shadowLight && shadowModels.count) {
        // try render shadow mapp if needed
        [self renderShadowMapsWithShadowLight:shadowLight
                                 shadowModels:shadowModels];
    }
    
    // 3. load texture for models
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadTextureForModels:allModels];
    });
    

    // 4 .sort render objects
    CERenderConfig *baseConfig = [CERenderConfig new];
    baseConfig.enableShadowMapping = (shadowLight && shadowModels.count);
    baseConfig.lightType = scene.mainLight ? scene.mainLight.lightInfo.lightType : CELightTypeNone;
    NSArray *renderGroups = [self renderGroupsWithObjects:allModels withBaseConfig:baseConfig];
    
    // 5. render models
    glBindFramebuffer(GL_FRAMEBUFFER, scene.renderCore.defaultFramebuffer);
    glClearColor(scene.vec4BackgroundColor.r, scene.vec4BackgroundColor.g, scene.vec4BackgroundColor.b, scene.vec4BackgroundColor.a);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, scene.renderCore.width, scene.renderCore.height);
    for (CERenderGroup *group in renderGroups) {
        CEDefaultRenderer *renderer = [self rendererWithConfig:group.renderConfig];
        renderer.camera = scene.camera;
        renderer.mainLight = scene.mainLight;
        // normally render a object
        [renderer renderObjects:group.renderObjects];
        /*
        if (group.renderConfig.renderMode == CERenderModeTransparent) {
            // render transparent object with double sided and blend on
            glEnable(GL_BLEND);
            glEnable(GL_CULL_FACE);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glCullFace(GL_FRONT);
            [renderer renderObjects:group.renderObjects];
            glCullFace(GL_BACK);
            [renderer renderObjects:group.renderObjects];
            glDisable(GL_CULL_FACE);
            glDisable(GL_BLEND);
            
        } else {
            // normally render a object
            [renderer renderObjects:group.renderObjects];
        }
         //*/
    }
    
    // 6. render debug info
    if (scene.enableDebug) {
        [self renderDebugSceneWithObjects:allModels];
    }
    printf("render duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
}

/**
 sort models into render groups
 */
- (NSArray *)renderGroupsWithObjects:(NSArray *)models withBaseConfig:(CERenderConfig *)baseConfig {
    // @{CERenderConfig : CERenderGroup}
    NSMutableDictionary *sortedRenderObjectDict = [NSMutableDictionary dictionary];
    for (CEModel *model in models) {
        CERenderConfig *modelConfig = baseConfig.copy;
        modelConfig.renderType = (int)model.material.materialType;
        modelConfig.enableTexture = model.texture ? YES : NO;
        modelConfig.enableNormalMapping = model.normalMap ? YES : NO;
        CERenderGroup *group = sortedRenderObjectDict[modelConfig];
        if (!group) {
            group = [CERenderGroup new];
            group.renderConfig = modelConfig;
            group.renderObjects = [NSMutableArray array];
            sortedRenderObjectDict[modelConfig] = group;
        }
        [(NSMutableArray *)group.renderObjects addObject:model];
    }
    
    NSArray *renderGroups = [sortedRenderObjectDict allValues];
    // sort groups by renderMode
    renderGroups = [renderGroups sortedArrayUsingComparator:^NSComparisonResult(CERenderGroup *group1, CERenderGroup *group2) {
        return group1.renderConfig.renderType - group2.renderConfig.renderType;
    }];
//    // sort objects by distance to camera
//    CECamera *camera = [CEScene currentScene].camera;
//    for (CERenderGroup *group in renderGroups) {
//        BOOL isAccending = group.renderConfig.renderMode == CERenderModeTransparent ? NO : YES;
//        group.renderObjects = [group.renderObjects sortedArrayUsingComparator:^NSComparisonResult(CEModel *model1, CEModel *model2) {
//            float distance1 = GLKVector3Distance([model1 positionInWorldSpace],
//                                                 [camera positionInWorldSpace]);
//            float distance2 = GLKVector3Distance([model2 positionInWorldSpace],
//                                                 [camera positionInWorldSpace]);
//            return isAccending ? distance1 - distance2 : distance2 - distance1;
//        }];
//    }
    
    return renderGroups.copy;
}


- (void)recursiveAddVisiableModel:(CEModel *)model toList:(NSMutableArray *)models {
    for (CEModel *child in model.childObjects) {
        [self recursiveAddVisiableModel:child toList:models];
    }
    if (model.vertexBuffer) {
        [models addObject:model];
    }
}


- (CEDefaultRenderer *)rendererWithConfig:(CERenderConfig *)config {
    CEDefaultRenderer *render = _rendererDict[config];
    if (!render) {
        render = [CEDefaultRenderer rendererWithConfig:config];
        _rendererDict[config] = render;
    }
#if DEBUG
    NSAssert(render, @"FAIL TO CREATE RENDER");
#endif
    return render;
}


- (void)loadTextureForModels:(NSArray *)models {
    for (CEModel *model in models) {
        // load diffuse texture
        if (model.material.diffuseTexture && !model.texture) {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:model.material.diffuseTexture];
            NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @YES};
            NSError *error;
            GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
            if (error) {
                CEWarning(@"Fail to load texture: %@", error);
                
            } else {
                model.texture = texture;
                CEPrintf("load texture OK duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
            }
        }
        
        // load normal map texture
        if (model.material.normalTexture && !model.normalMap) {
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:model.material.normalTexture];
            NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @YES};
            NSError *error;
            GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
            if (error) {
                CEWarning(@"Fail to load normal map texture: %@", error);
                
            } else {
                model.normalMap = texture;
                CEPrintf("load normal map texture OK duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
            }
        }
    }
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
    [[self wireframeRenderer] renderWireframeForObjects:objects];
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







