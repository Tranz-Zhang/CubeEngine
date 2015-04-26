//
//  CEScene.h
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"
#import "CECamera.h"
#import "CELight.h"

/**
 representing a 3D scene, manage these things:
 - 3D Objects
 - Camera
 - Light
 */
@interface CEScene : NSObject

@property (nonatomic, readonly) NSArray *allRenderObjects;
@property (nonatomic, readonly) NSArray *allLights;
@property (nonatomic, readonly) CECamera *camera;
@property (nonatomic, readonly) EAGLContext *context;
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, assign) NSInteger maxLightCount;

@property (nonatomic, assign) BOOL displayOriginalPivot;

// Model
- (void)addModel:(CEModel *)model;
- (void)removeModel:(CEModel *)model;

// Light
- (void)addLight:(CELight *)light;
- (void)removeLight:(CELight *)light;

- (void)update;

@end

