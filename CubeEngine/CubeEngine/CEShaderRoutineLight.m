//
//  CEShaderRoutineLight.m
//  CubeEngine
//
//  Created by chance on 8/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderRoutineLight.h"

@implementation CEShaderRoutineLight

- (NSString *)vertexShaderVariables {
    return CE_SHADER_STRING
    (
     required vec4 inputColor;
    );
}

@end
