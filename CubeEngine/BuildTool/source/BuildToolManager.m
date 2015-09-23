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
#import "CEDB.h"

#import "OBJFileParser.h"
#import "MTLFileParser.h"

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
    
    printf("\n>> check engine directory in app:\n %s\n", [_appPath UTF8String]);
    _engineDir = [_appPath stringByAppendingPathComponent:kEngineDirectory];
    if (![self createDirectoryAtPath:_engineDir]) {
        _engineDir = nil;
        return;
    }
    
    if(![self processShaderResources]){
        printf("\nFail to process shader resources, ABORT!\n");
        return;
    }
    if(![self processModelResources]){
        printf("\nFail to process model resources, ABORT!\n");
        return;
    }
//    [self testShaderBuilder];
}


#pragma mark - process shaders

- (BOOL)processShaderResources {
    printf("\n>> process shader resources...\n");
    // check shader directory in app
    NSString *toDir = [_appPath stringByAppendingPathComponent:kShaderDirectory];
    if (![self createDirectoryAtPath:toDir]) {
        return NO;
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
        return YES;
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
    return YES;
}


- (void)testShaderBuilder {
#if TARGET_OS_MAC
    CEShaderBuilder *shaderBuilder = [CEShaderBuilder new];
    [shaderBuilder startBuildingNewShader];
    [shaderBuilder build];
#endif

}



#pragma mark - process models

- (BOOL)processModelResources {
    printf("\n>> process model resources...\n");
    if (![[NSFileManager defaultManager] fileExistsAtPath:_resourcesDir]) {
        printf("Resources directory doesn't existed at path: %s\n", [_resourcesDir UTF8String]);
        return NO;
    }
    // check model directory in app
    NSString *modelDir = [_appPath stringByAppendingPathComponent:kModelDirectory];
    if (![self createDirectoryAtPath:modelDir]){
        return NO;
    }
    
    // get obj files
    NSMutableArray *objFiles = [NSMutableArray array];
    [self parseObjFileAtPath:_resourcesDir objFiles:objFiles];
    if (!objFiles.count) {
        printf("WARNING: process no model in Path:%s\n", [_resourcesDir UTF8String]);
        return YES;
    }
    NSLog(@"%@", objFiles);
//    for (NSString *filePath in objFiles) {
//        OBJFileParser *parser = [OBJFileParser parserWithFilePath:filePath];
//        NSArray *results = [parser parse];
//    }
    
    
    NSString *objFilePath = objFiles[5];//[objFiles lastObject];
    OBJFileParser *objParser = [OBJFileParser parserWithFilePath:objFilePath];
    OBJFileInfo *info = [objParser parse];
    
    BOOL hasNormalMap = NO;
    if (info.mtlFileName) {
        NSString *currentDirectory = [objFilePath stringByDeletingLastPathComponent];
        NSString *mtlFilePath = [currentDirectory stringByAppendingPathComponent:info.mtlFileName];
        MTLFileParser *mtlParser = [MTLFileParser parserWithFilePath:mtlFilePath];
        NSDictionary *mtlDict = [mtlParser parse];
        for (MeshInfo *mesh in info.meshInfos) {
            mesh.materialInfo = mtlDict[mesh.materialName];
            if (!hasNormalMap) {
                hasNormalMap = (mesh.materialInfo.normalTextureName != nil);
            }
        }
    }
    if (hasNormalMap) {
        [OBJFileParser addTengentDataToObjInfo:info];
    }
    
    return YES;
}


- (void)parseObjFileAtPath:(NSString *)directory objFiles:(NSMutableArray *)objFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    for (NSString *fileName in fileList) {
        if ([fileName hasPrefix:@"."]) { // skip hidden directory
            continue;
        }
        BOOL isDirectory;
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if([fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
            if (!isDirectory) {
                if ([fileName hasSuffix:@".obj"]) {
                    [objFiles addObject:filePath];
                }
                
            } else {
                [self parseObjFileAtPath:filePath objFiles:objFiles];
            }
        }
    }
}


#pragma mark - others
- (BOOL)createDirectoryAtPath:(NSString *)directoryPath {
    if (![_fileManager fileExistsAtPath:directoryPath isDirectory:nil]) {
        BOOL isOK = [_fileManager createDirectoryAtPath:directoryPath
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
        printf("Create directory %s at:%s\n", isOK ? "OK" : "FAIL", [directoryPath UTF8String]);
        return isOK;
    }
    return YES;
}


@end










