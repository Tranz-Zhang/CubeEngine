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
    NSDictionary *_uniformVariableDict;
}

+ (instancetype)buildProgramWithShaderInfo:(CEShaderInfo *)shaderInfo {
    if (!shaderInfo.vertexShader.length || !shaderInfo.fragmentShader.length) {
        return nil;
    }
    CEProgram *program = [[CEProgram alloc] initWithVertexShaderString:shaderInfo.vertexShader
                                                  fragmentShaderString:shaderInfo.fragmentShader];
    // setup attributes for program
    NSArray *attributeTypes = [self addAttributes:shaderInfo.attributeInfoDict.allKeys
                                        toProgram:program];
    if (!attributeTypes.count) {
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
    [shaderProgram setupWithProgram:program attributeTypes:attributeTypes uniformInfoDict:shaderInfo.uniformInfoDict];
    return shaderProgram;
}


+ (NSArray *)addAttributes:(NSArray *)attributeNames toProgram:(CEProgram *)program {
    if (!attributeNames.count || !program) {
        return nil;
    }
    // attribute must added in this order
    NSMutableArray *sortedAttributes = [NSMutableArray array];
    for (NSString *attributeName in attributeNames) {
        CEVBOAttributeName attributeType = CEVBOAttributeNameWithShaderDeclaration(attributeName);
        if (attributeType != CEVBOAttributeUnknown) {
            [sortedAttributes addObject:@(attributeType)];
            [program addAttribute:attributeName atIndex:attributeType];
        } else {
            return nil;
        }
    }
    return sortedAttributes.copy;
}


- (void)setupWithProgram:(CEProgram *)program
          attributeTypes:(NSArray *)attributeTypes
         uniformInfoDict:(NSDictionary *)uniformInfoDict {
    _program = program;
    _textureUnitCount = 0;
    NSMutableDictionary *uniformVariableDict = [NSMutableDictionary dictionary];
    [uniformInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString *variableName, CEShaderVariableInfo *info, BOOL *stop) {
        NSString *className = [[CEShaderProgram typeToUniformClassNameDict] objectForKey:info.type];
        if (className) {
            CEShaderVariable *uniform = [[NSClassFromString(className) alloc] initWithName:variableName];
            if ([uniform setupIndexWithProgram:program]) {
                uniformVariableDict[variableName] = uniform;
            }
        }
        if ([info.type isEqualToString:@"sampler2D"]) {
            _textureUnitCount++;
        }
    }];
    _uniformVariableDict = uniformVariableDict.copy;
    _attributes = [attributeTypes copy];
    _attributesType = [CEVBOAttribute attributesTypeWithNames:_attributes];
    [self onProgramSetup];
}


- (CEShaderVariable *)uniformVariableWithName:(NSString *)name type:(NSString *)dataType {
    if (!name.length || !dataType.length) {
        return nil;
    }
    CEShaderVariable *variable = _uniformVariableDict[name];
    if (variable && [variable.dataType isEqualToString:dataType]) {
        return variable;
    }
    return nil;
}


- (void)onProgramSetup {
    CEError(@"Must Implement by subclass");
}


- (void)use {
    [_program use];
}

#pragma mark - Others

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


