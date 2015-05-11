//
//  CELight_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"
#import "CECamera_Rendering.h"
#import "CEVertexBuffer.h"
#import "CEIndicesBuffer.h"
#import "CELightUniformInfo.h"
#import "CEShadowMapBuffer.h"
#import "CEModel.h"


@interface CELight () {
    @protected
    CEVertexBuffer *_vertexBuffer;
    CEIndicesBuffer *_indicesBuffer;
    CELightUniformInfo *_uniformInfo;
    BOOL _enabled;
    BOOL _hasLightChanged;
}

// light visual model
+ (NSArray *)defaultVertexBufferAttributes;
@property (nonatomic, readonly) CEVertexBuffer *vertexBuffer;
@property (nonatomic, readonly) CEIndicesBuffer *indicesBuffer;

// Light info
@property (nonatomic, strong) CELightUniformInfo *uniformInfo;

// Indicates if light attributes have changed since last time
@property (nonatomic, assign) BOOL hasLightChanged;

// must overwrite by subclass
- (void)updateUniformsWithCamera:(CECamera *)camera;


#pragma mark - ShadowMapping
@property (nonatomic, readonly) CEShadowMapBuffer *shadowMapBuffer;
// light view matrix, mainly used for shadow mapping
@property (nonatomic, readonly) GLKMatrix4 lightViewMatrix;
@property (nonatomic, readonly) GLKMatrix4 lightProjectionMatrix;

// update view matrix and projection matrix. Should be overwited by subclass
- (void)updateLightVPMatrixWithModels:(NSSet *)models;

@end


