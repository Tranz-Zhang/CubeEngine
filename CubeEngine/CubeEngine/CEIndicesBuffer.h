//
//  CEIndicesBuffer.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEVertexBuffer.h"

@interface CEIndicesBuffer : CEVertexBuffer

- (instancetype)initWithIndicesData:(NSData *)indicesData count:(NSInteger)indexCount;

@end
