//
//  CEShaderProfileParser.m
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderProfileParser.h"
//#import "CEShaderVariable.h"
#import "CEShaderVariableInfo_setter.h"
#import "CEShaderStructInfo_setter.h"
#import "CEShaderProfile__setter.h"
#import "CEShaderFunctionInfo_setter.h"
#import "CEShaderLinkFunctionInfo_setter.h"
#import "CEShaderUniformDefines.h"


@implementation CEShaderProfileParser

- (CEShaderProfile *)parseShaderString:(NSString *)shaderString {
    if (!shaderString.length) {
        return nil;
    }
    
    // remove comment
    NSString *shaderContent = [self removeCommentLinesInString:shaderString];
    // remove empty lines
    shaderContent = [self removeEmptyLinesInString:shaderContent];
    
    CEShaderProfile *shaderInfo = [CEShaderProfile new];
    NSMutableArray *vertexVariables = [NSMutableArray array];
    [vertexVariables addObjectsFromArray:[self parseAttributesInShader:shaderContent]];
    [vertexVariables addObjectsFromArray:[self parseUnifromsInShader:shaderContent]];
    [vertexVariables addObjectsFromArray:[self parseVaryingsInShader:shaderContent]];
    shaderInfo.variables = vertexVariables.copy;
    shaderInfo.structs = [self parseStructDeclarationInShader:shaderContent];
    NSArray *functions = [self parseFunctionsInShader:shaderContent];
    shaderInfo.function = functions.count > 0 ? functions[0] : nil;
    shaderInfo.defaultPrecision = [self parseDefaultPrecision:shaderContent];
    return shaderInfo;
}


#pragma mark - parse
- (NSString *)parseDefaultPrecision:(NSString *)shaderString {
    NSRegularExpression *regex = [self uniformRegex];
    NSTextCheckingResult *result = [regex firstMatchInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!result) {
        return nil;
    }
    NSString *precisionString = [shaderString substringWithRange:result.range];
    NSMutableArray *components = [[precisionString componentsSeparatedByString:@" "] mutableCopy];
    [components removeObject:@""];
    return components.count > 2 ? components[1] : nil;
}


