//
//  CEDefaultRenderer.h
//  CubeEngine
//
//  Created by chance on 9/13/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CECamera.h"
#import "CELight.h"
#import "CERenderConfig.h"

@interface CEDefaultRenderer : CERenderer

@property (nonatomic, assign) uint32_t shadowMapTextureID;

+ (instancetype)rendererWithConfig:(CERenderConfig *)config;

@end


