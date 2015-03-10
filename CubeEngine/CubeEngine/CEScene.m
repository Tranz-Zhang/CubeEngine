//
//  CEScene.m
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEScene.h"
#import "CECamera_Rendering.h"
#import "CERenderer.h"

@interface CEScene () {
    CERenderer *_renderer;
    NSMutableArray *_renderObjects;
}

@end

@implementation CEScene

- (instancetype)init
{
    self = [super init];
    if (self) {
        _renderObjects = [NSMutableArray array];
        
        _camera = [[CECamera alloc] init];
        _camera.radianDegree = 65;
        _camera.aspect = 320.0 / 568.0;
        _camera.nearZ = 0.1;
        _camera.farZ = 100;
        _camera.location = GLKVector3Make(0, 0, 4);
        
        _renderer = [CERenderer new];
        _renderer.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Setters & Getters
- (EAGLContext *)context {
    return _renderer.context;
}

#pragma mark -
- (void)addRenderObject:(CEModel *)renderObject {
    if (renderObject) {
        [_renderObjects addObject:renderObject];
    }
}

- (void)removeRenderObject:(CEModel *)renderObject {
    if (renderObject) {
        [_renderObjects removeObject:renderObject];
    }
}


- (void)update {
    _renderer.cameraProjectionMatrix = _camera.projectionMatrix;
    [_renderer renderObject:_renderObjects.lastObject];
}


@end
