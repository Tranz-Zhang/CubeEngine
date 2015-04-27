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

@interface CELight () {
    @protected
    CEVertexBuffer *_vertexBuffer;
    CEIndicesBuffer *_indicesBuffer;
    CELightUniformInfo *_uniformInfo;
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

@end


