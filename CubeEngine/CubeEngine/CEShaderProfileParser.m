//
//  CEShaderProfileParser.m
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProfileParser.h"
#import "CEShaderVariable.h"

@implementation CEShaderProfileParser

- (CEShaderProfile *)parseShaderString:(NSString *)shaderString {
    if (!shaderString.length) {
        return nil;
    }
    
    CEShaderProfile *shaderInfo = [CEShaderProfile new];
    NSMutableArray *vertexVariables = [NSMutableArray array];
    [vertexVariables addObjectsFromArray:[self parseAttributesInShader:shaderString]];
    [vertexVariables addObjectsFromArray:[self parseUnifromsInShader:shaderString]];
    [vertexVariables addObjectsFromArray:[self parseVaryingsInShader:shaderString]];
    shaderInfo.variables = vertexVariables.copy;
    shaderInfo.structs = [self parseStructDeclarationInShader:shaderString];
    NSArray *functions = [self parseFunctionsInShader:shaderString];
    shaderInfo.function = functions.count > 0 ? functions[0] : nil;
    return shaderInfo;
}


#pragma mark - parse

- (NSArray *)parseUnifromsInShader:(NSString *)shaderString {
    NSRegularExpression *regex = [self uniformRegex];
    NSArray *results = [regex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!results.count) return nil;
    
    NSMutableArray *uniforms = [NSMutableArray arrayWithCapacity:results.count];
    for (NSTextCheckingResult *result in results) {
        NSString *declaration = [shaderString substringWithRange:NSMakeRange(result.range.location, result.range.length - 1)];
        CEShaderVariableInfo *variable = [self variableInfoWithDeclaration:declaration];
        if (variable) {
            variable.usage = CEShaderVariableUsageUniform;
            [uniforms addObject:variable];
        }
    }
    return uniforms.copy;
}


- (NSArray *)parseAttributesInShader:(NSString *)shaderString {
    NSRegularExpression *regex = [self attributeRegex];
    NSArray *results = [regex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!results.count) return nil;
    
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:results.count];
    for (NSTextCheckingResult *result in results) {
        NSString *declaration = [shaderString substringWithRange:NSMakeRange(result.range.location, result.range.length - 1)];
        CEShaderVariableInfo *variable = [self variableInfoWithDeclaration:declaration];
        if (variable) {
            if (variable.type == CEShaderVariableFloat ||
                variable.type == CEShaderVariableVector2 ||
                variable.type == CEShaderVariableVector3 ||
                variable.type == CEShaderVariableVector4) {
                variable.usage = CEShaderVariableUsageAttribute;
                [attributes addObject:variable];
                
            } else {
                printf("WARNING: Unsupported attribute: %s\n", [declaration UTF8String]);
            }
        }
    }
    return attributes.copy;
}


- (NSArray *)parseVaryingsInShader:(NSString *)shaderString {
    NSRegularExpression *regex = [self varyingRegex];
    NSArray *results = [regex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!results.count) return nil;
    
    NSMutableArray *varyings = [NSMutableArray arrayWithCapacity:results.count];
    for (NSTextCheckingResult *result in results) {
        NSString *declaration = [shaderString substringWithRange:NSMakeRange(result.range.location, result.range.length - 1)];
        CEShaderVariableInfo *variable = [self variableInfoWithDeclaration:declaration];
        if (variable) {
            variable.usage = CEShaderVariableUsageVarying;
            [varyings addObject:variable];
        }
    }
    return varyings.copy;
}


// @"attribute lowp vec3 VertexNormal" -> CEShaderVariableInfo
- (CEShaderVariableInfo *)variableInfoWithDeclaration:(NSString *)declarationString {
    NSMutableArray *components = [[declarationString componentsSeparatedByString:@" "] mutableCopy];
    [components removeObject:@""];
    if (components.count < 3) {
        return nil;
    }
    CEShaderVariableInfo *variableInfo = [CEShaderVariableInfo new];
    if (components.count == 3) {
        variableInfo.precision = kCEPrecisionDefault;
        variableInfo.type = CEShaderVariableTypeFromString(components[1]);
        variableInfo.name = components[2];
        
    } else {
        variableInfo.precision = components[1];
        variableInfo.type = CEShaderVariableTypeFromString(components[2]);
        variableInfo.name = components[3];
    }
    
    if (variableInfo.type == CEShaderVariableUnknown) {
        printf("WARNING: Unknown variable type for declaration: %s\n", [declarationString UTF8String]);
        return nil;
    }
    
    return variableInfo;
}


