//
//  CEBaseRenderer.h
//  CubeEngine
//
//  Created by chance on 4/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CEModel.h"
#import "CELight.h"

// render model without lighting
@interface CEBaseRenderer : CERenderer

@property (nonatomic, assign) NSInteger maxLightCount;
@property (nonatomic, strong) NSSet *lights;

@end
