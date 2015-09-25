//
//  CELight_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"
#import "CEVertexBuffer_DEPRECATED.h"
#import "CEIndicesBuffer_DEPRECATED.h"
#import "CELightInfo.h"


@interface CELight () {
    @protected
    CEVertexBuffer_DEPRECATED *_vertexBuffer;
    CEIndicesBuffer_DEPRECATED *_indicesBuffer;
    CELightInfo *_lightInfo;
    BOOL _enabled;
}

// light visual model
+ (NSArray *)defaultVertexBufferAttributes;
@property (nonatomic, readonly) CEVertexBuffer_DEPRECATED *vertexBuffer;
@property (nonatomic, readonly) CEIndicesBuffer_DEPRECATED *indicesBuffer;

// light info
@property (nonatomic, readonly) CELightInfo *lightInfo;


@end


