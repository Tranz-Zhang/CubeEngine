//
//  CEShaderFunctionInfo.m
//  CubeEngine
//
//  Created by chance on 8/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderFunctionInfo.h"
#import "CEShaderFunctionInfo_setter.h"

#define kCEJsonObjectKey_functionID @"functionID"
#define kCEJsonObjectKey_functionContent @"functionContent"
#define kCEJsonObjectKey_paramNames @"paramNames"
#define kCEJsonObjectKey_paramLocations @"paramLocations"
#define kCEJsonObjectKey_linkFunctionDict @"linkFunctionDict"


@implementation CEShaderFunctionInfo

- (instancetype)initWithJsonDict:(NSDictionary *)jsonDict {
    self = [super init];
    if (self) {
        _functionID = jsonDict[kCEJsonObjectKey_functionID];
        _functionContent = jsonDict[kCEJsonObjectKey_functionContent];
        _paramNames = jsonDict[kCEJsonObjectKey_paramNames];
        _paramLocations = jsonDict[kCEJsonObjectKey_paramLocations];
        
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        NSDictionary *linkFunctionDict = jsonDict[kCEJsonObjectKey_linkFunctionDict];
        [linkFunctionDict enumerateKeysAndObjectsUsingBlock:^(NSString *functionID, NSDictionary *dict, BOOL *stop) {
            CEShaderLinkFunctionInfo *linkFunction = [[CEShaderLinkFunctionInfo alloc] initWithJsonDict:dict];
            tempDict[functionID] = linkFunction;
        }];
        if (tempDict.count) {
            _linkFunctionDict = tempDict.copy;
        }
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
    if (_paramNames.count) {
        dict[kCEJsonObjectKey_paramNames] = _paramNames;
    }
    if (_paramLocations.count) {
        dict[kCEJsonObjectKey_paramLocations] = _paramLocations;
    }
    if (_linkFunctionDict.count) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        [_linkFunctionDict enumerateKeysAndObjectsUsingBlock:^(NSString *functionID, CEShaderLinkFunctionInfo *linkFunction, BOOL *stop) {
            tempDict[functionID] = [linkFunction jsonDict];
        }];
        dict[kCEJsonObjectKey_linkFunctionDict] = tempDict.copy;
    }
    
    return [dict copy];
}


@end

