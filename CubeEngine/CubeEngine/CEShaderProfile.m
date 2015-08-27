//
//  TestCodingGroup.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProfile.h"

#define kCEJsonObjectKey_structs    @"structs"
#define kCEJsonObjectKey_variables  @"variables"
#define kCEJsonObjectKey_function  @"function"


@implementation CEShaderProfile

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _structs = jsonDict[kCEJsonObjectKey_structs];
        _variables = [self shaderVariablesFromJsonArray:jsonDict[kCEJsonObjectKey_variables]];
        _function = [[CEShaderFunctionInfo alloc] initWithJsonDict:jsonDict[kCEJsonObjectKey_function]];
    }
    return self;
}


- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_structs.count) {
        dict[kCEJsonObjectKey_structs] = _structs;
    }
    if (_variables.count) {
        dict[kCEJsonObjectKey_variables] = [self jsonArrayFromShaderVariables:_variables];
    }
    if (_function) {
        dict[kCEJsonObjectKey_function] = [_function jsonDict];
    }
    return [dict copy];
}


/*
#pragma mark - parse CEShaderFunctionInfo
- (NSArray *)shaderFunctionsFromJsonArray:(NSArray *)jsonArray {
    if (!jsonArray.count) return nil;
    NSMutableArray *functions = [NSMutableArray arrayWithCapacity:jsonArray.count];
    for (NSDictionary *jsonDict in jsonArray) {
        CEShaderFunctionInfo *function = [[CEShaderFunctionInfo alloc] initWithJsonDict:jsonDict];
        [functions addObject:function];
    }
    return [functions copy];
}


- (NSArray *)jsonArrayFromShaderFunctions:(NSArray *)shaderFunctions {
    if (!shaderFunctions.count) return nil;
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:shaderFunctions.count];
    for (CEShaderFunctionInfo *function in shaderFunctions) {
        NSDictionary *jsonDict = [function jsonDict];
        if (jsonDict) {
            [jsonArray addObject:jsonDict];
        }
    }
    return [jsonArray copy];
}
//*/


#pragma mark - parse CEShaderVariableInfo
- (NSArray *)shaderVariablesFromJsonArray:(NSArray *)jsonArray {
    if (!jsonArray.count) return nil;
    NSMutableArray *variables = [NSMutableArray arrayWithCapacity:jsonArray.count];
    for (NSDictionary *jsonDict in jsonArray) {
        CEShaderVariableInfo *variableInfo = [[CEShaderVariableInfo alloc] initWithJsonDict:jsonDict];
        [variables addObject:variableInfo];
    }
    return [variables copy];
}


- (NSArray *)jsonArrayFromShaderVariables:(NSArray *)shaderFunctions {
    if (!shaderFunctions.count) return nil;
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:shaderFunctions.count];
    for (CEShaderVariableInfo *variableInfo in shaderFunctions) {
        NSDictionary *jsonDict = [variableInfo jsonDict];
        if (jsonDict) {
            [jsonArray addObject:jsonDict];
        }
    }
    return [jsonArray copy];
}


@end
