//
//  CEShaderVector4.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVector4.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderVector4

- (void)setVector4:(GLKVector4)vector4 {
    _vector4 = vector4;
    
    if (_index < 0) return;
    glUniform4fv(_index, 1, vector4.v);
}

- (NSString *)declaration {
    return [NSString stringWithFormat:@"%@ vec4 %@;", [self precisionString], self.name];
}

@end