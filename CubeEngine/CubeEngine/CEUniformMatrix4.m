//
//  CEShaderMatrix4.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniformMatrix4.h"

@implementation CEUniformMatrix4

- (void)setMatrix4:(GLKMatrix4)matrix4 {
    if (_index < 0) return;
#warning TEST Code
//    BOOL allEqual = YES;
//    for (int i = 0; i < 16; i++) {
//        if (allEqual) {
//            allEqual = (_matrix4.m[i] == matrix4.m[i]);
//        } else {
//            break;
//        }
//    }
//    if (allEqual) return;
    
    _matrix4 = matrix4;
    glUniformMatrix4fv(_index, 1, GL_FALSE, matrix4.m);
}


- (NSString *)dataType {
    return @"mat4";
}

@end
