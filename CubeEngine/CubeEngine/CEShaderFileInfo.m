//
//  TestCodingGroup.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderFileInfo.h"

#define kCEJsonObjectKey_VTX_structs    @"vertexShaderStructs"
#define kCEJsonObjectKey_VTX_variables  @"vertexShaderVariables"
#define kCEJsonObjectKey_VTX_functions  @"vertexShaderFunctions"

#define kCEJsonObjectKey_FRG_structs    @"fragmentShaderStructs"
#define kCEJsonObjectKey_FRG_variables  @"fragmentShaderVariables"
#define kCEJsonObjectKey_FRG_functions  @"fragmentShaderFunctions"


@implementation CEShaderFileInfo

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _vertexShaderStructs = jsonDict[kCEJsonObjectKey_VTX_structs];
        _vertexShaderVariables = [self shaderVariablesFromJsonArray:jsonDict[kCEJsonObjectKey_VTX_variables]];
        _vertexShaderFunctions = [self shaderFunctionsFromJsonArray:jsonDict[kCEJsonObjectKey_VTX_functions]];
        
        _fragmentShaderStructs = jsonDict[kCEJsonObjectKey_FRG_structs];
        _fragmentShaderVariables = [self shaderVariablesFromJsonArray:jsonDict[kCEJsonObjectKey_FRG_variables]];
        _fragmentShaderFunctions = [self shaderFunctionsFromJsonArray:jsonDict[kCEJsonObjectKey_FRG_functions]];
        
    }
    return self;
}


- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_vertexShaderStructs.count) {
        dict[kCEJsonObjectKey_VTX_structs] = _vertexShaderStructs;
    }
    if (_vertexShaderVariables.count) {
        dict[kCEJsonObjectKey_VTX_variables] = [self jsonArrayFromShaderVariables:_vertexShaderVariables];
    }
    if (_vertexShaderFunctions.count) {
        dict[kCEJsonObjectKey_VTX_functions] = [self jsonArrayFromShaderFunctions:_vertexShaderFunctions];
    }
    
    if (_fragmentShaderStructs.count) {
        dict[kCEJsonObjectKey_FRG_structs] = _fragmentShaderStructs;
    }
    if (_fragmentShaderVariables.count) {
        dict[kCEJsonObjectKey_FRG_variables] = [self jsonArrayFromShaderVariables:_fragmentShaderVariables];
    }
    if (_fragmentShaderFunctions.count) {
        dict[kCEJsonObjectKey_FRG_functions] = [self jsonArrayFromShaderFunctions:_fragmentShaderFunctions];
    }
    return [dict copy];
}


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
