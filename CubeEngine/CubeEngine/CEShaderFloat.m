//
//  CEShaderFloat.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderFloat.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderFloat

- (void)setFloatValue:(GLfloat)floatValue {
    _floatValue = floatValue;
    
    if (_index < 0) return;
    glUniform1f(_index, floatValue);
}

- (NSString *)declaration {
    return [NSString stringWithFormat:@"%@ float %@;", [self precisionString], self.name];
}

@end
