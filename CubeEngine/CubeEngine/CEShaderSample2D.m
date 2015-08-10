//
//  CEShaderSample2D.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderSample2D.h"

@implementation CEShaderSample2D {
    int _textureIndex;
    GLuint textureID;
}

- (void)setTextureID:(GLuint)textureID {
    _textureID = textureID;
    
    if (_index < 0) return;
    
}

- (void)setTextureIndex:(int)textureIndex {
    _textureIndex = textureIndex;
}

@end
