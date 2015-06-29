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
#import "CELightInfo.h"


@interface CELight () {
    @protected
    CEVertexBuffer *_vertexBuffer;
    CEIndicesBuffer *_indicesBuffer;
    CELightInfo *_lightInfo;
    BOOL _enabled;
}

// light visual model
+ (NSArray *)defaultVertexBufferAttributes;
@property (nonatomic, readonly) CEVertexBuffer *vertexBuffer;
@property (nonatomic, readonly) CEIndicesBuffer *indicesBuffer;

// light info
@property (nonatomic, readonly) CELightInfo *lightInfo;


@end


