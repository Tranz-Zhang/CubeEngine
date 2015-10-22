//
//  CEWireframeRenderer.h
//  CubeEngine
//
//  Created by chance on 4/10/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEModel.h"
#import "CECamera.h"

@interface CEWireframeRenderer : NSObject

@property (nonatomic, weak) CECamera *camera;
@property (nonatomic, assign) GLfloat lineWidth;
@property (nonatomic, copy) UIColor *lineColor;

- (void)renderWireframeForModels:(NSArray *)objects;

@end
