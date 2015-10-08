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
#import "CEShaderVariableDefines.h"

@implementation CEShaderProgram {
    NSDictionary *_variableDict;
}

+ (instancetype)buildProgramWithShaderInfo:(CEShaderInfo *)shaderInfo {
    if (!shaderInfo.vertexShader.length || !shaderInfo.fragmentShader.length) {
        return nil;
    }
    CEProgram *program = [[CEProgram alloc] initWithVertexShaderString:shaderInfo.vertexShader
                                                  fragmentShaderString:shaderInfo.fragmentShader];
    // setup attributes for program
    if (![self addAttributes:shaderInfo.attributeInfoDict.allKeys toProgram:program]) {
        return nil;
    }
    
    if (![program link]) {
        // print error info
        CEPrintf("================ vertexShader ================\n%s\n", [shaderInfo.vertexShader UTF8String]);
        CEPrintf("================ fragmentShader ================\n%s\n", [shaderInfo.fragmentShader UTF8String]);
        CEError(@"Program link log: %@", [program programLog]);
        CEError(@"Fragment shader compile log: %@", [program fragmentShaderLog]);
        CEError(@"Vertex shader compile log: %@", [program vertexShaderLog]);
        NSAssert(0, @"Fail to Compile Program");
    }
    
    CEShaderProgram *shaderProgram = [[[self class] alloc] init];
    [shaderProgram setupWithProgram:program shaderInfo:shaderInfo];
    return shaderProgram;
}


+ (BOOL)addAttributes:(NSArray *)attributeNames toProgram:(CEProgram *)program {
    if (!attributeNames.count || !program) {
        return NO;
    }
    // attribute must added in this order
    NSArray *attributeKeywords = @[@"position", @"uv", @"texture", @"normal", @"tangent", @"color"];
    NSMutableArray *sortedAttributeNames = [NSMutableArray array];
    for (NSString *keyword in attributeKeywords) {
        NSString *matchedAttributeName = nil;
        for (NSString *attributeName in attributeNames) {
            NSRange matchRange = [attributeName rangeOfString:keyword options:NSCaseInsensitiveSearch];
            if (matchRange.location != NSNotFound) {
                matchedAttributeName = attributeName;
                break;
            }
        }
        if (matchedAttributeName) {
            [sortedAttributeNames addObject:matchedAttributeName];
        }
    }
    if (sortedAttributeNames.count != attributeNames.count) {
        CEError(@"Unrecognized attribute names: %@", attributeNames);
        return NO;
    }
    for (NSString *attributeName in attributeNames) {
        [program addAttribute:attributeName];
    }
    
    return YES;
}


- (void)setupWithProgram:(CEProgram *)program shaderInfo:(CEShaderInfo *)shaderInfo {
    _program = program;
    
    NSMutableDictionary *variableDict = [NSMutableDictionary dictionary];
    [shaderInfo.uniformInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString *variableName, CEShaderVariableInfo *info, BOOL *stop) {
        NSString *className = [[CEShaderProgram typeToUniformClassNameDict] objectForKey:info.type];
        if (className) {
            CEShaderVariable *uniform = [[NSClassFromString(className) alloc] initWithName:variableName];
            if ([uniform setupIndexWithProgram:program]) {
                variableDict[variableName] = uniform;
            }
        }
    }];
    [shaderInfo.attributeInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString *variableName, CEShaderVariableInfo *info, BOOL *stop) {
        NSString *className = [[CEShaderProgram typeToAttributeClassNameDict] objectForKey:info.type];
        if (className) {
            CEAttribute *attribute = [[NSClassFromString(className) alloc] initWithName:variableName];
            if ([attribute setupIndexWithProgram:program]) {
                variableDict[variableName] = attribute;
            }
        }
    }];
    
    _variableDict = variableDict.copy;
    [self onProgramSetup];
}


- (CEShaderVariable *)outputVariableWithName:(NSString *)name type:(NSString *)dataType {
    if (!name.length || !dataType.length) {
        return nil;
    }
    CEShaderVariable *variable = _variableDict[name];
    if (variable && [variable.dataType isEqualToString:dataType]) {
        return variable;
    }
    return nil;
}

- (void)onProgramSetup {
    
}

- (void)use {
    [_program use];
}

#pragma mark - Others

+ (NSDictionary *)typeToAttributeClassNameDict {
    static NSDictionary *sTypeToAttributeClassNameDict = nil;
    if (!sTypeToAttributeClassNameDict) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sTypeToAttributeClassNameDict =
            @{
              @"float"  : @"CEAttributeFloat",
              @"vec2"   : @"CEAttributeVector2",
              @"vec3"   : @"CEAttributeVector3",
              @"vec4"   : @"CEAttributeVector4",
              };
            
            // load class the first time
            [CEAttributeFloat new];
            [CEAttributeVector2 new];
            [CEAttributeVector3 new];
            [CEAttributeVector4 new];
        });
    }
    return sTypeToAttributeClassNameDict;
}


+ (NSDictionary *)typeToUniformClassNameDict {
    static NSDictionary *sTypeToUniformClassNameDict = nil;
    if (!sTypeToUniformClassNameDict) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sTypeToUniformClassNameDict =
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
            
            // load class the first time
            [CEUniformBool new];
            [CEUniformInteger new];
            [CEUniformFloat new];
            [CEUniformVector2 new];
            [CEUniformVector3 new];
            [CEUniformVector4 new];
            [CEUniformMatrix2 new];
            [CEUniformMatrix3 new];
            [CEUniformMatrix4 new];
            [CEUniformSampler2D new];
            [CEUniformLightInfo new];
        });
    }
    return sTypeToUniformClassNameDict;
}

@end


