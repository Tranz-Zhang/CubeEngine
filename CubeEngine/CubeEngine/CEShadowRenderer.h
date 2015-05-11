//
//  CEShadowRenderer.h
//  CubeEngine
//
//  Created by chance on 4/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"
#import "CEModel.h"
#import "CELight.h"


@interface CEShadowRenderer : CERenderer

@property (nonatomic, strong) NSSet *lights;

@end
