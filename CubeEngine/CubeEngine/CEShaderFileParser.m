//
//  CEShaderFileParser.m
//  CubeEngine
//
//  Created by chance on 8/19/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderFileParser.h"
#import "CEUtils.h"


@interface CEShaderFileInfo ()

@property (nonatomic, readwrite, strong) NSSet *vertexShaderVariables;
@property (nonatomic, readwrite, strong) NSString *vertexShaderContent;
@property (nonatomic, readwrite, strong) NSSet *fragmentShaderVariables;
@property (nonatomic, readwrite, strong) NSString *fragmentShaderContent;

@end

@interface CEShaderFunctionInfo ()

@property (nonatomic, readwrite, strong) NSString *functionID;
@property (nonatomic, readwrite, strong) NSString *functionContent;
@property (nonatomic, readwrite, strong) NSDictionary *linkFunctionDict; // {@"functionID" : @"rangeString"}

@end



@implementation CEShaderFileParser {
    NSString *_vertexShaderPath;
    NSString *_fragmentShaderPath;
}


- (instancetype)initWithShaderName:(NSString *)shaderName {
    self = [super init];
    if (self) {
        _vertexShaderPath = [CEShaderDirectory() stringByAppendingFormat:@"/%@.vert", shaderName];
        _fragmentShaderPath = [CEShaderDirectory() stringByAppendingFormat:@"/%@.frag", shaderName];
    }
    return self;
}


- (CEShaderFileInfo *)parse {
    CEShaderFileInfo *shaderInfo = [CEShaderFileInfo new];
    [self parseVertexShaderForInfo:shaderInfo];
    [self parseFragmentShaderForInfo:shaderInfo];
    
    return nil;
}


- (void)parseVertexShaderForInfo:(CEShaderFileInfo *)shaderInfo {
    NSString *vertexShader = [NSString stringWithContentsOfFile:_vertexShaderPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    if (!vertexShader.length) {
        return;
    }
    
    
}


- (void)parseFragmentShaderForInfo:(CEShaderFileInfo *)shaderInfo {
    NSString *fragmentShader = [NSString stringWithContentsOfFile:_fragmentShaderPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    if (!fragmentShader.length) {
        return;
    }
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [self parseUnifromsInShader:fragmentShader];
    printf("duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
    
    startTime = CFAbsoluteTimeGetCurrent();
    [self parseAttributesInShader:fragmentShader];
    printf("duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
    
    startTime = CFAbsoluteTimeGetCurrent();
    [self parseVaryingsInShader:fragmentShader];
    printf("duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
    
    startTime = CFAbsoluteTimeGetCurrent();
    [self parseStructDeclarationInShader:fragmentShader];
    printf("duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
    
    startTime = CFAbsoluteTimeGetCurrent();
    [self parseFunctionsInShader:fragmentShader];
    printf("duration: %.5f\n", CFAbsoluteTimeGetCurrent() - startTime);
    
    
    
}


- (NSString *)searchString:(NSString *)content forVariableDeclaration:(NSString *)keyword {
    NSRange keywordRange = [content rangeOfString:keyword];
    if (keywordRange.location != NSNotFound) {
        NSRange endMarkRange = [content rangeOfString:@";"];
        return [content substringWithRange:NSMakeRange(keywordRange.location, endMarkRange.location)];
    }
    return nil;
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
    
    for (NSTextCheckingResult *result in results) {
        NSLog(@"%@", [shaderString substringWithRange:result.range]);
    }
    return nil;
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
    
    for (NSTextCheckingResult *result in results) {
        NSLog(@"%@", [shaderString substringWithRange:result.range]);
    }
    return nil;
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
    
    for (NSTextCheckingResult *result in results) {
        NSLog(@"%@", [shaderString substringWithRange:result.range]);
    }
    return nil;
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
            sFunctionNameRegex = [NSRegularExpression regularExpressionWithPattern:@"void\\s*\\w*\\(.*\\)" options:0 error:nil];
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
                searchRange.location = NSMaxRange(resultRange);
                searchRange.length = shaderString.length - NSMaxRange(resultRange);
                
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
    for (NSString *functionContent in functionDeclarations) {
        // parse function id
        
    }
    
    return [functionDeclarations copy];
}


@end



