//
//  CEBaseRender.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"

// 渲染器父类，定义基本的渲染器接口

@interface CERenderer : NSObject

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLKMatrix4 viewMatrix;
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;


- (BOOL)setupRenderer;
- (void)renderObject:(CEModel *)model;

@end
