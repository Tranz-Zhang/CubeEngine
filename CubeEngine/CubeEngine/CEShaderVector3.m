//
//  CEShaderVector3.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVector3.h"

@implementation CEShaderVector3

- (void)setVector3:(GLKVector3)vector3 {
    _vector3 = vector3;
    
    if (_index < 0) return;
    glUniform3fv(_index, 1, vector3.v);
}

@end
