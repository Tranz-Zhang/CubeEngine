//
//  GLCoordinateDrawer.h
//  CubeEngine
//
//  Created by chance on 15/3/16.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel_Deprecated.h"

@interface CECoordinateRenderer : NSObject

@property (nonatomic, assign) BOOL showWorldCoordinate;
@property (nonatomic, assign) GLKMatrix4 cameraProjectionMatrix;

- (instancetype)initWithContext:(EAGLContext *)context;

- (void)addModel:(CEModel_Deprecated* )model;
- (void)removeModel:(CEModel_Deprecated *)model;

- (void)render;

@end


