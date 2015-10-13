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
    if (transparency < 0) {
        return;
    }
    _transparency = MIN(1.0, MAX(0.0, transparency));
    _materialType = _transparency >= 1.0 ? CEMaterialSolid : CEMaterialTransparent;
}


- (id)copyWithZone:(NSZone *)zone {
    CEMaterial *material = [[CEMaterial allocWithZone:zone] init];
    material.name = _name;
    material.materialType = _materialType;
    material.diffuseTexture = _diffuseTexture;
    material.normalTexture = _normalTexture;
    material.ambientColor = _ambientColor;
    material.diffuseColor = _diffuseColor;
    material.specularColor = _specularColor;
    material.shininessExponent = _shininessExponent;
    material.transparency = _transparency;
    
    return material;
}

@end
