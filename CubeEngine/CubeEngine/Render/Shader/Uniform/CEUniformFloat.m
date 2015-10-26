//
//  CEShaderFloat.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformFloat.h"

@implementation CEUniformFloat

- (void)setFloatValue:(GLfloat)floatValue {
    if (_index < 0 || _floatValue == floatValue) {
        return;
    }
    _floatValue = floatValue;
    glUniform1f(_index, floatValue);
}


- (NSString *)dataType {
    return @"float";
}


@end
