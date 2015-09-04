//
//  CEShaderBuilder.m
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderBuilder.h"
#import "CEShaderProfile.h"
#import "CEShaderVariable_privates.h"
#import "CEShaderBuildProfileResult.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "CEUtils.h"
#else
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
    
    // add test function profile and test
    CEShaderProfile *profile = [self shaderProfileWithName:@"BaseLightEffect.vert"];
    _vertexProfileDict[profile.function.functionID] = profile;
    profile = [self shaderProfileWithName:@"PointLightFunciton.vert"];
    _vertexProfileDict[profile.function.functionID] = profile;
    
    profile = [self shaderProfileWithName:@"BaseLightEffect.frag"];
    _fragmentProfileDict[profile.function.functionID] = profile;
    
    profile = [self shaderProfileWithName:@"TestFunction1.vert"];
    _vertexProfileDict[profile.function.functionID] = profile;
    profile = [self shaderProfileWithName:@"TestFunction2.vert"];
    _vertexProfileDict[profile.function.functionID] = profile;
    profile = [self shaderProfileWithName:@"TestFunction3.vert"];
    _vertexProfileDict[profile.function.functionID] = profile;
}


- (CEShaderInfo *)build {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    CEShaderProfile *mainVertexProfile = [self shaderProfileWithName:@"Main.vert"];
    CEShaderProfile *mainFragmentProfile = [self shaderProfileWithName:@"Main.frag"];
    if (!mainVertexProfile || !mainFragmentProfile) {
        return nil;
    }
    
    NSMutableSet *outputVariables = [NSMutableSet set];
    
    // build vertex shader
    NSDictionary *vertexProfilePool = [_vertexProfileDict copy];
    CEShaderBuildProfileResult *vertexResult = [CEShaderBuildProfileResult new];
    [self buildProfile:mainVertexProfile withProfilePool:vertexProfilePool result:vertexResult];
    NSString *vertexVariableDeclaration = [self variableDeclarationStringWithProfileResult:vertexResult];
    NSString *vertexShaderString = [NSString stringWithFormat:@"%@void main() %@", vertexVariableDeclaration, vertexResult.shaderString];
    [outputVariables addObjectsFromArray:vertexResult.attributes];
    [outputVariables addObjectsFromArray:vertexResult.uniforms];
    
    // build fragment shader
    NSDictionary *fragmentProfilePool = [_fragmentProfileDict copy];
    CEShaderBuildProfileResult *fragmentResult = [CEShaderBuildProfileResult new];
    [self buildProfile:mainFragmentProfile withProfilePool:fragmentProfilePool result:fragmentResult];
    NSString *fragmentVariableDeclaration = [self variableDeclarationStringWithProfileResult:fragmentResult];
    NSString *fragmentShaderString = [NSString stringWithFormat:@"%@void main() %@", fragmentVariableDeclaration, fragmentResult.shaderString];
    [outputVariables addObjectsFromArray:fragmentResult.attributes];
    [outputVariables addObjectsFromArray:fragmentResult.uniforms];
    
    printf("================ vertexShader ================\n%s\n", [vertexShaderString UTF8String]);
    printf("================ fragmentShader ================\n%s\n", [fragmentShaderString UTF8String]);
    printf("shader build duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
    
    return nil;
}



#pragma mark - build variables

- (NSString *)variableDeclarationStringWithProfileResult:(CEShaderBuildProfileResult *)result {
    NSArray *declarationList = @[result.structs, result.attributes, result.uniforms, result.varyings];
    NSMutableString *shaderString = [NSMutableString string];
    for (int i = 0; i < declarationList.count; i++) {
        NSArray *declarations = declarationList[i];
        if (!declarations.count) {
            continue;
        }
        NSMutableSet *identifies = [NSMutableSet set];
        NSMutableSet *variableNames = [NSMutableSet set];
        for (CEShaderVariableInfo *info in declarations) {
            // remove duplicated variable declarations
            BOOL duplicatedID = [identifies containsObject:info];
            BOOL duplicatedName = [variableNames containsObject:info.name];
            if (duplicatedID && duplicatedName) {
                continue;
            } else if (!duplicatedID && duplicatedName) {
                NSAssert(false, @"Duplicated variable declaration for: %@ ", info.name);
            }
            
            [identifies addObject:info];
            [variableNames addObject:info.name];
            [shaderString appendFormat:@"%@\n", [info declarationString]];
        }
        [shaderString appendString:@"\n"];
    }
    return shaderString.copy;
}


- (CEShaderVariable *)uniformWithInfo:(CEShaderVariableInfo *)info {
    return nil;
}


- (CEShaderVariable *)attributeWithInfo:(CEShaderVariableInfo *)info {
    return nil;
}


#pragma mark - build function

- (void)buildProfile:(CEShaderProfile *)profile
     withProfilePool:(NSDictionary *)profilePool
              result:(CEShaderBuildProfileResult *)result {
    // sort variables
    for (CEShaderVariableInfo *variableInfo in profile.variables) {
        switch (variableInfo.usage) {
            case CEShaderVariableUsageAttribute:
                [result.attributes addObject:variableInfo];
                break;
            case CEShaderVariableUsageUniform:
                [result.uniforms addObject:variableInfo];
                break;
            case CEShaderVariableUsageVarying:
                [result.varyings addObject:variableInfo];
                break;
            case CEShaderVariableUsageNone:
            default:
                break;
        }
    }
    // add struct
    [result.structs addObjectsFromArray:profile.structs];
    
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
                // recursive build profile
                [self buildProfile:linkProfile withProfilePool:profilePool result:result];
                NSString *shaderString = result.shaderString;
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
                
                NSString *replaceContent = [NSString stringWithFormat:@"//%@\n%@", [functionContent substringWithRange:linkInfo.linkRange], shaderString];
                [functionContent replaceCharactersInRange:linkInfo.linkRange
                                               withString:replaceContent];
                
            } else {
                // remove link mark
                [functionContent deleteCharactersInRange:NSMakeRange(linkInfo.linkRange.location, linkInfo.linkRange.length + 1)];
//                [functionContent replaceCharactersInRange:NSMakeRange(linkInfo.linkRange.location, 1)
//                                               withString:@"//removed-"];
            }
        }
        result.shaderString = functionContent;
        
    } else {
        result.shaderString = profile.function.functionContent;
    }
}


#pragma mark - Tools


- (CEShaderProfile *)shaderProfileWithName:(NSString *)profileName {
    if (!profileName) return nil;
    
    static NSMutableDictionary *sShaderProfileCache;
    if (!sShaderProfileCache) {
        sShaderProfileCache = [NSMutableDictionary dictionary];
    }
    
    CEShaderProfile *profile = sShaderProfileCache[profileName];
    if (profile) return profile;
    
    // load from disk
    NSData *jsonData = [NSData dataWithContentsOfFile:[CEShaderDirectory() stringByAppendingFormat:@"/%@.profile", profileName]];
    if (jsonData.length) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        profile = [[CEShaderProfile alloc] initWithJsonDict:jsonDict];
        sShaderProfileCache[profileName] = profile;
    }
    return profile;
}






@end

