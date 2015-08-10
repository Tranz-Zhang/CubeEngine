//
//  CEShaderMatrix2.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderMatrix2.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderMatrix2

- (void)setMatrix2:(GLKMatrix2)matrix2 {
    _matrix2 = matrix2;
    
    if (_index < 0) return;
    glUniformMatrix2fv(_index, 1, GL_FALSE, matrix2.m);
}

- (NSString *)declarationString {
    return [NSString stringWithFormat:@"uniform %@ mat2 %@", [self precisionString], self.name];
}

@end
