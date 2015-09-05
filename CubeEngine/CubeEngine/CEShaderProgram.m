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
        fetch indexes...
        
    } else {
        // print error info
        CELog("================ vertexShader ================\n%s\n", [vertexShaderString UTF8String]);
        CELog("================ fragmentShader ================\n%s\n", [fragmentShaderString UTF8String]);
        CEError(@"Program link log: %@", [program programLog]);
        CEError(@"Fragment shader compile log: %@", [program fragmentShaderLog]);
        CEError(@"Vertex shader compile log: %@", [program vertexShaderLog]);
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
