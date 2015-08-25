//
//  CEShaderVariableInfo.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderVariableInfo.h"

#define kCEJsonObjectKey_name @"name"
#define kCEJsonObjectKey_type @"type"
#define kCEJsonObjectKey_precision @"precision"
#define kCEJsonObjectKey_usage @"usage"


@implementation CEShaderVariableInfo

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _name = jsonDict[kCEJsonObjectKey_name];
        _type = jsonDict[kCEJsonObjectKey_type];
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
    if (_type.length) {
        dict[kCEJsonObjectKey_type] = _type;
    }
    if (_precision.length) {
        dict[kCEJsonObjectKey_precision] = _precision;
    }
    dict[kCEJsonObjectKey_usage] = @(_usage);
    return [dict copy];
}


@end

