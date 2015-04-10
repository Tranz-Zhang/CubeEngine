//
//  CEMeshWireFrame.h
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEMesh.h"

// presenting the wireframe of a given mesh
@interface CEMeshWireFrame : NSObject

@property (nonatomic, copy) UIColor *wireFrameColor;
@property (nonatomic, assign) BOOL showCoordinateIndicator;
@property (nonatomic, readonly) NSData *vertexData;
@property (nonatomic, assign) GLint vertexBufferIndex;

+ (CEMeshWireFrame *)wireFrameWithMesh:(CEMesh *)mesh;


@end
