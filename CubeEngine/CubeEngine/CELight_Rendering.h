//
//  CELight_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"
#import "CEVertexBuffer.h"
#import "CEIndicesBuffer.h"
#import "CELightUniformInfo.h"

@interface CELight () {
    @protected
    CEVertexBuffer *_vertexBuffer;
    CEIndicesBuffer *_indicesBuffer;
    CELightUniformInfo *_uniformInfo;
    BOOL _hasLightChanged;
}

// light visual model
@property (nonatomic, readonly) CEVertexBuffer *vertexBuffer;
@property (nonatomic, readonly) CEIndicesBuffer *indicesBuffer;

// Light info
@property (nonatomic, strong) CELightUniformInfo *uniformInfo;

/** 
 indicates if the render should calculate the half vector bewteen eye direction
 and light direction
 Default is NO.
 */
@property (nonatomic, readonly) BOOL needCalculateHalfVector;


// Indicates if light attributes have changed since last time
@property (nonatomic, assign) BOOL hasLightChanged;

// must overwrite by subclass
- (void)updateUniforms;

@end