- (NSArray *)parseStructDeclarationInShader:(NSString *)shaderString {
    NSRegularExpression *regex = [self structNameRegex];
    NSArray *results = [regex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!results.count) return nil;
    
    NSMutableArray *structDeclarations = [NSMutableArray arrayWithCapacity:results.count];
    for (NSTextCheckingResult *result in results) {
        NSRange searchRange = NSMakeRange(NSMaxRange(result.range), shaderString.length - NSMaxRange(result.range));
        NSRange resultRange = [shaderString rangeOfString:@"}" options:0 range:searchRange];
        if (resultRange.location != NSNotFound) {
            NSRange structRange = NSMakeRange(result.range.location,
                                              NSMaxRange(resultRange) - result.range.location);
            if (NSMaxRange(structRange) <= shaderString.length) {
                NSString *structString = [shaderString substringWithRange:structRange];
                [structDeclarations addObject:[structString stringByAppendingString:@";"]];
            }
        }
    }
    
    return structDeclarations.copy;
}


- (NSArray *)parseFunctionsInShader:(NSString *)shaderString {
    NSRegularExpression *regex = [self functionNameRegex];
    NSArray *results = [regex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!results.count) return nil;
    
    NSMutableArray *functionDeclarations = [NSMutableArray arrayWithCapacity:results.count];
    int bracketCount = 0;
    for (NSTextCheckingResult *result in results) {
        NSRange searchRange = NSMakeRange(NSMaxRange(result.range), shaderString.length - NSMaxRange(result.range));
        NSCharacterSet *bracketSet = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
        do {
            NSRange resultRange = [shaderString rangeOfCharacterFromSet:bracketSet options:0 range:searchRange];
            if (resultRange.location != NSNotFound) {
                NSString *bracket = [shaderString substringWithRange:resultRange];
                if ([bracket isEqualToString:@"{"]) {
                    bracketCount++;
                } else {
                    bracketCount--;
                }
                if (bracketCount >= 0) {
                    searchRange.location = NSMaxRange(resultRange);
                    searchRange.length = shaderString.length - NSMaxRange(resultRange);
                    
                } else {
                   searchRange.location = NSNotFound;
                }
                
            } else {
                searchRange.location = NSNotFound;
                bracketCount = 0;
            }
        } while (bracketCount > 0);
        
        NSString *functionContent;
        if (searchRange.location != NSNotFound) {
            NSRange functionRange = NSMakeRange(result.range.location,
                                                searchRange.location - result.range.location);
            if (NSMaxRange(functionRange) <= shaderString.length) {
                functionContent = [shaderString substringWithRange:functionRange];
            }
        }
        if (functionContent.length) {
            [functionDeclarations addObject:functionContent];
        }
    }
    
    
    // parse function declarations to CEShaderFunctionInfo
    NSMutableArray *functionInfos = [NSMutableArray array];
    for (NSString *functionContent in functionDeclarations) {
        CEShaderFunctionInfo *info = [self parseFunctionInfoWithContent:functionContent
                                                           shaderString:shaderString];
        if (info) {
            [functionInfos addObject:info];
        }
    }
    
    return functionInfos.copy;
}


