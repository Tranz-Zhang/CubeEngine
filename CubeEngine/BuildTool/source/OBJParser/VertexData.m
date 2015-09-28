//
//  VertexData.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "VertexData.h"

@implementation VertexData

- (void)setNormal:(GLKVector3)normal {
    _normal = normal;
    if (normal.x == 0 && normal.y == 0) {
        printf("");
    }
}

@end
