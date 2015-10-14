//
//  CEShaderVector3.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformVector3.h"

@implementation CEUniformVector3

- (void)setVector3:(GLKVector3)vector3 {
    if (_index < 0 || GLKVector3AllEqualToVector3(_vector3, vector3)) {
        return;
    }
    _vector3 = vector3;
    glUniform3fv(_index, 1, vector3.v);
}


- (NSString *)dataType {
    return @"vec3";
}

@end