- (CEShaderFunctionInfo *)parseFunctionInfoWithContent:(NSString *)functionString shaderString:(NSString *)shaderString {
    CEShaderFunctionInfo *functionInfo = [CEShaderFunctionInfo new];
    
    // get function name
    __block NSString *functionName;
    [functionString enumerateSubstringsInRange:NSMakeRange(0, 100) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (![substring isEqualToString:@"void"]) {
            functionName = substring;
            *stop = YES;
        }
    }];
    // get functionID
    NSMutableString *functionID = functionName.mutableCopy;
    NSRange startBracketRange = [functionString rangeOfString:@"("];
    NSRange endBracketRange = [functionString rangeOfString:@")"];
    NSString *paramString = [functionString substringWithRange:NSMakeRange(NSMaxRange(startBracketRange), endBracketRange.location - NSMaxRange(startBracketRange))];
    NSArray *params = [paramString componentsSeparatedByString:@","];
    for (NSString *paramDeclaration in params) {
        NSString *paramID = [self getParamID:paramDeclaration];
        if (paramID.length) {
            [functionID appendFormat:@"_%@", paramID];
        }
    }
    functionInfo.functionID = functionID.copy;
    
    // get function paramNames
    NSMutableArray *paramNames = [NSMutableArray array];
    for (NSString *paramDeclaration in params) {
        NSString *paramName = [self getParamName:paramDeclaration];
        if (paramName.length) {
            [paramNames addObject:paramName];
        }
    }
    functionInfo.paramNames = paramNames.copy;
    
    // get function content
    startBracketRange = [functionString rangeOfString:@"{"];
    endBracketRange = [functionString rangeOfString:@"}" options:NSBackwardsSearch];
    NSString *content;
    if (startBracketRange.location != NSNotFound &&
        endBracketRange.location != NSNotFound) {
        content = [functionString substringWithRange:NSMakeRange(startBracketRange.location, NSMaxRange(endBracketRange) - startBracketRange.location)];
    }
    if (!content.length) {
        return nil;
    }
    functionInfo.functionContent = content;
    
    // get function paramLocations
    NSMutableArray *paramLocations = [NSMutableArray arrayWithCapacity:paramNames.count];
    for (NSString *paramName in paramNames) {
        NSMutableArray *locations = [NSMutableArray array];
        [content enumerateSubstringsInRange:NSMakeRange(0, content.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            if ([substring isEqualToString:paramName]) {
                [locations addObject:NSStringFromRange(substringRange)];
            }
        }];
        [paramLocations addObject:locations.copy];
    }
    functionInfo.paramLocations = paramLocations.copy;
    
    // get link function info
    NSMutableDictionary *linkFunctionDict = [NSMutableDictionary dictionary];
    NSRegularExpression *linkFunctionRegex = [self linkFunctionRegex];
    NSArray *results = [linkFunctionRegex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    for (NSTextCheckingResult *result in results) {
        NSString *linkDecleration = [content substringWithRange:result.range];
        // get function name
        NSRange startBracketRange = [linkDecleration rangeOfString:@"("];
        if (startBracketRange.location == NSNotFound) continue;
        NSString *functionName = [linkDecleration substringWithRange:NSMakeRange(5, startBracketRange.location - 5)];
        functionName = [functionName stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        // get function params
        NSMutableString *linkFunctionID = [functionName mutableCopy];
        NSRange endBracketRange = [linkDecleration rangeOfString:@")" options:NSBackwardsSearch];
        if (endBracketRange.location == NSNotFound) continue;
        NSString *paramContent = [linkDecleration substringWithRange:NSMakeRange(NSMaxRange(startBracketRange), endBracketRange.location - NSMaxRange(startBracketRange))];
        paramContent = [paramContent stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *params = [paramContent componentsSeparatedByString:@","];
        for (NSString *param in params) {
            if (!param.length) continue;
            NSString *regexPattern = [NSString stringWithFormat:@"\\w+\\s+%@(\\s*\\[\\w\\]|)", param];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:nil];
            NSTextCheckingResult *result = [regex firstMatchInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
            if (result && result.range.location != NSNotFound) {
                NSString *paramDeclaration = [shaderString substringWithRange:result.range];
                NSString *paramID = [self getParamID:paramDeclaration];
                if (paramID.length) {
                    [linkFunctionID appendFormat:@"_%@", paramID];
                }
            }
        }
        CEShaderLinkFunctionInfo *linkFunctionInfo = [CEShaderLinkFunctionInfo new];
        linkFunctionInfo.functionID = linkFunctionID;
        linkFunctionInfo.paramNames = params;
        linkFunctionInfo.linkRange = result.range;
        linkFunctionDict[linkFunctionID] = linkFunctionInfo;
    }
    functionInfo.linkFunctionDict = linkFunctionDict.copy;
    
    return functionInfo;
}

#pragma mark - assist mothods

- (NSString *)getParamID:(NSString *)paramDeclaration {
    if (!paramDeclaration.length) {
        return nil;
    }
    
    NSArray *words = [paramDeclaration componentsSeparatedByString:@" "];
    NSString *paramType;
    for (NSString *word in words) {
        if (word.length && !paramType) {
            paramType = word;
        }
    }
    
    // check array
    NSRange startBracketRange = [paramDeclaration rangeOfString:@"["];
    NSRange endBracketRange = [paramDeclaration rangeOfString:@"]"];
    NSString *arrayCount = nil;
    if (startBracketRange.location != NSNotFound &&
        endBracketRange.location != NSNotFound) {
        arrayCount = [paramDeclaration substringWithRange:NSMakeRange(NSMaxRange(startBracketRange), endBracketRange.location - NSMaxRange(startBracketRange))];
    }
    
    if (arrayCount) {
        return [NSString stringWithFormat:@"%@x%@", paramType, arrayCount];
        
    } else {
        return [NSString stringWithFormat:@"%@", paramType];
    }
}


- (NSString *)getParamName:(NSString *)paramDeclaration {
    __block BOOL passParamType = NO;
    __block NSString *paramName;
    [paramDeclaration enumerateSubstringsInRange:NSMakeRange(0, paramDeclaration.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (substring.length) {
            if (!passParamType) {
                passParamType = YES;
            } else {
                paramName = substring;
                *stop = YES;
            }
        }
    }];
    
    return paramName;
}


#pragma mark - Regex

- (NSRegularExpression *)uniformRegex {
    static NSRegularExpression *sUniformRegex = nil;
    if (!sUniformRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sUniformRegex = [NSRegularExpression regularExpressionWithPattern:@"uniform\\s*(\\w*\\s*){1,2}\\w*;" options:0 error:nil];
        });
    }
    return sUniformRegex;
}


