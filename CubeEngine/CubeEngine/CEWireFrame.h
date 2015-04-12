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
@interface CEWireFrame : NSObject

@property (nonatomic, copy) UIColor *lineColor;
@property (nonatomic, assign) GLfloat lineWidth;
@property (nonatomic, assign) BOOL showCoordinateIndicator;

- (instancetype)initWithMesh:(CEMesh *)mesh;

@end
