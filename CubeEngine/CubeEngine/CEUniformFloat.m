//
//  CEShaderFloat.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformFloat.h"
#import "CEShaderVariable_privates.h"

@implementation CEUniformFloat

- (void)setFloatValue:(GLfloat)floatValue {
    _floatValue = floatValue;
    
    if (_index < 0) return;
    glUniform1f(_index, floatValue);
}


- (NSString *)dataType {
    return @"float";
}


@end
