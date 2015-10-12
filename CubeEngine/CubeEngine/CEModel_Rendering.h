//
//  CEModel_Rendering.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "CEModel.h"
#import "CERenderObject.h"
#import "CEVertexBuffer_DEPRECATED.h"
#import "CEIndicesBuffer_DEPRECATED.h"


@interface CEModel ()

@property (nonatomic, readonly) CEVertexBuffer_DEPRECATED *vertexBuffer DEPRECATED_ATTRIBUTE;
@property (nonatomic, readonly) CEIndicesBuffer_DEPRECATED *indicesBuffer DEPRECATED_ATTRIBUTE;
@property (nonatomic, readonly) CEIndicesBuffer_DEPRECATED *wireframeBuffer DEPRECATED_ATTRIBUTE;

// textures
@property (nonatomic, strong) GLKTextureInfo *texture DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) GLKTextureInfo *normalMap DEPRECATED_ATTRIBUTE;


// initialization
- (instancetype)initWithVertexBuffer:(CEVertexBuffer_DEPRECATED *)vertexBuffer
                       indicesBuffer:(CEIndicesBuffer_DEPRECATED *)indicesBuffer DEPRECATED_ATTRIBUTE;


#pragma mark - New render API
- (instancetype)initWithRenderObjects:(NSArray *)renderObjects;

@property (nonatomic, readwrite) GLKVector3 bounds;
@property (nonatomic, readwrite) GLKVector3 offsetFromOrigin;
@property (nonatomic, readonly) NSArray *renderObjects;

@end
