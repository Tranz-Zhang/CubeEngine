//
//  CEShaderSample2D.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderSample2D.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderSample2D {
    int _textureIndex;
}


- (void)setTextureID:(GLuint)textureID {
    if (_textureID != textureID) {
        _textureID = textureID;
        
        if (_index < 0) return;
        glActiveTexture(GL_TEXTURE0 + _textureIndex);
        glBindTexture(GL_TEXTURE_2D, textureID);
        glUniform1i(_index, _textureIndex);
    }
}


- (void)setTextureIndex:(int)textureIndex {
    _textureIndex = textureIndex;
}



@end




