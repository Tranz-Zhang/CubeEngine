//
//  CEMaterialInfo.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMaterialInfo.h"

@implementation CEMaterialInfo

- (BOOL)isEqual:(CEMaterialInfo *)other {
    if (other == self) {
        return YES;
    } else {
        return _materialID == other.materialID;
    }
}

- (NSUInteger)hash {
    return _materialID;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"MTL%08X", _materialID];
}


@end
