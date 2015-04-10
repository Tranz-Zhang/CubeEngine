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

/**
 representing a 3D scene, manage these things:
 - 3D Objects
 - Camera
 - Light
 */
@interface CEScene : NSObject

@property (atomic, readonly) NSArray *allRenderObjects;
@property (nonatomic, readonly) CECamera *camera;
@property (nonatomic, readonly) EAGLContext *context;

@property (nonatomic, assign) BOOL displayOriginalPivot;


- (void)addModel:(CEModel *)model;
- (void)removeModel:(CEModel *)model;

- (void)update;

@end

