//
//  CEShaderInteger.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderInteger.h"

@implementation CEShaderInteger

- (void)setIntValue:(GLint)intValue {
    _intValue = intValue;
    
    if (_index < 0) return;
    glUniform1i(_index, intValue);
}

@end
