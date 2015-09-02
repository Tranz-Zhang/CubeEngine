//
//  TestCodingGroup.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProfile.h"
#import "CEShaderProfile__setter.h"

#define kCEJsonObjectKey_structs    @"structs"
#define kCEJsonObjectKey_variables  @"variables"
#define kCEJsonObjectKey_function  @"function"


@implementation CEShaderProfile

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        NSArray *jsonArray = jsonDict[kCEJsonObjectKey_structs];
        if (jsonArray.count) {
            NSMutableArray *structs = [NSMutableArray arrayWithCapacity:jsonArray.count];
            for (NSDictionary *structDict in jsonArray) {
                CEShaderStructInfo *structInfo = [[CEShaderStructInfo alloc] initWithJsonDict:structDict];
                [structs addObject:structInfo];
            }
            _structs = structs.copy;
        }
        
        jsonArray = jsonDict[kCEJsonObjectKey_variables];
        if (jsonArray.count) {
            NSMutableArray *variables = [NSMutableArray arrayWithCapacity:jsonArray.count];
            for (NSDictionary *variableDict in jsonArray) {
                CEShaderVariableInfo *variableInfo = [[CEShaderVariableInfo alloc] initWithJsonDict:variableDict];
                [variables addObject:variableInfo];
            }
            _variables = variables.copy;
        }
        
        _function = [[CEShaderFunctionInfo alloc] initWithJsonDict:jsonDict[kCEJsonObjectKey_function]];
    }
    return self;
}


- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_structs.count) {
        NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:_structs.count];
        for (CEShaderStructInfo *structInfo in _structs) {
            NSDictionary *jsonDict = [structInfo jsonDict];
            if (jsonDict) {
                [jsonArray addObject:jsonDict];
            }
        }
        dict[kCEJsonObjectKey_structs] = jsonArray.copy;
    }
    
    if (_variables.count) {
        NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:_variables.count];
        for (CEShaderVariableInfo *variableInfo in _variables) {
            NSDictionary *jsonDict = [variableInfo jsonDict];
            if (jsonDict) {
                [jsonArray addObject:jsonDict];
            }
        }
        dict[kCEJsonObjectKey_variables] = jsonArray.copy;
    }
    
    if (_function) {
        dict[kCEJsonObjectKey_function] = [_function jsonDict];
    }
    return [dict copy];
}


- (NSString *)description {
    return [[self jsonDict] description];
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
//*/

@end
