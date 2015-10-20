//
//  MaterialInfo.m
//  CubeEngine
//
//  Created by chance on 9/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "MaterialInfo.h"

@implementation MaterialInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _transparency = 1;
        _materialType = CEMaterialSolid;
    }
    return self;
}

- (void)setName:(NSString *)name {
    if (![_name isEqualToString:name]) {
        _name = name;
        _resourceID = HashValueWithString(name);
    }
}

- (BOOL)isEqual:(MaterialInfo *)other {
    if (other == self) {
        return YES;
    } else {
        return _resourceID && _resourceID == other.resourceID;
    }
}


- (NSUInteger)hash {
    return _resourceID;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"MTL[%08X]-%@:\ntype:%d\ndiffuse:%@\nnormal:%@\nspecular:%@\nambientColor:(%.2f, %.2f, %.2f)\ndiffuseColor:(%.2f, %.2f, %.2f)\nspecularColor:(%.2f, %.2f, %.2f)\nshininess:%.2f\ntransparency:%.2f", _resourceID, _name,  _materialType, _diffuseTexture, _normalTexture, _specularTexture, _ambientColor.r, _ambientColor.g, _ambientColor.b, _diffuseColor.r, _diffuseColor.g, _diffuseColor.b, _specularColor.r, _specularColor.g, _specularColor.b, _shininessExponent, _transparency];
}

@end

