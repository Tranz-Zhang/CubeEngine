//
//  CEVertexDataBuffer.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEVertexBuffer.h"
#import "CEVBOAttribute.h"

@implementation CEVertexBuffer {
    GLuint _bufferIndex;
    BOOL _ready;
    NSData *_vertexData;
}


- (instancetype)initWithData:(NSData *)vertexData attributes:(NSArray *)attributes {
    self = [super init];
    if (self) {
        _vertexData = vertexData;
        _attributes = [attributes copy];
        _attributesType = [CEVBOAttribute attributesTypeWithNames:attributes];
    }
    return self;
}


- (BOOL)setupBuffer {
    if (_ready) return YES;
    if (!_vertexData.length || _attributes.count) {
        return NO;
    }
    
    _ready = YES;
    return YES;
}


- (void)destoryBuffer {
    
}


- (BOOL)loadBuffer {
    if (!_ready) return NO;
    
    
    
    return YES;
}


- (void)unloadBuffer {
    
}


@end
