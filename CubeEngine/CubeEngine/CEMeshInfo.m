//
//  CEMeshInfo.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMeshInfo.h"

@implementation CEMeshInfo

- (BOOL)isEqual:(CEMeshInfo *)other {
    if (other == self) {
        return YES;
    } else {
        return _meshID == other.meshID;;
    }
}


- (NSUInteger)hash {
    return _meshID;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MESH%X", _meshID];
}


@end
