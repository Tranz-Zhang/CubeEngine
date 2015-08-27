//
//  CEShaderLinkFunctionInfo.m
//  CubeEngine
//
//  Created by chance on 8/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderLinkFunctionInfo.h"

#define kCEJsonObjectKey_functionID @"functionID"
#define kCEJsonObjectKey_paramNames @"paramNames"
#define kCEJsonObjectKey_linkRange @"linkRange"

@implementation CEShaderLinkFunctionInfo

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _functionID = jsonDict[kCEJsonObjectKey_functionID];
        _paramNames = jsonDict[kCEJsonObjectKey_paramNames];
        _linkRange = NSRangeFromString(jsonDict[kCEJsonObjectKey_linkRange]);
    }
    return self;
}


- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_functionID.length) {
        dict[kCEJsonObjectKey_functionID] = _functionID;
    }
    if (_paramNames.count) {
        dict[kCEJsonObjectKey_paramNames] = _paramNames;
    }
    dict[kCEJsonObjectKey_linkRange] = NSStringFromRange(_linkRange);
    return [dict copy];
}


@end
