//
//  CEShaderSample2D.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformSampler2D.h"

@implementation CEUniformSampler2D

- (void)setTextureUnit:(GLuint)textureUnit {
    if (_textureUnit != textureUnit) {
        if (_index < 0) return;
        glUniform1i(_index, _textureUnit);
    }
}


- (NSString *)dataType {
    return @"sampler2D";
}


@end

