//
//  CEShaderVariable_privates.h
//  CubeEngine
//
//  Created by chance on 8/6/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariable.h"
#import "CEProgram.h"

@interface CEShaderVariable ()

// index retrive from glProgram
//@property (nonatomic, assign) GLint index;

// implementd by subclass
- (BOOL)setupIndexWithProgram:(CEProgram *)program;

@end
