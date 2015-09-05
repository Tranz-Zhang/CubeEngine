//
//  BuildToolManager.m
//  CubeEngine
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BuildToolManager.h"
#import "CEShaderProfileParser.h"
#import "CEShaderFunctionInfo.h"
#import "CEShaderProfile.h"
#import "CEShaderBuilder.h"

#define kShaderResourceDir @"CubeEngine/ShaderResources"

@implementation BuildToolManager {
    NSFileManager *_fileManager;
    NSString *_appPath;
    NSString *_engineDir;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}


- (void)run {
    if (!_appName.length || !_buildProductDir.length) {
        return;
    }
    _appPath = [kAppPath copy];
    if (![_fileManager fileExistsAtPath:_appPath isDirectory:nil]) {
        printf("App doesn't exist at path: %s\n", [_appPath UTF8String]);
        return;
    }
    if (![self createEngineDirectoryInApp]) {
        return;
    }
    
    [self processShaderResources];
    
    [self testShaderBuilder];
}


- (BOOL)createEngineDirectoryInApp {
    printf("\n>> check engine directory in app:\n %s\n", [_appPath UTF8String]);
    
    _engineDir = [_appPath stringByAppendingPathComponent:kEngineDirectory];
    if (![_fileManager fileExistsAtPath:_engineDir isDirectory:nil]) {
        BOOL isOK = [_fileManager createDirectoryAtPath:_engineDir
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:nil];
        printf(isOK ? "Create engine directory\n" : "Fail to create engine directory\n");
        return isOK;
        
    } else {
        return YES;
    }
}


- (void)processShaderResources {
    printf("\n>> process shader resources...\n");
    
    // check shader directory in app
    NSString *toDir = [_appPath stringByAppendingPathComponent:kShaderDirectory];
    if (![_fileManager fileExistsAtPath:toDir isDirectory:nil]) {
        BOOL isOK = [_fileManager createDirectoryAtPath:toDir
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
        printf(isOK ? "Create shader directory\n" : "Fail to create engine directory\n");
        if (!isOK) return;
    }
    // remove existed shaders
    NSArray *lastShaderFiles = [_fileManager contentsOfDirectoryAtPath:toDir error:nil];
    for (NSString *fileName in lastShaderFiles) {
        NSString *filePath = [toDir stringByAppendingPathComponent:fileName];
        [_fileManager removeItemAtPath:filePath error:nil];
    }
    
    NSString *fromDir = [_engineProjectDir stringByAppendingPathComponent:kShaderResourceDir];
    NSArray * currentShaderFiles = [_fileManager contentsOfDirectoryAtPath:fromDir error:nil];
    if (!currentShaderFiles.count) {
        printf("WARNING: process no shaders in Path:%s\n", [fromDir UTF8String]);
        return;
    }
    
    CEShaderProfileParser *shaderParser = [CEShaderProfileParser new];
    for (NSString *fileName in currentShaderFiles) {
        if (![fileName hasSuffix:@".vert"] && ![fileName hasSuffix:@".frag"]) {
            continue;
        }
        NSString *filePath = [fromDir stringByAppendingPathComponent:fileName];
        NSString *shaderString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        CEShaderProfile *fileInfo = [shaderParser parseShaderString:shaderString];
        if (fileInfo) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[fileInfo jsonDict]
                                                               options:0 error:nil];
            BOOL isOK = [jsonData writeToFile:[toDir stringByAppendingFormat:@"/%@.profile", fileName] atomically:YES];
            printf("process shader %s.profile %s\n", [fileName UTF8String], isOK ? "OK" : "Fail");
        }
    }
}


- (void)processModelResources {
    
}


#pragma mark - Shader Builder
- (void)testShaderBuilder {
#if TARGET_OS_MAC
    CEShaderBuilder *shaderBuilder = [CEShaderBuilder new];
    [shaderBuilder startBuildingNewShader];
    [shaderBuilder build];
#endif

}



@end










