//
//  CERenderManager.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 渲染器管理类，根据当前模型调用不同的渲染器进行渲染
 */
@interface CERenderManager : NSObject

- (instancetype)initWithContext:(EAGLContext *)context;

- (void)renderCurrentScene;

@end

/**
 !!!: Important Note for CERenderManager
 - response for shadowmap rendering, because it known all the models which enable shadowmap
 - extract all models from CEModel hierarchy, sort them and use different renderer to render objects
 
 */
