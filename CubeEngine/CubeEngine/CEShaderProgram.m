//
//  CEShaderProgram.m
//  CubeEngine
//
//  Created by chance on 9/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProgram.h"
#import "CEShaderProgram_privates.h"

@implementation CEShaderProgram {
    NSDictionary *_variableDict;
}

+ (instancetype)buildProgramWithShaderInfo:(CEShaderInfo *)shaderInfo {
    CEProgram *program = [[CEProgram alloc] initWithVertexShaderString:shaderInfo.vertexShader
                                                  fragmentShaderString:shaderInfo.fragmentShader];
    [shaderInfo.variableInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString *variableName, CEShaderVariableInfo *info, BOOL *stop) {
        if (info.usage == CEShaderVariableUsageAttribute) {
            [program addAttribute:variableName];
        }
    }];
    
    if (![program link]) {
        // print error info
        CELog("================ vertexShader ================\n%s\n", [vertexShaderString UTF8String]);
        CELog("================ fragmentShader ================\n%s\n", [fragmentShaderString UTF8String]);
        CEError(@"Program link log: %@", [program programLog]);
        CEError(@"Fragment shader compile log: %@", [program fragmentShaderLog]);
        CEError(@"Vertex shader compile log: %@", [program vertexShaderLog]);
        NSAssert(0, @"Fail to Compile Program");
    }
    
    CEShaderProgram *shaderProgram = [[self class] init];
    [shaderProgram setupWithProgram:program shaderInfo:shaderInfo];
    return shaderProgram;
}


- (void)setupWithProgram:(CEProgram *)program shaderInfo:(CEShaderInfo *)shaderInfo {
    _program = program;
    
    NSMutableDictionary *variableDict = [NSMutableDictionary dictionary];
    [shaderInfo.variableInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString *variableName, CEShaderVariableInfo *info, BOOL *stop) {
        how to parse struct and variables
    }];
}


+ (NSDictionary *)

@end


