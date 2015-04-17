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

@interface CEScene () {
    EAGLContext *_context;
    CERenderManager *_renderManager;
    NSMutableArray *_renderObjects;
}

@end


@implementation CEScene

- (instancetype)init
{
    self = [super init];
    if (self) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        _camera = [[CECamera alloc] init];
        _camera.radianDegree = 65;
        _camera.aspect = 320.0 / 568.0;
        _camera.nearZ = 0.1;
        _camera.farZ = 100;
        _camera.position = GLKVector3Make(0, 0, 4);
        
        _renderManager = [[CERenderManager alloc] initWithContext:_context];
        _renderManager.camera = _camera;
        _renderObjects = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Setters & Getters
- (EAGLContext *)context {
    return _context;
}


#pragma mark -
- (void)addModel:(CEModel *)model {
    if ([model isKindOfClass:[CEModel class]]) {
        [_renderObjects addObject:model];
        
    } else {
        CEError(@"Can not add model to scene");
    }
}


- (void)removeModel:(CEModel *)model {
    if (model) {
        [_renderObjects removeObject:model];
    }
}


- (void)update {
    [EAGLContext setCurrentContext:_context];
    [_renderManager renderModels:_renderObjects];
}


@end
