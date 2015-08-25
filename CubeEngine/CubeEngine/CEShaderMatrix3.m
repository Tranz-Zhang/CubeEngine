//
//  CEShaderMatrix3.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderMatrix3.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderMatrix3

- (void)setMatrix3:(GLKMatrix3)matrix3 {
    _matrix3 = matrix3;
    
    if (_index < 0) return;
    glUniformMatrix3fv(_index, 1, GL_FALSE, matrix3.m);
}

- (NSString *)declaration {
    return [NSString stringWithFormat:@"%@ mat3 %@;", self.precision, self.name];
}

@end
