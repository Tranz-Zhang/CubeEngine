//
//  BuildToolManager.m
//  CubeEngine
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BuildToolManager.h"
#import "Common.h"
#import "CEResourceDefines.h"
#import "CEShaderProfileParser.h"
#import "CEShaderFunctionInfo.h"
#import "CEShaderProfile.h"
#import "CEShaderBuilder.h"
#import "CEDB.h"
#import "FileUpdateManager.h"

#import "OBJFileParser.h"
#import "ModelDataPacker.h"
#import "TextureDataPacker.h"

// db object
#import "CEModelInfo.h"
#import "CEMeshInfo.h"
#import "CEMaterialInfo.h"
#import "CETextureInfo.h"


#define kShaderResourceDir @"CubeEngine/ShaderResources"

@implementation BuildToolManager {
    NSFileManager *_fileManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}


- (void)run {
    if (![_fileManager fileExistsAtPath:kAppPath isDirectory:nil]) {
        printf("App doesn't exist at path: %s\n", [kAppPath UTF8String]);
        return;
    }
    
    // check config directory
    NSString *configDir = [kAppPath stringByAppendingPathComponent:kConfigDirectory];
    if (![self createDirectoryAtPath:configDir]){
        printf("\nFail to create config directory, ABORT!\n");
        return;
    }
    [self cleanDirectory:configDir];
    
    if(![self processShaderResources]){
        printf("\nFail to process shader resources, ABORT!\n");
        return;
    }
    if(![self processModelResources]){
        printf("\nFail to process model resources, ABORT!\n");
        return;
    }
    
    
//    [self testShaderBuilder];
    [[FileUpdateManager sharedManager] cleanUp];
}


#pragma mark - process shaders

- (BOOL)processShaderResources {
    printf("\n>> process shader resources...\n");
    // check shader directory in app
    NSString *toDir = [kAppPath stringByAppendingPathComponent:kShaderDirectory];
    if (![self createDirectoryAtPath:toDir]) {
        return NO;
    }
    // remove existed shaders
    [self cleanDirectory:toDir];
    
    NSString *fromDir = [kEngineProjectDirectory stringByAppendingPathComponent:kShaderResourceDir];
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
            printf("process shader: %s.profile %s\n", [fileName UTF8String], isOK ? "OK" : "Fail");
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:kResourcesDirectory]) {
        printf("Resources directory doesn't existed at path: %s\n", [kResourcesDirectory UTF8String]);
        return NO;
    }
    
    // get obj file paths
    NSMutableArray *objFilePathList = [NSMutableArray array];
    [self parseObjFileAtPath:kResourcesDirectory objFiles:objFilePathList];
    if (!objFilePathList.count) {
        printf("WARNING: process no model in Path:%s\n", [kResourcesDirectory UTF8String]);
        return YES;
    }

    // parse obj file
    NSMutableArray *objFileInfos = [NSMutableArray array];
    for (NSString *objFilePath in objFilePathList) {
        printf("parsing obj file: %s", [objFilePath lastPathComponent].UTF8String);
        OBJFileInfo *info = [OBJFileParser parseBaseInfoWithFilePath:objFilePath];
        if (info) {
            [objFileInfos addObject:info];
        }
        printf(" %s\n", info ? "√" : "X");
    }
    
