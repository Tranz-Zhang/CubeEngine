//
//  CEShaderMatrix4.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderMatrix4.h"

@implementation CEShaderMatrix4

- (void)setMatrix4:(GLKMatrix4)matrix4 {
    _matrix4 = matrix4;
    
    if (_index < 0) return;
    glUniformMatrix4fv(_index, 1, GL_FALSE, matrix4.m);
}

@end
