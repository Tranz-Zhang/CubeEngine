//
//  CEModel_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "CEModel.h"
#import "CEVertexBuffer.h"
#import "CEIndicesBuffer.h"

@interface CEModel ()

@property (nonatomic, readonly) CEVertexBuffer *vertexBuffer;
@property (nonatomic, readonly) CEIndicesBuffer *indicesBuffer;
@property (nonatomic, readonly) CEIndicesBuffer *wireframeBuffer;

// textures
@property (nonatomic, strong) GLKTextureInfo *texture;
@property (nonatomic, strong) GLKTextureInfo *normalMap;


// initialization
- (instancetype)initWithVertexBuffer:(CEVertexBuffer *)vertexBuffer
                       indicesBuffer:(CEIndicesBuffer *)indicesBuffer;

@end
