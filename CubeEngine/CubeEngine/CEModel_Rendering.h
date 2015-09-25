//
//  CEModel_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "CEModel.h"
#import "CEVertexBuffer_DEPRECATED.h"
#import "CEIndicesBuffer_DEPRECATED.h"

@interface CEModel ()

@property (nonatomic, readonly) CEVertexBuffer_DEPRECATED *vertexBuffer;
@property (nonatomic, readonly) CEIndicesBuffer_DEPRECATED *indicesBuffer;
@property (nonatomic, readonly) CEIndicesBuffer_DEPRECATED *wireframeBuffer;

// textures
@property (nonatomic, strong) GLKTextureInfo *texture;
@property (nonatomic, strong) GLKTextureInfo *normalMap;


// initialization
- (instancetype)initWithVertexBuffer:(CEVertexBuffer_DEPRECATED *)vertexBuffer
                       indicesBuffer:(CEIndicesBuffer_DEPRECATED *)indicesBuffer;

@end