- (NSArray *)parseUnifromsInShader:(NSString *)shaderString {
    NSRegularExpression *regex = [self uniformRegex];
    NSArray *results = [regex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!results.count) return nil;
    
    NSMutableArray *uniforms = [NSMutableArray arrayWithCapacity:results.count];
    for (NSTextCheckingResult *result in results) {
        NSString *declaration = [shaderString substringWithRange:NSMakeRange(result.range.location, result.range.length - 1)];
        CEShaderVariableInfo *variable = [self variableInfoWithDeclaration:declaration];
        if (variable) {
//            variable.usage = CEShaderVariableUsageUniform;
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
            if ([variable.type isEqualToString:@"float"] ||
                [variable.type isEqualToString:@"vec2"] ||
                [variable.type isEqualToString:@"vec3"] ||
                [variable.type isEqualToString:@"vec4"]) {
//                variable.usage = CEShaderVariableUsageAttribute;
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
//            variable.usage = CEShaderVariableUsageVarying;
            [varyings addObject:variable];
        }
    }
    return varyings.copy;
}


- (NSArray *)parseStructDeclarationInShader:(NSString *)shaderString {
    NSRegularExpression *regex = [self structNameRegex];
    NSArray *results = [regex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!results.count) return nil;
    
    NSMutableDictionary *structDict = [NSMutableDictionary dictionaryWithCapacity:results.count];
    for (NSTextCheckingResult *result in results) {
        NSRange searchRange = NSMakeRange(NSMaxRange(result.range), shaderString.length - NSMaxRange(result.range));
        NSRange resultRange = [shaderString rangeOfString:@"}" options:0 range:searchRange];
        if (resultRange.location != NSNotFound) {
            NSRange structRange = NSMakeRange(result.range.location,
                                              NSMaxRange(resultRange) - result.range.location);
            if (NSMaxRange(structRange) <= shaderString.length) {
                NSString *structString = [shaderString substringWithRange:structRange];
                // get sturct name
                NSString *structHeader = [shaderString substringWithRange:result.range];
                NSArray *headerComponents = [structHeader componentsSeparatedByString:@" "];
                NSString *structName = headerComponents.lastObject;
                if (structString.length && structName.length) {
                    structDict[structName] = [structString stringByAppendingString:@";"];
                }
            }
        }
    }
    
    // parse struct decaration to CEShaderStructInfo
    NSMutableArray *structInfos = [NSMutableArray arrayWithCapacity:structDict.count];
    [structDict enumerateKeysAndObjectsUsingBlock:^(NSString *structName, NSString *structString, BOOL *stop) {
        // parse struct variables
        NSRegularExpression *regex = [self structVariableRegex];
        NSArray *results = [regex matchesInString:structString options:0 range:NSMakeRange(0, structString.length)];
        NSMutableArray *variableInfos = [NSMutableArray arrayWithCapacity:results.count];
        for (NSTextCheckingResult *result in results) {
            NSString *variableDeclaration = [structString substringWithRange:NSMakeRange(result.range.location, result.range.length - 1)];
            CEShaderVariableInfo *info = [self variableInfoWithDeclaration:variableDeclaration];
            if (info) {
                [variableInfos addObject:info];
            }
        }
        
        CEShaderStructInfo *structInfo = [CEShaderStructInfo new];
        structInfo.name = structName;
        structInfo.variables = variableInfos.copy;
        // calculate hash value
        NSMutableString *hashString = [NSMutableString stringWithFormat:@"%@:", structName];
        for (CEShaderVariableInfo *variableInfo in variableInfos) {
            [hashString appendFormat:@"%d_%@_%@_%@_%d;", (int)variableInfo.usage, variableInfo.precision,
             variableInfo.type, variableInfo.name, variableInfo.arrayItemCount];
        }
        structInfo.structID = HashValueWithString(hashString);
        [structInfos addObject:structInfo];
    }];
    
    return structInfos.copy;
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
    [functionString enumerateSubstringsInRange:NSMakeRange(0, MIN(100, functionString.length)) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (![substring isEqualToString:@"void"]) {
            functionName = substring;
            *stop = YES;
        }
    }];
    
    // get functionID
    NSRange startBracketRange = [functionString rangeOfString:@"("];
    NSRange endBracketRange = [functionString rangeOfString:@")"];
    NSString *paramString = [functionString substringWithRange:NSMakeRange(NSMaxRange(startBracketRange), endBracketRange.location - NSMaxRange(startBracketRange))];
    NSArray *params = [paramString componentsSeparatedByString:@","];
    NSMutableArray *paramIDs = [NSMutableArray arrayWithCapacity:params.count];
    for (NSString *paramDeclaration in params) {
        NSString *paramID = [self getParamID:paramDeclaration];
        if (paramID.length) {
            [paramIDs addObject:paramID];
        }
    }
    NSMutableString *functionID = functionName.mutableCopy;
    [functionID appendFormat:@"(%@)", [paramIDs componentsJoinedByString:@","]];
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
        NSString *linkFunctionName = [linkDecleration substringWithRange:NSMakeRange(5, startBracketRange.location - 5)];
        linkFunctionName = [linkFunctionName stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        // get function params
        NSRange endBracketRange = [linkDecleration rangeOfString:@")" options:NSBackwardsSearch];
        if (endBracketRange.location == NSNotFound) continue;
        NSString *paramContent = [linkDecleration substringWithRange:NSMakeRange(NSMaxRange(startBracketRange), endBracketRange.location - NSMaxRange(startBracketRange))];
        paramContent = [paramContent stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSMutableArray *params = [[paramContent componentsSeparatedByString:@","] mutableCopy];
        [params removeObject:@""];
        NSMutableArray *paramIDs = [NSMutableArray arrayWithCapacity:params.count];
        for (NSString *param in params) {
            if (!param.length) continue;
            NSString *regexPattern = [NSString stringWithFormat:@"\\w+\\s+\\b%@\\b(\\s*\\[\\d\\]|)", param];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:nil];
            NSTextCheckingResult *result = [regex firstMatchInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
            if (result && result.range.location != NSNotFound) {
                NSString *paramDeclaration = [shaderString substringWithRange:result.range];
                NSString *paramID = [self getParamID:paramDeclaration];
                if (paramID.length) {
                    [paramIDs addObject:paramID];
                }
            }
        }
        
        NSMutableString *linkFunctionID = linkFunctionName.mutableCopy;
        [linkFunctionID appendFormat:@"(%@)", [paramIDs componentsJoinedByString:@","]];
        CEShaderLinkFunctionInfo *linkFunctionInfo = [CEShaderLinkFunctionInfo new];
        linkFunctionInfo.functionID = linkFunctionID.copy;
        linkFunctionInfo.paramNames = params.count ? params : nil;
        linkFunctionInfo.linkRange = result.range;
        linkFunctionDict[linkFunctionInfo.functionID] = linkFunctionInfo;
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


// @"attribute lowp vec3 VertexNormal" -> CEShaderVariableInfo
- (CEShaderVariableInfo *)variableInfoWithDeclaration:(NSString *)declarationString {
    if (!declarationString.length) return nil;
    
    // check '[' and ']'
    NSRange startBracketRange = [declarationString rangeOfString:@"["];
    NSRange endBracketRange = [declarationString rangeOfString:@"]"];
    NSAssert((startBracketRange.location == NSNotFound && endBracketRange.location == NSNotFound) ||
             (startBracketRange.location != NSNotFound && endBracketRange.location != NSNotFound),
             @"Wrong bracket match");
    int arrayItemCount = 1;
    NSString *parsingString = declarationString;
    if (startBracketRange.location != NSNotFound &&
        endBracketRange.location != NSNotFound) {
        NSString *countString = [declarationString substringWithRange:NSMakeRange(NSMaxRange(startBracketRange), endBracketRange.location - NSMaxRange(startBracketRange))];
        arrayItemCount = countString.intValue;
        NSAssert(arrayItemCount >= 1, @"Error array item count");
        parsingString = [declarationString substringToIndex:startBracketRange.location];
    
    } else if ([parsingString hasSuffix:@";"]) {
        parsingString = [parsingString substringToIndex:parsingString.length - 1];
    }
    
    NSMutableArray *components = [[parsingString componentsSeparatedByString:@" "] mutableCopy];
    [components removeObject:@""];
    
    CEShaderVariableUsage usage = CEShaderVariableUsageFromString(components[0]);
    if ((usage == CEShaderVariableUsageNone && components.count < 2) ||
        (usage != CEShaderVariableUsageNone && components.count < 3)) {
        return nil;
    }
    
    CEShaderVariableInfo *variableInfo = [CEShaderVariableInfo new];
    variableInfo.usage = usage;
    
    if (usage != CEShaderVariableUsageNone) {
        // attribute uniform varying variables
        if (components.count == 3) {
            variableInfo.precision = kCEPrecisionDefault;
            variableInfo.type = components[1];
            variableInfo.name = components[2];
            
        } else {
            variableInfo.precision = components[1];
            variableInfo.type = components[2];
            variableInfo.name = components[3];
        }
        
    } else {
        // normal variable
        if (components.count == 2) {
            variableInfo.precision = kCEPrecisionDefault;
            variableInfo.type = components[0];
            variableInfo.name = components[1];
            
        } else {
            variableInfo.precision = components[0];
            variableInfo.type = components[1];
            variableInfo.name = components[2];
        }
    }
    if (![variableInfo.type hasPrefix:@"int"] &&
        ![variableInfo.type hasPrefix:@"float"] &&
        ![variableInfo.type hasPrefix:@"vec"] &&
        ![variableInfo.type hasPrefix:@"mat"]) {
        variableInfo.precision = nil;
    }
    NSString *hashString = [NSString stringWithFormat:@"%d_%@_%@_%@", (int)variableInfo.usage, variableInfo.precision,
                            variableInfo.type, variableInfo.name];
    variableInfo.variableID = HashValueWithString(hashString);
    variableInfo.arrayItemCount = arrayItemCount;
    return variableInfo;
}



- (NSString *)removeEmptyLinesInString:(NSString *)string {
    NSRegularExpression *regex = [self emptyLineRegex];
    NSArray *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSMutableString *mutableContent = string.mutableCopy;
    [results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
        [mutableContent replaceCharactersInRange:result.range withString:@"\n"];
    }];
    if ([mutableContent hasPrefix:@"\n"]) {
        [mutableContent deleteCharactersInRange:NSMakeRange(0, [@"\n" length])];
    }
    return mutableContent.copy;
}


- (NSString *)removeCommentLinesInString:(NSString *)string {
    NSRegularExpression *regex = [self commentRegex];
    NSArray *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSMutableString *mutableContent = string.mutableCopy;
    [results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
        [mutableContent deleteCharactersInRange:result.range];
    }];
    return mutableContent.copy;
}


#pragma mark - Regex

- (NSRegularExpression *)uniformRegex {
    static NSRegularExpression *sUniformRegex = nil;
    if (!sUniformRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sUniformRegex = [NSRegularExpression regularExpressionWithPattern:@"uniform\\s+(\\w+\\s+){1,2}\\w+(\\s*\\[\\d\\]|);" options:0 error:nil];
        });
    }
    return sUniformRegex;
}


