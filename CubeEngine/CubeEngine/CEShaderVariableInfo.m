//
//  CEShaderVariableInfo.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariableInfo.h"
#import "CEShaderVariableDefines.h"

#define kCEJsonObjectKey_name @"name"
#define kCEJsonObjectKey_type @"type"
#define kCEJsonObjectKey_precision @"precision"
#define kCEJsonObjectKey_usage @"usage"

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

@implementation CEShaderVariableInfo

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _name = jsonDict[kCEJsonObjectKey_name];
        _type = [jsonDict[kCEJsonObjectKey_type] intValue];
        _precision = jsonDict[kCEJsonObjectKey_precision];
        _usage = [jsonDict[kCEJsonObjectKey_usage] intValue];
    }
    return self;
}


- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_name.length) {
        dict[kCEJsonObjectKey_name] = _name;
    }
    if (_precision.length) {
        dict[kCEJsonObjectKey_precision] = _precision;
    }
    dict[kCEJsonObjectKey_type] = @(_type);
    dict[kCEJsonObjectKey_usage] = @(_usage);
    return [dict copy];
}



- (BOOL)isEqual:(CEShaderVariableInfo *)object
{
    if (object == self) {
        return YES;
    } else if (![super isEqual:object]) {
        return NO;
    } else {
        return (self == object &&
                [_name isEqualToString:object.name] &&
                _type == object.type &&
                [_precision isEqualToString:object.precision] &&
                _usage == object.usage);
    }
}


- (NSUInteger)hash {
    NSString *hashString = [NSString stringWithFormat:@"%@%d%@%d", _name, _type, _precision, _usage];
    printf("%s:%lu\n", [_name UTF8String], (unsigned long)hashString.hash);
    return [[NSString stringWithFormat:@"%@%d%@%d", _name, _type, _precision, _usage] hash];
}


- (CEShaderVariable *)toShaderVariable {
    NSString *precision = _precision ?: kCEPrecisionDefault;
    
    if (_usage == CEShaderVariableUsageAttribute) {
        int variableCount = -1;
        switch (_type) {
            case CEShaderVariableFloat:
                variableCount = 1;
                break;
            case CEShaderVariableVector2:
                variableCount = 2;
                break;
            case CEShaderVariableVector3:
                variableCount = 3;
                break;
                
            case CEShaderVariableVector4:
                variableCount = 4;
                break;
            default:
                break;
        }
        if (variableCount > 0) {
            return [[CEShaderAttribute alloc] initWithName:_name precision:precision variableCount:variableCount];
        } else {
            return nil;
        }
    }
    
    // uniforms
    switch (_type) {
        case CEShaderVariableFloat:
            return [[CEShaderFloat alloc] initWithName:_name precision:precision];
        case CEShaderVariableInt:
            return [[CEShaderInteger alloc] initWithName:_name precision:precision];
        case CEShaderVariableBool:
            return [[CEShaderBool alloc] initWithName:_name precision:precision];
            
        case CEShaderVariableVector2:
            return [[CEShaderVector2 alloc] initWithName:_name precision:precision];
        case CEShaderVariableVector3:
            return [[CEShaderVector3 alloc] initWithName:_name precision:precision];
        case CEShaderVariableVector4:
            return [[CEShaderVector4 alloc] initWithName:_name precision:precision];
            
        case CEShaderVariableMatrix2:
            return [[CEShaderMatrix2 alloc] initWithName:_name precision:precision];
        case CEShaderVariableMatrix3:
            return [[CEShaderMatrix3 alloc] initWithName:_name precision:precision];
        case CEShaderVariableMatrix4:
            return [[CEShaderMatrix3 alloc] initWithName:_name precision:precision];
            
        case CEShaderVariableSampler2D:
            return [[CEShaderSample2D alloc] initWithName:_name precision:precision];
            
        case CEShaderVariableUnknown:
        case CEShaderVariableVoid:
        default:
            return nil;
    }
}


@end

