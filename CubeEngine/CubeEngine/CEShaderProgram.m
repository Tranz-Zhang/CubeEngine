//
//  CEShaderProgram.m
//  CubeEngine
//
//  Created by chance on 9/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProgram.h"
#import "CEShaderProgram_privates.h"

@implementation CEShaderProgram

+ (instancetype)buildProgramWithShaderInfo:(CEShaderInfo *)shaderInfo {
    CEProgram *program = [[CEProgram alloc] initWithVertexShaderString:shaderInfo.vertexShader
                                                  fragmentShaderString:shaderInfo.fragmentShader];
    for (NSString *attributeName in shaderInfo.attributeDict.allKeys) {
        [program addAttribute:attributeName];
    }
    
    if ([program link]) {
        printf("compile OK\n");
        
    } else {
        // print error info
        NSString *progLog = [program programLog];
        CEError(@"Program link log: %@", progLog);
        NSString *fragLog = [program fragmentShaderLog];
        CEError(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [program vertexShaderLog];
        CEError(@"Vertex shader compile log: %@", vertLog);
        NSAssert(0, @"Fail to Compile Program");
    }
    
    return nil;
}


- (void)setProgram:(CEProgram *)program {
    if (program != _program) {
        _program = program;
    }
}


@end