//    NSString *objFilePath = objFilePathList[9];
//    printf("parsing obj file: %s", [objFilePath lastPathComponent].UTF8String);
//    OBJFileInfo *info = [OBJFileParser parseBaseInfoWithFilePath:objFilePath];
//    if (info) {
//        [objFileInfos addObject:info];
//    }
//    printf(" %s\n", info ? "√" : "X");
    
    // process resources
    if (![self processModelResourcesDataWithObjInfos:objFileInfos]) {
        return NO;
    }
    // write db info
    if (![self buildDatabaseWithObjInfos:objFileInfos]) {
        return NO;
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


- (BOOL)processModelResourcesDataWithObjInfos:(NSArray *)objFileInfos {
    
    NSString *modelDir = [kAppPath stringByAppendingPathComponent:kModelDirectory];
    if (![self createDirectoryAtPath:modelDir]){
        return NO;
    }
    NSString *textureDir = [kAppPath stringByAppendingPathComponent:kTextureDirectory];
    if (![self createDirectoryAtPath:textureDir]){
        return NO;
    }
    
    ModelDataPacker *modelPacker = [[ModelDataPacker alloc] initWithAppPath:kAppPath];
    TextureDataPacker *texturePacker = [[TextureDataPacker alloc] initWithAppPath:kAppPath];
    // composite vertex data and indic data
    for (OBJFileInfo *objInfo in objFileInfos) {
        printf("process model: %s\n", objInfo.name.UTF8String);
        // process model data
        if (![[FileUpdateManager sharedManager] isFileUpToDateAtPath:objInfo.filePath autoDelete:YES]) {
            NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
            OBJFileParser *dataParser = [OBJFileParser dataParser];
            [dataParser parseDataWithFileInfo:objInfo];
            dataDict[@(objInfo.resourceID)] = [objInfo buildVertexData];
            BOOL hasOptimized = NO;
            for (MeshInfo *meshInfo in objInfo.meshInfos) {
                NSData *indiceData = [meshInfo buildOptimizedIndiceData];
                if (indiceData.length) {
                    meshInfo.isOptimized = YES;
                } else {
                    indiceData = [meshInfo buildIndiceData];
                    meshInfo.isOptimized = NO;
                }
                dataDict[@(meshInfo.resourceID)] = indiceData;
                if (!hasOptimized) {
                    hasOptimized = meshInfo.isOptimized;
                }
            }
            NSString *resultPath = [modelPacker packModelDataDict:dataDict];
            if (resultPath) {
                [[FileUpdateManager sharedManager] updateInfoWithSourcePath:objInfo.filePath resultPath:resultPath];
            }
            printf(" - Model Data %s%s\n", resultPath ? "√" : "X", hasOptimized ? "+" : "");

        } else {
            printf(" - Model Data ∆\n");
        }
        
        // process texture data
        NSMutableArray *textureInfos = [NSMutableArray arrayWithCapacity:3];
        for (MeshInfo *meshInfo in objInfo.meshInfos) {
            if (meshInfo.materialInfo.diffuseTexture) {
                [textureInfos addObject:meshInfo.materialInfo.diffuseTexture];
            }
            if (meshInfo.materialInfo.normalTexture) {
                [textureInfos addObject:meshInfo.materialInfo.normalTexture];
            }
            if (meshInfo.materialInfo.specularTexture) {
                [textureInfos addObject:meshInfo.materialInfo.specularTexture];
            }
        }
        for (TextureInfo *info in textureInfos) {
            if (![[FileUpdateManager sharedManager] isFileUpToDateAtPath:info.filePath autoDelete:YES]) {
                NSString *resultPath = [texturePacker packTextureDataWithInfo:info];
                if (resultPath) {
                    [[FileUpdateManager sharedManager] updateInfoWithSourcePath:info.filePath resultPath:resultPath];
                }
                printf(" - Texture:%s %s\n", info.fileName.UTF8String, resultPath ? "√" : "X");
                
            } else {
                printf(" - Texture:%s ∆\n", info.fileName.UTF8String);
            }
        }
    }
    
    return YES;
}


- (BOOL)buildDatabaseWithObjInfos:(NSArray *)objFileInfos {
    NSString *configDir = [kAppPath stringByAppendingPathComponent:kConfigDirectory];
    // build db info
    NSMutableArray *dbObjInfoList = [NSMutableArray array];
    NSMutableArray *dbMeshInfoList = [NSMutableArray array];
    NSMutableArray *dbMaterialInfoList = [NSMutableArray array];
    NSMutableArray *dbTextureInfoList = [NSMutableArray array];
    
    for (OBJFileInfo *info in objFileInfos) {
        CEModelInfo *dbObjInfo = [CEModelInfo new];
        dbObjInfo.modelName = info.name;
        dbObjInfo.attributes = info.attributes;
        dbObjInfo.vertexDataID = info.resourceID;
        NSMutableArray *meshIDs = [NSMutableArray arrayWithCapacity:info.meshInfos.count];
        for (int i = 0; i < info.meshInfos.count; i++) {
            // mesh info
            MeshInfo *meshInfo = info.meshInfos[i];
            CEMeshInfo *dbMeshInfo = [CEMeshInfo new];
            dbMeshInfo.meshID = meshInfo.resourceID;
            dbMeshInfo.materialID = meshInfo.materialInfo.resourceID;
            dbMeshInfo.indiceCount = meshInfo.indiceCount;
            dbMeshInfo.indicePrimaryType = [meshInfo indicePrimaryType];
            dbMeshInfo.drawMode = meshInfo.isOptimized ? GL_TRIANGLE_STRIP : GL_TRIANGLES;
            [meshIDs addObject:@(dbMeshInfo.meshID)];
            [dbMeshInfoList addObject:dbMeshInfo];
            // material info
            MTLInfo *mtlInfo = meshInfo.materialInfo;
            CEMaterialInfo *dbMaterialInfo = [CEMaterialInfo new];
            dbMaterialInfo.materialID = mtlInfo.resourceID;
            dbMaterialInfo.ambientColorData = [NSData dataWithBytes:mtlInfo.ambientColor.v length:sizeof(GLKVector3)];
            dbMaterialInfo.diffuseColorData = [NSData dataWithBytes:mtlInfo.diffuseColor.v length:sizeof(GLKVector3)];
            dbMaterialInfo.specularColorData = [NSData dataWithBytes:mtlInfo.specularColor.v length:sizeof(GLKVector3)];
            dbMaterialInfo.shininessExponent = mtlInfo.shininessExponent;
            dbMaterialInfo.transparent = mtlInfo.transparency > 0 ?: -1;
            dbMaterialInfo.diffuseTextureID = mtlInfo.diffuseTexture.resourceID;
            dbMaterialInfo.normalTextureID = mtlInfo.normalTexture.resourceID;
            dbMaterialInfo.specularTextureID = mtlInfo.specularTexture.resourceID;
            if (dbMaterialInfo.transparent > 0 && dbMaterialInfo.transparent < 1) {
                dbMaterialInfo.materialType = CEMaterialTransparent;
            } else if (mtlInfo.diffuseTexture.hasAlpha) {
                dbMaterialInfo.materialType = CEMaterialAlphaTested;
            } else {
                dbMaterialInfo.materialType = CEMaterialSolid;
            }
            [dbMaterialInfoList addObject:dbMaterialInfo];
            
            // textures info
            if (mtlInfo.diffuseTexture) {
                CETextureInfo *diffuseTextureInfo = [CETextureInfo new];
                diffuseTextureInfo.textureID = mtlInfo.diffuseTexture.resourceID;
                diffuseTextureInfo.textureSize = mtlInfo.diffuseTexture.size;
                diffuseTextureInfo.hasAlpha = mtlInfo.diffuseTexture.hasAlpha;
                [dbTextureInfoList addObject:diffuseTextureInfo];
            }
            if (mtlInfo.normalTexture) {
                CETextureInfo *normalTextureInfo = [CETextureInfo new];
                normalTextureInfo.textureID = mtlInfo.normalTexture.resourceID;
                normalTextureInfo.textureSize = mtlInfo.normalTexture.size;
                normalTextureInfo.hasAlpha = mtlInfo.normalTexture.hasAlpha;
                [dbTextureInfoList addObject:normalTextureInfo];
            }
            if (mtlInfo.specularTexture) {
                CETextureInfo *specularTextureInfo = [CETextureInfo new];
                specularTextureInfo.textureID = mtlInfo.specularTexture.resourceID;
                specularTextureInfo.textureSize = mtlInfo.specularTexture.size;
                specularTextureInfo.hasAlpha = mtlInfo.specularTexture.hasAlpha;
                [dbTextureInfoList addObject:specularTextureInfo];
            }
        }
        dbObjInfo.meshIDs = meshIDs.copy;
        [dbObjInfoList addObject:dbObjInfo];
    }
    
    // save database info
    NSString *dbPath = [configDir stringByAppendingPathComponent:kResourceInfoDBName];
    if ([_fileManager fileExistsAtPath:dbPath isDirectory:nil]) {
        [_fileManager removeItemAtPath:dbPath error:nil];
    }
    NSError *error;
    BOOL isOK;
    CEDatabase *db = [CEDatabase databaseWithName:kResourceInfoDBName inPath:configDir];
    CEDatabaseContext *modelContext = [CEDatabaseContext contextWithTableName:kDBTableModelInfo class:[CEModelInfo class] inDatabase:db];
    isOK = [modelContext insertObjects:dbObjInfoList.copy error:&error];
    if (!isOK || error) {
        printf("Fail to insert obj info to db: %s\n", [[error localizedDescription] UTF8String]);
        return NO;
    }
    CEDatabaseContext *meshContext = [CEDatabaseContext contextWithTableName:kDBTableMeshInfo class:[CEMeshInfo class] inDatabase:db];
    isOK = [meshContext insertObjects:dbMeshInfoList error:&error];
    if (!isOK || error) {
        printf("Fail to insert mesh info to db: %s\n", [[error localizedDescription] UTF8String]);
        return NO;
    }
    CEDatabaseContext *materialContext = [CEDatabaseContext contextWithTableName:kDBTableMaterialInfo class:[CEMaterialInfo class] inDatabase:db];
    isOK = [materialContext insertObjects:dbMaterialInfoList error:&error];
    if (!isOK || error) {
        printf("Fail to insert material info to db: %s\n", [[error localizedDescription] UTF8String]);
        return NO;
    }
    CEDatabaseContext *textureContext = [CEDatabaseContext contextWithTableName:kDBTableTextureInfo class:[CETextureInfo class] inDatabase:db];
    isOK = [textureContext insertObjects:dbTextureInfoList error:&error];
    if (!isOK || error) {
        printf("Fail to insert texture info to db: %s\n", [[error localizedDescription] UTF8String]);
        return NO;
    }
    printf("Write model info to database Successfully!\n");
    
    return YES;
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


// remove all content in directory
- (void)cleanDirectory:(NSString *)directoryPath {
    BOOL isDirectory = NO;
    BOOL existed = [_fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!existed || !isDirectory) {
        printf("Warning: directory does not exist at path: %s\n", directoryPath.UTF8String);
    }
    
    NSArray *lastShaderFiles = [_fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString *fileName in lastShaderFiles) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        [_fileManager removeItemAtPath:filePath error:nil];
    }
}


@end










