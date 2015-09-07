//
//  CEShaderProgram.m
//  CubeEngine
//
//  Created by chance on 9/4/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProgram.h"
#import "CEShaderProgram_privates.h"
#import "CEShaderVariable_privates.h"

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
        CEPrintf("================ vertexShader ================\n%s\n", [shaderInfo.vertexShader UTF8String]);
        CEPrintf("================ fragmentShader ================\n%s\n", [shaderInfo.fragmentShader UTF8String]);
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
        if (info.usage == CEShaderVariableUsageAttribute) {
            CEAttributeType type = CEAttributeTypeWithString(info.type);
            CEAttribute *attribute = [[CEAttribute alloc] initWithName:variableName type:type];
            if ([attribute setupIndexWithProgram:program]) {
                variableDict[variableName] = attribute;
            }
            
        } else if (info.usage == CEShaderVariableUsageUniform) {
            CEUniform *uniform = [[CEUniform alloc] initWithName:variableName];
            if ([uniform setupIndexWithProgram:program]) {
                variableDict[variableName] = uniform;
            }
        }
    }];
    
    NSLog(@"");
}


+ (NSDictionary *)typeToUniformClassNameDict {
    static NSDictionary *sTypeToVariableClassNameDict = nil;
    if (!sTypeToVariableClassNameDict) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sTypeToVariableClassNameDict =
            @{
              @"bool"   : @"CEUniformBool",
              @"int"    : @"CEUniformInteger",
              @"float"  : @"CEUniformFloat",
              @"vec2"   : @"CEUniformVector2",
              @"vec3"   : @"CEUniformVector3",
              @"vec4"   : @"CEUniformVector4",
              @"mat2"   : @"CEUniformMatrix2",
              @"mat3"   : @"CEUniformMatrix3",
              @"mat4"   : @"CEUniformMatrix4",
              @"sampler2D" : @"CEUniformSampler2D",
              @"LightInfo" : @"CEUniformLightInfo", //!!!: custom struct
              };
        });
    }
    return sTypeToVariableClassNameDict;
}

@end


