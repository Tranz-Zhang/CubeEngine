//
//  CEVertexDataBuffer.h
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEVertexBuffer : NSObject

- (instancetype)initWithData:(NSData *)vertexData attributes:(NSArray *)attributes;

@property (nonatomic, readonly) NSArray *attributes;
@property (nonatomic, readonly) uint16_t attributesType;

- (BOOL)setupBuffer;
- (void)destoryBuffer;

- (BOOL)loadBuffer;
- (void)unloadBuffer;

@end
