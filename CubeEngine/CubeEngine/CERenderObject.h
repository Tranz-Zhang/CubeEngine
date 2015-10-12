//
//  CERenderObject.h
//  CubeEngine
//
//  Created by chance on 9/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEVertexBuffer.h"
#import "CEIndiceBuffer.h"
#import "CEMaterial.h"

/**
 CERenderObject includes all the information needed for rendering a mesh.
 */

@interface CERenderObject : NSObject

// mesh info
@property (nonatomic, strong) CEVertexBuffer *vertexBuffer;
@property (nonatomic, strong) CEIndiceBuffer *indexBuffer;

// material info
@property (nonatomic, strong) CEMaterial *material;

// model matrix
@property (nonatomic, assign) GLKMatrix4 modelMatrix;


@end
