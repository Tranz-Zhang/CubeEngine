//
//  CERenderManager.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"
#import "CECamera.h"

/**
 渲染器管理类，根据当前模型调用不同的渲染器进行渲染
 */
@interface CERenderManager : NSObject

@property (nonatomic, weak) CECamera *camera;

- (instancetype)initWithContext:(EAGLContext *)context;

- (void)renderModels:(NSArray *)models;

@end
