//
//  CEVertexBufferAttributeInfo.m
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEVertexBufferAttributeInfo.h"

@implementation CEVertexBufferAttributeInfo

- (GLsizei)attibuteSize {
    return _elementCount * _elementSize;
}

@end
