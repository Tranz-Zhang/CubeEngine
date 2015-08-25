//
//  BuildToolManager.m
//  CubeEngine
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BuildToolManager.h"
#import "CEDirectoryDefines.h"
#import "CEShaderProfileParser.h"
#import "CEShaderFunctionInfo.h"
#import "CEShaderProfile.h"

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
    _appPath = [_buildProductDir stringByAppendingFormat:@"/%@.app", _appName];
//    if (![_fileManager fileExistsAtPath:_appPath isDirectory:nil]) {
//        printf("App doesn't exist at path: %s\n", [_appPath UTF8String]);
//        return;
//    }
    
    if (![self createEngineDirectoryInApp]) {
        return;
    }
    
    [self processShaderResources];
}


- (BOOL)createEngineDirectoryInApp {
    _engineDir = [_appPath stringByAppendingPathComponent:kEngineDirectory];
    printf(">> checkEngineDirectoryInApp: %s\n", [_engineDir UTF8String]);
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
    printf(">> process shader resources...\n");
    
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
    NSMutableSet *shaderNames = [NSMutableSet set];
    for (NSString *fileName in currentShaderFiles) {
        if ([fileName hasSuffix:@".vert"] || [fileName hasSuffix:@".frag"]) {
            [shaderNames addObject:[fileName substringToIndex:fileName.length - 5]];
        }
    }
    if (!shaderNames.count) {
        printf("WARNING: process no shaders in Path:%s\n", [fromDir UTF8String]);
        return;
    }
    
    CEShaderProfileParser *shaderFileParser = [CEShaderProfileParser new];
    for (NSString *shaderName in shaderNames) {
        NSString *vertexFilePath = [fromDir stringByAppendingFormat:@"/%@.vert", shaderName];
        NSString *vertexString = [NSString stringWithContentsOfFile:vertexFilePath encoding:NSUTF8StringEncoding error:nil];
        NSString *fragmentFilePath = [fromDir stringByAppendingFormat:@"/%@.frag", shaderName];
        NSString *fragmentString = [NSString stringWithContentsOfFile:fragmentFilePath encoding:NSUTF8StringEncoding error:nil];
        
        CEShaderProfile *fileInfo = [shaderFileParser parseWithVertexShader:vertexString
                                                              fragmentShader:fragmentString];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[fileInfo jsonDict]
                                                           options:0 error:nil];
        BOOL isOK = [jsonData writeToFile:[toDir stringByAppendingFormat:@"/%@.ceshader", shaderName] atomically:YES];
        printf("process shader %s %s\n", [shaderName UTF8String], isOK ? "OK" : "Fail");
    }
}


- (void)copyShaderResources {
    printf(">> copying shader resources...\n");
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
        printf("WARNING: Copy no shaders in Path:%s\n", [fromDir UTF8String]);
        return;
    }
    for (NSString *fileName in currentShaderFiles) {
        if ([fileName hasPrefix:@"."]) {
            printf("skip file: %s\n", [fileName UTF8String]);
            continue;
        }
        printf("copy %s", [fileName UTF8String]);
        NSString *fromPath = [fromDir stringByAppendingPathComponent:fileName];
        NSString *toPath = [toDir stringByAppendingPathComponent:fileName];
        NSError *error;
        BOOL isOK = [_fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
        if (!isOK || error) {
            printf(" Fail! ERROR:\n%s\n", [[error localizedDescription] UTF8String]);
        } else {
            printf(" OK\n");
        }
    }
    
}


@end










