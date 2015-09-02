//
//  CEShaderBool.m
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderBool.h"
#import "CEShaderVariable_privates.h"

@implementation CEShaderBool

- (void)setBoolValue:(BOOL)boolValue {
    _boolValue = boolValue;
    
    if (_index < 0) return;
    glUniform1i(_index, boolValue ? 1 : 0);
}

@end
