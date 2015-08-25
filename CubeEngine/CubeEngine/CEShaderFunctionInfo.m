//
//  TestCodingObj.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderFunctionInfo.h"

#define kCEJsonObjectKey_functionID @"functionID"
#define kCEJsonObjectKey_functionContent @"functionContent"
#define kCEJsonObjectKey_linkFunctionDict @"linkFunctionDict"


@implementation CEShaderFunctionInfo

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _functionID = jsonDict[kCEJsonObjectKey_functionID];
        _functionContent = jsonDict[kCEJsonObjectKey_functionContent];
        _linkFunctionDict = jsonDict[kCEJsonObjectKey_linkFunctionDict];
    }
    return self;
}


- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_functionID.length) {
        dict[kCEJsonObjectKey_functionID] = _functionID;
    }
    if (_functionContent.length) {
        dict[kCEJsonObjectKey_functionContent] = _functionContent;
    }
    if (_linkFunctionDict.count) {
        dict[kCEJsonObjectKey_linkFunctionDict] = _linkFunctionDict;
    }
    return [dict copy];
}


@end

