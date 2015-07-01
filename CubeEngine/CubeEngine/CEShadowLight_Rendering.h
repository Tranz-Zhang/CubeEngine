//
//  CEShadowLight_Rendering.h
//  CubeEngine
//
//  Created by chance on 6/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowLight.h"
#import "CEShadowMapBuffer.h"
#import "CEModel.h"

#define kDefaultTextureSize 512

@interface CEShadowLight ()

#pragma mark - ShadowMapping
@property (nonatomic, readonly) CEShadowMapBuffer *shadowMapBuffer;
// light view matrix, mainly used for shadow mapping
@property (nonatomic, readonly) GLKMatrix4 lightViewMatrix;
@property (nonatomic, readonly) GLKMatrix4 lightProjectionMatrix;

// update view matrix and projection matrix. Should be overwited by subclass
- (void)updateLightVPMatrixWithModels:(NSArray *)models;

@end
