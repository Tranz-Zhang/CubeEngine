//
//  CEShaderBuilder.m
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderBuilder.h"
#import "CEShaderProfile.h"

#if TARGET_OS_IPHONE
#import "CEUtils.h"
#endif

#if TARGET_OS_MAC
NSString *CEShaderDirectory() {
    return @"/Users/chance/My Development/cube-engine/CubeEngine/BuildTool/Debug.app/Engine/ShaderProfiles";
}
#endif


@implementation CEShaderBuilder {
    NSMutableDictionary *_vertexProfileDict;
    NSMutableDictionary *_fragmentProfileDict;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _vertexProfileDict = [NSMutableDictionary dictionary];
        _fragmentProfileDict = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)startBuildingNewShader {
    [_vertexProfileDict removeAllObjects];
    [_fragmentProfileDict removeAllObjects];
    
    // add main profile
    CEShaderProfile *mainVertexProfile = [self shaderProfileWithName:@"Main.vert.profile"];
    if (mainVertexProfile) {
        _vertexProfileDict[mainVertexProfile.function.functionID] = mainVertexProfile;
    }
    CEShaderProfile *mainFragmentProfile = [self shaderProfileWithName:@"Main.frag.profile"];
    if (mainFragmentProfile) {
        _fragmentProfileDict[mainFragmentProfile.function.functionID] = mainFragmentProfile;
    }
    
    // add test function profile and test
    CEShaderProfile *test1 = [self shaderProfileWithName:@"TestFunction1.vert.profile"];
    _vertexProfileDict[test1.function.functionID] = test1;
    CEShaderProfile *test2 = [self shaderProfileWithName:@"TestFunction2.vert.profile"];
    _vertexProfileDict[test2.function.functionID] = test2;
    CEShaderProfile *test3 = [self shaderProfileWithName:@"TestFunction3.vert.profile"];
    _vertexProfileDict[test3.function.functionID] = test3;
}


- (CEShaderBuildResult *)build {
    
    NSDictionary *vertexProfilePool = [_vertexProfileDict copy];
    CEShaderProfile *vertexMainProfile = vertexProfilePool[@"main"];
    
    NSMutableArray *attributes = [NSMutableArray array];
    NSMutableArray *uniforms = [NSMutableArray array];
    NSMutableArray *varyings = [NSMutableArray array];
    NSMutableArray *structs = [NSMutableArray array];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    NSString *vertexShader = [self buildShaderWithProfile:vertexMainProfile
                                              profilePool:vertexProfilePool
                                                  structs:structs
                                               attributes:attributes
                                                 uniforms:uniforms
                                                 varyings:varyings];
    printf("Resut:\n%s\n\nbuild duration: %.5f\n", [vertexShader UTF8String], CFAbsoluteTimeGetCurrent() - startTime);
    return nil;
}


- (NSString *)buildShaderWithProfile:(CEShaderProfile *)profile
                         profilePool:(NSDictionary *)profilePool
                             structs:(NSMutableArray *)structs
                          attributes:(NSMutableArray *)attributes
                            uniforms:(NSMutableArray *)uniforms
                            varyings:(NSMutableArray *)varyings {
    // sort variables
    for (CEShaderVariableInfo *variableInfo in profile.variables) {
        switch (variableInfo.usage) {
            case CEShaderVariableUsageAttribute:
                [attributes addObject:variableInfo];
                break;
            case CEShaderVariableUsageUniform:
                [uniforms addObject:variableInfo];
                break;
            case CEShaderVariableUsageVarying:
                [varyings addObject:variableInfo];
                break;
            case CEShaderVariableUsageNone:
            default:
                break;
        }
    }
    // add struct
    [structs addObjectsFromArray:profile.structs];
    
    if (profile.function.linkFunctionDict.count) {
        // sort link functionIDs by their range in descend
        NSArray *allIDs = profile.function.linkFunctionDict.allKeys;
        NSArray *linkFunctionIDs = [allIDs sortedArrayUsingComparator:^NSComparisonResult(NSString *id1, NSString *id2) {
            CEShaderLinkFunctionInfo *linkInfo1 = profile.function.linkFunctionDict[id1];
            CEShaderLinkFunctionInfo *linkInfo2 = profile.function.linkFunctionDict[id2];
            return NSMaxRange(linkInfo2.linkRange) - NSMaxRange((linkInfo1.linkRange));
        }];
        // link functions
        NSMutableString *functionContent = [profile.function.functionContent mutableCopy];
        for (NSString *functionID in linkFunctionIDs) {
            // check if there's function to link
            CEShaderProfile *linkProfile = profilePool[functionID];
            CEShaderLinkFunctionInfo *linkInfo = profile.function.linkFunctionDict[functionID];
            if (linkProfile && linkProfile.function.paramNames.count == linkInfo.paramNames.count) {
                NSString *shaderString = [self buildShaderWithProfile:linkProfile
                                                          profilePool:profilePool
                                                              structs:structs
                                                           attributes:attributes
                                                             uniforms:uniforms
                                                             varyings:varyings];
                // check param name to keep the function context consistent
                NSMutableDictionary *replaceLocationDict = [NSMutableDictionary dictionary];
                for (int i = 0; i < linkInfo.paramNames.count; i++) {
                    NSString *inputParam = linkInfo.paramNames[i];
                    NSString *functionParam = linkProfile.function.paramNames[i];
                    if (![inputParam isEqualToString:functionParam]) {
                        NSMutableArray *locations = [NSMutableArray array];
                        [shaderString enumerateSubstringsInRange:NSMakeRange(0, shaderString.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                            if ([substring isEqualToString:functionParam]) {
                                [locations insertObject:NSStringFromRange(substringRange) atIndex:0];
                            }
                        }];
                        replaceLocationDict[inputParam] = locations.copy;
                    }
                }
                if (replaceLocationDict.count) {
                    NSMutableString *tempContent = shaderString.mutableCopy;
                    [replaceLocationDict enumerateKeysAndObjectsUsingBlock:^(NSString *replaceParam, NSArray *locations, BOOL *stop) {
                        for (NSString *rangeString in locations) {
                            NSRange replaceRange = NSRangeFromString(rangeString);
                            [tempContent replaceCharactersInRange:replaceRange withString:replaceParam];
                        }
                    }];
                    shaderString = tempContent.copy;
                }
                
                NSString *replaceContent = [NSString stringWithFormat:@"//Link: %@\n%@", functionID, shaderString];
                [functionContent replaceCharactersInRange:linkInfo.linkRange
                                               withString:replaceContent];
                
            } else {
                // remove link mark
                [functionContent replaceCharactersInRange:NSMakeRange(linkInfo.linkRange.location, 1)
                                               withString:@"//removed-"];
//                [functionContent deleteCharactersInRange:linkRange];
            }
        }
        
        return [functionContent copy];
        
    } else {
        return profile.function.functionContent;
    }
}


- (CEShaderProfile *)shaderProfileWithName:(NSString *)profileName {
    if (!profileName) return nil;
    
    static NSMutableDictionary *sShaderProfileCache;
    if (!sShaderProfileCache) {
        sShaderProfileCache = [NSMutableDictionary dictionary];
    }
    
    CEShaderProfile *profile = sShaderProfileCache[profileName];
    if (profile) return profile;
    
    // load from disk
    NSData *jsonData = [NSData dataWithContentsOfFile:[CEShaderDirectory() stringByAppendingPathComponent:profileName]];
    if (jsonData.length) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        profile = [[CEShaderProfile alloc] initWithJsonDict:jsonDict];
        sShaderProfileCache[profileName] = profile;
    }
    return profile;
}




@end

