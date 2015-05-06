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
 CEScene is like a container for rendering metarials, including:
 - 3D Objects
 - Camera
 - Light
 
 Note: It is designed to be thread safe.
 */
@interface CEScene : NSObject

@property (nonatomic, readonly) NSSet *allModels;
@property (nonatomic, readonly) NSSet *allLights;
@property (nonatomic, readonly) NSInteger maxLightCount;
@property (nonatomic, readonly) CECamera *camera;
@property (nonatomic, copy) UIColor *backgroundColor;

// Model
- (void)addModel:(CEModel *)model;
- (void)removeModel:(CEModel *)model;
- (void)addModels:(NSArray *)models;
- (void)removeModels:(NSArray *)models;


// Light
- (void)addLight:(CELight *)light;
- (void)removeLight:(CELight *)light;


@end

