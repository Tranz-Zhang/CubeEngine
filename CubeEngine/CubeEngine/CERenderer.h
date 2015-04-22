//
//  CEBaseRender.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"
#import "CECamera.h"

// 渲染器父类，定义基本的渲染器接口

@interface CERenderer : NSObject {
    EAGLContext *_context;
    __weak CECamera *_camera;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, weak) CECamera *camera;


- (BOOL)setupRenderer;
- (void)renderObject:(CEModel *)model;

@end
