//
//  CEShaderVec2.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVector2.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderVector2

- (void)setVector2:(GLKVector2)vector2 {
    _vector2 = vector2;
    
    if (_index < 0) return;
    glUniform2fv(_index, 1, vector2.v);
}

- (NSString *)declaration {
    return [NSString stringWithFormat:@"%@ vec2 %@;", self.precision, self.name];
}

@end