- (NSRegularExpression *)attributeRegex {
    static NSRegularExpression *sAttributeRegex = nil;
    if (!sAttributeRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sAttributeRegex = [NSRegularExpression regularExpressionWithPattern:@"attribute\\s+(\\w+\\s+){1,2}\\w+(\\s*\\[\\d\\]|);" options:0 error:nil];
        });
    }
    return sAttributeRegex;
}


- (NSRegularExpression *)varyingRegex {
    static NSRegularExpression *sVaryingRegex = nil;
    if (!sVaryingRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sVaryingRegex = [NSRegularExpression regularExpressionWithPattern:@"varying\\s+(\\w+\\s+){1,2}\\w+(\\s*\\[\\d\\]|);" options:0 error:nil];
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


- (NSRegularExpression *)structVariableRegex {
    static NSRegularExpression *sStructVariableRegex = nil;
    if (!sStructVariableRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sStructVariableRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\w+\\s+)?(vec\\d|float|mat\\d|int|bool)\\s\\w+(\\s*\\[\\d\\]|);" options:0 error:nil];
        });
    }
    return sStructVariableRegex;
}


- (NSRegularExpression *)functionNameRegex {
    static NSRegularExpression *sFunctionNameRegex = nil;
    if (!sFunctionNameRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sFunctionNameRegex = [NSRegularExpression regularExpressionWithPattern:@"void\\s+\\w+\\s*\\(.*\\)" options:0 error:nil];
        });
    }
    return sFunctionNameRegex;
}


