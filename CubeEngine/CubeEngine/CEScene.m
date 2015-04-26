//
//  CEScene.m
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEScene.h"
#import "CECamera_Rendering.h"
#import "CERenderManager.h"
#import "CEDebugRenderManager.h"

@interface CEScene () {
    EAGLContext *_context;
    CERenderManager *_renderManager;
    CEDebugRenderManager *_debugRenderManager;
    NSMutableArray *_renderObjects;
    NSMutableArray *_lights;
}

@end


@implementation CEScene

- (instancetype)init
{
    self = [super init];
    if (self) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _renderObjects = [NSMutableArray array];
        _lights = [NSMutableArray array];
        
        _camera = [[CECamera alloc] init];
        _camera.radianDegree = 65;
        _camera.aspect = 320.0 / 568.0;
        _camera.nearZ = 0.1;
        _camera.farZ = 100;
        _camera.position = GLKVector3Make(0, 0, 4);
        
        _renderManager = [[CERenderManager alloc] initWithContext:_context];
        _renderManager.camera = _camera;
        _debugRenderManager = [[CEDebugRenderManager alloc] initWithContext:_context];
        _debugRenderManager.camera = _camera;
    }
    return self;
}


#pragma mark - Setters & Getters
- (EAGLContext *)context {
    return _context;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = [backgroundColor copy];
        _renderManager.backgroundColor = backgroundColor;
    }
}

- (NSArray *)allRenderObjects {
    return [_renderObjects copy];
}

- (NSArray *)allLights {
    return _lights.copy;
}

#pragma mark - Model
- (void)addModel:(CEModel *)model {
    if ([model isKindOfClass:[CEModel class]]) {
        [_renderObjects addObject:model];
        
    } else {
        CEError(@"Can not add model to scene");
    }
}


- (void)removeModel:(CEModel *)model {
    [_renderObjects removeObject:model];
}


#pragma mark - Light
- (void)addLight:(CELight *)light {
    if (_lights.count < [CELight maxLightCount] &&
        [light isKindOfClass:[CELight class]] &&
        ![_lights containsObject:light]) {
        [_lights addObject:light];
        _renderManager.lights = _lights;
    }
}

- (void)removeLight:(CELight *)light {
    if ([light isKindOfClass:[CELight class]]) {
        [_lights removeObject:light];
        _renderManager.lights = _lights;
    }
}


- (void)update {
    [EAGLContext setCurrentContext:_context];
    [_renderManager renderModels:_renderObjects];
    
    [_debugRenderManager renderWireframeForModels:_renderObjects];
    [_debugRenderManager renderLights:_lights];
//    [_debugRenderManager renderWorldSpaceCoordinates];
}


@end
