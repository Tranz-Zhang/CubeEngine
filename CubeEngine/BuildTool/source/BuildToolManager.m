//
//  BuildToolManager.m
//  CubeEngine
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BuildToolManager.h"
#import "CEDirectoryDefines.h"

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
    if (!_appName.length || !_productDir.length) {
        return;
    }
    _appPath = [_productDir stringByAppendingFormat:@"/%@.app", _appName];
    if (![_fileManager fileExistsAtPath:_appPath isDirectory:nil]) {
        printf("App doesn't exist at path: %s\n", [_appPath UTF8String]);
        return;
    }
    
    if (![self createEngineDirectoryInApp]) {
        return;
    }
    
    [self copyShaderResources];
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
    
    NSString *fromDir = [_engineSourceDir stringByAppendingString:ShaderResourceDir];
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










