//
//  CEShadowMapRenderer.h
//  CubeEngine
//
//  Created by chance on 5/11/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"

@interface CEShadowMapRenderer : CERenderer

@property (nonatomic, assign) GLKMatrix4 lightVPMatrix;

@end
