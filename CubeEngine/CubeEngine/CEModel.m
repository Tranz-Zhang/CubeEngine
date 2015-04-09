//
//  CEModel.m
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEModel.h"

@implementation CEModel

- (instancetype)initWithMesh:(CEMesh *)mesh
{
    self = [super init];
    if (self) {
        _mesh = mesh;
    }
    return self;
}



@end
