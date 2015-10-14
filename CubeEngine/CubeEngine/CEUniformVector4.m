//
//  CEShaderVector4.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformVector4.h"

@implementation CEUniformVector4

- (void)setVector4:(GLKVector4)vector4 {
    if (_index < 0 || GLKVector4AllEqualToVector4(vector4, _vector4)) {
        return;
    }
    _vector4 = vector4;
    glUniform4fv(_index, 1, vector4.v);
}


- (NSString *)dataType {
    return @"vec4";
}


@end
