//
//  CEIndiceBuffer.m
//  CubeEngine
//
//  Created by chance on 9/25/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEIndiceBuffer.h"

@implementation CEIndiceBuffer {
    NSData *_indiceData;
    GLuint _indiceBufferId;
}

- (instancetype)initWithData:(NSData *)indiceData
                 primaryType:(GLenum)primaryType
                    drawMode:(GLenum)drawMode {
    self = [super init];
    if (self) {
        _indiceData = indiceData;
        _primaryType = primaryType;
        _drawMode = drawMode;
    }
    return self;
}

- (void)dealloc {
    [self destoryBuffer];
    _indiceData = nil;
}


- (BOOL)setupBuffer {
    if (_ready) return YES;
    if (!_indiceData.length ||
        _primaryType != GL_UNSIGNED_SHORT ||
        _primaryType != GL_UNSIGNED_BYTE) {
        return NO;
    }
    
    glGenBuffers(1, &_indiceBufferId);
    if (_indiceBufferId) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indiceBufferId);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indiceData.length, _indiceData.bytes, GL_STATIC_DRAW);
        _ready = YES;
    }
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    return _ready;
}

- (void)destoryBuffer {
    if (_indiceBufferId) {
        glDeleteBuffers(1, &_indiceBufferId);
        _indiceBufferId = 0;
    }
    _ready = NO;
}


- (BOOL)loadBuffer {
    if (!_ready) return NO;
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indiceBufferId);
    return YES;
}


- (void)unloadBuffer {
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}


@end
