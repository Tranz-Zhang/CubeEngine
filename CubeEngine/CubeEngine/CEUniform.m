//
//  CEUniform.m
//  CubeEngine
//
//  Created by chance on 9/7/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEUniform.h"
#import "CEShaderVariable_privates.h"

@implementation CEUniform

- (BOOL)setupIndexWithProgram:(CEProgram *)program {
    _index = [program uniformIndex:self.name];
    return _index >= 0;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"uniform %@ %@(%d)", [self dataType], self.name, _index];
}

@end
