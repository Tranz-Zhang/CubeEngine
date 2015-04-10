//
//  GLCoordinateDrawer.h
//  CubeEngine
//
//  Created by chance on 15/3/16.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"

@interface CECoordinateRenderer : NSObject

@property (nonatomic, assign) BOOL showWorldCoordinate;
@property (nonatomic, assign) GLKMatrix4 cameraProjectionMatrix;

- (instancetype)initWithContext:(EAGLContext *)context;

- (void)addModel:(CEModel* )model;
- (void)removeModel:(CEModel *)model;

- (void)render;

@end


