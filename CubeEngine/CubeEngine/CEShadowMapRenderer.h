//
//  CEShadowMapRenderer.h
//  CubeEngine
//
//  Created by chance on 10/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEShadowLight.h"

@interface CEShadowMapRenderer : NSObject

@property (nonatomic, readonly) BOOL isReady;
@property (nonatomic, readonly) uint32_t shadowMapTextureID;

// models: array of CEModels
- (BOOL)renderShadowMapWithModels:(NSArray *)shadowModels
                      shadowLight:(CEShadowLight *)shadowLight;

@end

