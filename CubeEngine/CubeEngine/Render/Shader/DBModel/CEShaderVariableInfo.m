//
//  CEShaderVariableInfo.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariableInfo.h"
#import "CEShaderVariableInfo_setter.h"

NSString *CEShaderVariableUsageString(CEShaderVariableUsage usage) {
    switch (usage) {
        case CEShaderVariableUsageUniform:
            return @"uniform";
        case CEShaderVariableUsageAttribute:
            return @"attribute";
        case CEShaderVariableUsageVarying:
            return @"varying";
        case CEShaderVariableUsageNone:
        default:
            return @"";
    }
}

CEShaderVariableUsage CEShaderVariableUsageFromString(NSString *usageString) {
    if ([usageString isEqualToString:@"uniform"]) {
        return CEShaderVariableUsageUniform;
    } else if ([usageString isEqualToString:@"attribute"]) {
        return CEShaderVariableUsageAttribute;
    } else if ([usageString isEqualToString:@"varying"]) {
        return CEShaderVariableUsageVarying;
    } else {
        return CEShaderVariableUsageNone;
    }
}


/*
CEShaderVariableType CEShaderVariableTypeFromString(NSString *typeString) {
    if ([typeString isEqualToString:@"bool"]) {
        return CEShaderVariableBool;
    } else if ([typeString isEqualToString:@"int"]) {
        return CEShaderVariableInt;
    } else if ([typeString isEqualToString:@"float"]) {
        return CEShaderVariableFloat;
    } else if ([typeString isEqualToString:@"vec2"]) {
        return CEShaderVariableVector2;
    } else if ([typeString isEqualToString:@"vec3"]) {
        return CEShaderVariableVector3;
    } else if ([typeString isEqualToString:@"vec4"]) {
        return CEShaderVariableVector4;
    } else if ([typeString isEqualToString:@"mat2"]) {
        return CEShaderVariableMatrix2;
    } else if ([typeString isEqualToString:@"mat3"]) {
        return CEShaderVariableMatrix3;
    } else if ([typeString isEqualToString:@"mat4"]) {
        return CEShaderVariableMatrix4;
    } else if ([typeString isEqualToString:@"simpler2D"]) {
        return CEShaderVariableSampler2D;
    } else if ([typeString isEqualToString:@"void"]){
        return CEShaderVariableVoid;
    } else {
        return CEShaderVariableUnknown;
    }
}


NSString *CEShaderVariableTypeStringWithType(CEShaderVariableType type) {
    switch (type) {
        case CEShaderVariableFloat:
            return @"float";
        case CEShaderVariableInt:
            return @"int";
        case CEShaderVariableBool:
            return @"bool";
            
        case CEShaderVariableVector2:
            return @"vec2";
        case CEShaderVariableVector3:
            return @"vec3";
        case CEShaderVariableVector4:
            return @"vec4";
            
        case CEShaderVariableMatrix2:
            return @"mat2";
        case CEShaderVariableMatrix3:
            return @"mat3";
        case CEShaderVariableMatrix4:
            return @"mat4";
            
        case CEShaderVariableSampler2D:
            return @"simpler2D";
            
        case CEShaderVariableVoid:
            return @"void";
            
        case CEShaderVariableUnknown:
        default:
            return nil;
    }
}
//*/


#define kCEJsonObjectKey_variableID @"variableID"
#define kCEJsonObjectKey_name @"name"
#define kCEJsonObjectKey_type @"type"
#define kCEJsonObjectKey_precision @"precision"
#define kCEJsonObjectKey_usage @"usage"
#define kCEJsonObjectKey_arrayItemCount @"arrayItemCount"

@implementation CEShaderVariableInfo {
    NSString *_declarationString;
}

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _variableID = [jsonDict[kCEJsonObjectKey_variableID] unsignedIntValue];
        _name = jsonDict[kCEJsonObjectKey_name];
        _type = jsonDict[kCEJsonObjectKey_type];
        _precision = jsonDict[kCEJsonObjectKey_precision];
        _usage = [jsonDict[kCEJsonObjectKey_usage] intValue];
        _arrayItemCount = [jsonDict[kCEJsonObjectKey_arrayItemCount] intValue];
    }
    return self;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _arrayItemCount = 1;
    }
    return self;
}


- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kCEJsonObjectKey_variableID] = @(_variableID);
    if (_name.length) {
        dict[kCEJsonObjectKey_name] = _name;
    }
    if (_type.length) {
    dict[kCEJsonObjectKey_type] = _type;
    }
    if (_precision.length) {
        dict[kCEJsonObjectKey_precision] = _precision;
    }
    dict[kCEJsonObjectKey_usage] = @(_usage);
    dict[kCEJsonObjectKey_arrayItemCount] = @(_arrayItemCount);
    return [dict copy];
}


- (NSString *)declarationString {
    if (_declarationString) {
        return _declarationString;
    }
    NSMutableString *declaration = [NSMutableString string];
    switch (_usage) {
        case CEShaderVariableUsageUniform:
            [declaration appendString:@"uniform "];
            break;
        case CEShaderVariableUsageAttribute:
            [declaration appendString:@"attribute "];
            break;
        case CEShaderVariableUsageVarying:
            [declaration appendString:@"varying "];
            break;
        case CEShaderVariableUsageNone:
        default:
            break;
    }
    if (_precision) {
        [declaration appendFormat:@"%@ ", _precision];
    }
    [declaration appendFormat:@"%@ ", _type];
    [declaration appendFormat:@"%@", _name];
    if (_arrayItemCount > 1) {
        [declaration appendFormat:@"[%d]", _arrayItemCount];
    }
    [declaration appendString:@";"];
    _declarationString = declaration.copy;
    return _declarationString;
}


- (NSString *)description {
    return [[self jsonDict] description];
}


- (BOOL)isEqual:(CEShaderVariableInfo *)other {
    return _variableID == other.variableID;
}


- (NSUInteger)hash {
    return _variableID;
}


@end



