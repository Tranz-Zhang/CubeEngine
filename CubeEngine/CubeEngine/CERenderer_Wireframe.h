//
//  CEWireframeRenderer.h
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CEModel.h"

@interface CERenderer_Wireframe : CERenderer

@property (nonatomic, assign) GLfloat lineWidth;
@property (nonatomic, copy) UIColor *lineColor;

@end
