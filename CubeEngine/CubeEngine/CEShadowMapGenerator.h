//
//  CEShadowMapGenerator.h
//  CubeEngine
//
//  Created by chance on 5/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CELight.h"
#import "CECamera.h"

@interface CEShadowMapGenerator : NSObject

@property (nonatomic, readonly) GLuint depthTexture;
@property (nonatomic, readonly) CGSize textureSize;
@property (nonatomic, readonly) CELight *light;
@property (nonatomic, readonly) GLKMatrix4 depthMVP;

- (instancetype)initWithLight:(CELight *)light textureSize:(CGSize)size inContext:(EAGLContext *)context;

- (BOOL)generateShadowMapWithModels:(NSSet *)models
                             camera:(CECamera *)camera
                          inContext:(EAGLContext *)context;

@end
