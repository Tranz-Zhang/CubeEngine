//
//  CEShaderSample2D.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformSampler2D.h"

@implementation CEUniformSampler2D {
    int _textureIndex;
}


- (void)setTextureID:(GLuint)textureID {
//    if (_textureID != textureID) {
        _textureID = textureID;
        
        if (_index < 0) return;
        glActiveTexture(GL_TEXTURE0 + _textureIndex);
        glBindTexture(GL_TEXTURE_2D, textureID);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glUniform1i(_index, _textureIndex);
//    }
}


- (void)setTextureIndex:(int)textureIndex {
    _textureIndex = textureIndex;
}


- (NSString *)dataType {
    return @"sampler2D";
}


@end


