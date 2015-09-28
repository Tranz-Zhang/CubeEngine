//
//  OBJFileInfo.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "OBJFileInfo.h"

@implementation OBJFileInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _vertexDataList = [[VectorList alloc] initWithVectorType:VectorType3];
        _positionList = [[VectorList alloc] initWithVectorType:VectorType3];
        _uvList = [[VectorList alloc] initWithVectorType:VectorType2];
        _normalList = [[VectorList alloc] initWithVectorType:VectorType3];
        _tangentList = [[VectorList alloc] initWithVectorType:VectorType3];
    }
    return self;
}

@end
