//
//  CEShaderInteger.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformInteger.h"
#import "CEShaderVariable_privates.h"

@implementation CEUniformInteger

- (void)setIntValue:(GLint)intValue {
    _intValue = intValue;
    
    if (_index < 0) return;
    glUniform1i(_index, intValue);
}

- (NSString *)dataType {
    return @"int";
}

@end
