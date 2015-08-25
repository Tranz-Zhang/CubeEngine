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

- (CEShaderProfile *)parseWithVertexShader:(NSString *)vertexShaderString
                             fragmentShader:(NSString *)fragmentShaderString {
    
    CEShaderProfile *shaderInfo = [CEShaderProfile new];
    
    // parse vertex shader
    if (vertexShaderString.length) {
        NSMutableArray *vertexVariables = [NSMutableArray array];
        [vertexVariables addObjectsFromArray:[self parseAttributesInShader:vertexShaderString]];
        [vertexVariables addObjectsFromArray:[self parseUnifromsInShader:vertexShaderString]];
        [vertexVariables addObjectsFromArray:[self parseVaryingsInShader:vertexShaderString]];
        shaderInfo.vertexShaderVariables = vertexVariables.copy;
        shaderInfo.vertexShaderStructs = [self parseStructDeclarationInShader:vertexShaderString];
        shaderInfo.vertexShaderFunctions = [self parseFunctionsInShader:vertexShaderString];
    }
    
    // parse fragment shader
    if (fragmentShaderString) {
        NSMutableArray *fragmentVariables = [NSMutableArray array];
        [fragmentVariables addObjectsFromArray:[self parseAttributesInShader:fragmentShaderString]];
        [fragmentVariables addObjectsFromArray:[self parseUnifromsInShader:fragmentShaderString]];
        [fragmentVariables addObjectsFromArray:[self parseVaryingsInShader:fragmentShaderString]];
        shaderInfo.fragmentShaderVariables = fragmentVariables.copy;
        shaderInfo.fragmentShaderStructs = [self parseStructDeclarationInShader:fragmentShaderString];
        shaderInfo.fragmentShaderFunctions = [self parseFunctionsInShader:fragmentShaderString];
    }
    
    return shaderInfo;
}


#pragma mark - parse

- (NSArray *)parseUnifromsInShader:(NSString *)shaderString {
    static NSRegularExpression *sUniformRegex = nil;
    if (!sUniformRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sUniformRegex = [NSRegularExpression regularExpressionWithPattern:@"uniform\\s*(\\w*\\s*){1,2}\\w*;" options:0 error:nil];
        });
    }
    NSArray *results = [sUniformRegex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
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
    static NSRegularExpression *sAttributeRegex = nil;
    if (!sAttributeRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sAttributeRegex = [NSRegularExpression regularExpressionWithPattern:@"attribute\\s*(\\w*\\s*){1,2}\\w*;" options:0 error:nil];
        });
    }
    NSArray *results = [sAttributeRegex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
    if (!results.count) return nil;
    
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:results.count];
    for (NSTextCheckingResult *result in results) {
        NSString *declaration = [shaderString substringWithRange:NSMakeRange(result.range.location, result.range.length - 1)];
        CEShaderVariableInfo *variable = [self variableInfoWithDeclaration:declaration];
        if (variable) {
            variable.usage = CEShaderVariableUsageAttribute;
            [attributes addObject:variable];
        }
    }
    return attributes.copy;
}


- (NSArray *)parseVaryingsInShader:(NSString *)shaderString {
    static NSRegularExpression *sVaryingRegex = nil;
    if (!sVaryingRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sVaryingRegex = [NSRegularExpression regularExpressionWithPattern:@"varying\\s*(\\w*\\s*){1,2}\\w*;" options:0 error:nil];
        });
    }
    NSArray *results = [sVaryingRegex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
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
        variableInfo.type = components[1];
        variableInfo.name = components[2];
        
    } else {
        variableInfo.precision = components[1];
        variableInfo.type = components[2];
        variableInfo.name = components[3];
    }
    return variableInfo;
}


- (NSArray *)parseStructDeclarationInShader:(NSString *)shaderString {
    static NSRegularExpression *sStructNameRegex = nil;
    if (!sStructNameRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sStructNameRegex = [NSRegularExpression regularExpressionWithPattern:@"struct\\s*\\w*" options:0 error:nil];
        });
    }
    NSArray *results = [sStructNameRegex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
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
    
    return [structDeclarations copy];
}


- (NSArray *)parseFunctionsInShader:(NSString *)shaderString {
    static NSRegularExpression *sFunctionNameRegex = nil;
    if (!sFunctionNameRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sFunctionNameRegex = [NSRegularExpression regularExpressionWithPattern:@"void\\s*\\w*\\s*\\(.*\\)" options:0 error:nil];
        });
    }
    NSArray *results = [sFunctionNameRegex matchesInString:shaderString options:0 range:NSMakeRange(0, shaderString.length)];
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
    
    return [functionInfos copy];
}


- (CEShaderFunctionInfo *)parseFunctionInfoWithContent:(NSString *)functionString shaderString:(NSString *)shaderString {
    // get function name
    __block NSString *functionName;
    [functionString enumerateSubstringsInRange:NSMakeRange(0, 100) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (![substring isEqualToString:@"void"]) {
            functionName = substring;
            *stop = YES;
        }
    }];
    // get function params
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
    
    // get function content
    startBracketRange = [functionString rangeOfString:@"{"];
    endBracketRange = [functionString rangeOfString:@"}" options:NSBackwardsSearch];
    NSString *content;
    if (startBracketRange.location != NSNotFound &&
        endBracketRange.location != NSNotFound) {
        content = [functionString substringWithRange:NSMakeRange(NSMaxRange(startBracketRange), endBracketRange.location - NSMaxRange(startBracketRange))];
    }
    
    
    // parse link info
    static NSRegularExpression *sFunctionLinkRegex = nil;
    if (!sFunctionLinkRegex) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sFunctionLinkRegex = [NSRegularExpression regularExpressionWithPattern:@"#link\\s\\w*\\(.*\\)(;|)" options:0 error:nil];
        });
    }
    NSMutableDictionary *linkFunctionDict = [NSMutableDictionary dictionary];
    if (content.length) {
        NSArray *results = [sFunctionLinkRegex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
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
                NSTextCheckingResult *result = [regex firstMatchInString:shaderString options:0 range:NSMakeRange(0, content.length)];
                if (result && result.range.location != NSNotFound) {
                    NSString *paramDeclaration = [shaderString substringWithRange:result.range];
                    NSString *paramID = [self getParamID:paramDeclaration];
                    if (paramID.length) {
                        [linkFunctionID appendFormat:@"_%@", paramID];
                    }
                }
            }
            linkFunctionDict[linkFunctionID] = NSStringFromRange(result.range);
        }
    }
    
    
    CEShaderFunctionInfo *functionInfo = [CEShaderFunctionInfo new];
    functionInfo.functionID = functionID.copy;
    functionInfo.functionContent = content;
    functionInfo.linkFunctionDict = linkFunctionDict.copy;
    
    return functionInfo;
}


- (NSString *)getParamID:(NSString *)paramDeclaration {
    if (!paramDeclaration.length) {
        return nil;
    }
    
    NSArray *words = [paramDeclaration componentsSeparatedByString:@" "];
    NSString *paramType;
    NSString *paramName;
    for (NSString *word in words) {
        if (word.length && !paramType) {
            paramType = word;
        } else if (word.length && paramType && !paramName) {
            paramName = word;
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




@end