- (NSRegularExpression *)attributeRegex {
    static NSRegularExpression *sAttributeRegex = nil;
    if (!sAttributeRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sAttributeRegex = [NSRegularExpression regularExpressionWithPattern:@"attribute\\s*(\\w*\\s*){1,2}\\w*;" options:0 error:nil];
        });
    }
    return sAttributeRegex;
}


- (NSRegularExpression *)varyingRegex {
    static NSRegularExpression *sVaryingRegex = nil;
    if (!sVaryingRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sVaryingRegex = [NSRegularExpression regularExpressionWithPattern:@"varying\\s*(\\w*\\s*){1,2}\\w*;" options:0 error:nil];
        });
    }
    return sVaryingRegex;
}


- (NSRegularExpression *)structNameRegex {
    static NSRegularExpression *sStructNameRegex = nil;
    if (!sStructNameRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sStructNameRegex = [NSRegularExpression regularExpressionWithPattern:@"struct\\s*\\w*" options:0 error:nil];
        });
    }
    return sStructNameRegex;
}


- (NSRegularExpression *)functionNameRegex {
    static NSRegularExpression *sFunctionNameRegex = nil;
    if (!sFunctionNameRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sFunctionNameRegex = [NSRegularExpression regularExpressionWithPattern:@"void\\s*\\w*\\s*\\(.*\\)" options:0 error:nil];
        });
    }
    return sFunctionNameRegex;
}


- (NSRegularExpression *)linkFunctionRegex {
    static NSRegularExpression *sLinkFunctionRegex = nil;
    if (!sLinkFunctionRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sLinkFunctionRegex = [NSRegularExpression regularExpressionWithPattern:@"#link\\s\\w*\\(.*\\)(;|)" options:0 error:nil];
        });
    }
    return sLinkFunctionRegex;
}


@end