- (NSRegularExpression *)linkFunctionRegex {
    static NSRegularExpression *sLinkFunctionRegex = nil;
    if (!sLinkFunctionRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sLinkFunctionRegex = [NSRegularExpression regularExpressionWithPattern:@"#link\\s+\\w+\\(.*\\)(;|)" options:0 error:nil];
        });
    }
    return sLinkFunctionRegex;
}


- (NSRegularExpression *)emptyLineRegex {
    static NSRegularExpression *sEmptyLineRegex = nil;
    if (!sEmptyLineRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sEmptyLineRegex = [NSRegularExpression regularExpressionWithPattern:@"\\n\\s*\\n" options:0 error:nil];
        });
    }
    return sEmptyLineRegex;
}


- (NSRegularExpression *)commentRegex {
    static NSRegularExpression *sCommentRegex = nil;
    if (!sCommentRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sCommentRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\/\\/[^\\n]*)|(\\/\\*(\\s|.)*?\\*\\/)" options:0 error:nil];
        });
    }
    return sCommentRegex;
}


// precision mediump float;
- (NSRegularExpression *)defaultPrecisionRegex {
    static NSRegularExpression *sDefaultPrecisionRegex = nil;
    if (!sDefaultPrecisionRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sDefaultPrecisionRegex = [NSRegularExpression regularExpressionWithPattern:@"precision\\s+\\w+\\s+float;" options:0 error:nil];
        });
    }
    return sDefaultPrecisionRegex;
}



@end





