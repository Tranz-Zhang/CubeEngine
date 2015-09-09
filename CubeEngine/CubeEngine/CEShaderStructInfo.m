//
//  CEShaderStructInfo.m
//  CubeEngine
//
//  Created by chance on 9/1/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderStructInfo.h"
#import "CEShaderStructInfo_setter.h"

#define kCEJsonObjectKey_structID @"structID"
#define kCEJsonObjectKey_name @"name"
#define kCEJsonObjectKey_variables @"variables"

@implementation CEShaderStructInfo {
    NSString *_declarationString;
}

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _structID = [jsonDict[kCEJsonObjectKey_structID] unsignedLongLongValue];
        _name = jsonDict[kCEJsonObjectKey_name];
        NSArray *variableDicts = jsonDict[kCEJsonObjectKey_variables];
        NSMutableArray *variables = [NSMutableArray arrayWithCapacity:variableDicts.count];
        for (NSDictionary *variableDict in variableDicts) {
            CEShaderVariableInfo *variableInfo = [[CEShaderVariableInfo alloc] initWithJsonDict:variableDict];
            [variables addObject:variableInfo];
        }
        if (variables.count) {
            _variables = variables.copy;
        }
    }
    return self;
}


- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kCEJsonObjectKey_structID] = @(_structID);
    if (_name.length) {
        dict[kCEJsonObjectKey_name] = _name;
    }
    if (_variables.count) {
        NSMutableArray *jsonArray = [NSMutableArray array];
        for (CEShaderVariableInfo *variable in _variables) {
            NSDictionary *jsonDict = [variable jsonDict];
            if (jsonDict) {
                [jsonArray addObject:jsonDict];
            }
        }
        dict[kCEJsonObjectKey_variables] = jsonArray.copy;
    }
    
    return [dict copy];
}


- (NSString *)declarationString {
    if (_declarationString) {
        return _declarationString;
    }
    NSMutableString *declaration = [NSMutableString string];
    [declaration appendFormat:@"struct %@ {\n", _name];
    for (CEShaderVariableInfo *info in _variables) {
        [declaration appendFormat:@"  %@\n", [info declarationString]];
    }
    [declaration appendString:@"};"];
    _declarationString = declaration.copy;
    return _declarationString;
}


- (NSString *)description {
    return [[self jsonDict] description];
}


- (BOOL)isEqual:(CEShaderStructInfo *)other {
    return _structID == other.structID;
}


- (NSUInteger)hash {
    return _structID;
}


@end
