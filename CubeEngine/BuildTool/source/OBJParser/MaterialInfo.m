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

@end
