//
//  CEShadowMapRenderer.h
//  CubeEngine
//
//  Created by chance on 10/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"

@interface CEShadowMapRenderer : CERenderer

@property (nonatomic, readonly) uint32_t shadowMapTextureID;

+ (instancetype)renderer;

@end

