//
//  CEMeterial.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMaterial.h"

@implementation CEMaterial

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTransparency:1];
    }
    return self;
}

- (void)setTransparency:(float)transparency {
    _transparency = MIN(1.0, MAX(0.0, transparency));
    _materialType = _transparency >= 1.0 ? CEMaterialSolid : CEMaterialTransparent;
}

@end
