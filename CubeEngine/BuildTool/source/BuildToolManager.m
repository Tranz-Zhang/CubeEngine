//
//  BuildToolManager.m
//  CubeEngine
//
//  Created by chance on 8/18/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "BuildToolManager.h"
#import "CEResourceDefines.h"
#import "CEShaderProfileParser.h"
#import "CEShaderFunctionInfo.h"
#import "CEShaderProfile.h"
#import "CEShaderBuilder.h"
#import "CEDB.h"

#import "OBJFileParser.h"
#import "MTLFileParser.h"
#import "ModelDataPacker.h"

// db object
#import "CEModelInfo.h"
#import "CEMeshInfo.h"
#import "CEMaterialInfo.h"
#import "CETextureInfo.h"


#define kShaderResourceDir @"CubeEngine/ShaderResources"

@implementation BuildToolManager {
    NSFileManager *_fileManager;
    NSString *_appPath;
    NSString *_engineDir;
    NSMutableDictionary *_fileLastUpdatedDict;
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
    [self cleanDirectory:toDir];
    
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:_resourcesDir]) {
        printf("Resources directory doesn't existed at path: %s\n", [_resourcesDir UTF8String]);
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
//    for (NSString *objFilePath in objFiles) {
//        
//    }\
    
    NSString *objFilePath = objFiles[9];//[objFiles lastObject];
    NSLog(@"TEST FILE: %@", objFilePath);
    
    // parse obj file
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
                hasNormalMap = (mesh.materialInfo.normalTexture != nil);
            }
        }
    }
    if (hasNormalMap) {
        [OBJFileParser addTangentDataToObjInfo:info];
    }
    
    if (![self processModelResourcesDataWithObjInfos:@[info]]) {
        return NO;
    }
    if (![self buildDatabaseWithObjInfos:@[info]]) {
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
    
    NSString *modelDir = [_appPath stringByAppendingPathComponent:kModelDirectory];
    if (![self createDirectoryAtPath:modelDir]){
        return NO;
    }
    [self cleanDirectory:modelDir];
    
    ModelDataPacker *modelPacker = [[ModelDataPacker alloc] initWithAppPath:_appPath];
    // composite vertex data and indic data
    for (OBJFileInfo *objInfo in objFileInfos) {
        printf("process model: %s", objInfo.name.UTF8String);
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        dataDict[@(objInfo.resourceID)] = [objInfo buildVertexData];
        for (MeshInfo *meshInfo in objInfo.meshInfos) {
            dataDict[@(meshInfo.resourceID)] = [meshInfo buildIndiceData];
        }
        BOOL isOK = [modelPacker packModelDataDict:dataDict];
        printf(" M_DATA[%s]", isOK ? "OK" : "Fail");
        
        // process texture data
        
        printf("\n");
    }
    
    return YES;
}


- (BOOL)buildDatabaseWithObjInfos:(NSArray *)objFileInfos {
//    // check config directory
    NSString *configDir = [_appPath stringByAppendingPathComponent:kConfigDirectory];
//    if (![self createDirectoryAtPath:configDir]){
//        return NO;
//    }
//    [self cleanDirectory:configDir];
    
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
            dbMeshInfo.indiceCount = (uint32_t)meshInfo.indicesList.count;
            dbMeshInfo.indicePrimaryType = [meshInfo indicePrimaryType];
            dbMeshInfo.drawMode = GL_TRIANGLES;
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
            dbMaterialInfo.transparent = mtlInfo.transparency;
            dbMaterialInfo.materialType = 0; // TODO: materialType
            dbMaterialInfo.diffuseTextureID = mtlInfo.diffuseTexture.resourceID;
            dbMaterialInfo.normalTextureID = mtlInfo.normalTexture.resourceID;
            [dbMaterialInfoList addObject:dbMaterialInfo];
            // textures info
            if (mtlInfo.diffuseTexture) {
                CETextureInfo *diffuseTextureInfo = [CETextureInfo new];
                diffuseTextureInfo.textureID = mtlInfo.diffuseTexture.resourceID;
                diffuseTextureInfo.textureSize = mtlInfo.diffuseTexture.size;
                [dbTextureInfoList addObject:diffuseTextureInfo];
            }
            if (mtlInfo.normalTexture) {
                CETextureInfo *normalTextureInfo = [CETextureInfo new];
                normalTextureInfo.textureID = mtlInfo.normalTexture.resourceID;
                normalTextureInfo.textureSize = mtlInfo.normalTexture.size;
                [dbTextureInfoList addObject:normalTextureInfo];
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



#pragma mark - File up to date checking

- (void)initializeUpToDateFileInfo {
    NSString *filePath = [_engineProjectDir stringByAppendingFormat:@"/BuildTool/resource_updated_info"];
    _fileLastUpdatedDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if (!_fileLastUpdatedDict) {
        _fileLastUpdatedDict = [NSMutableDictionary dictionary];
    }
}


- (BOOL)isFileUpdateToDateAtPath:(NSString *)filePath {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    if (![fileAttributes fileModificationDate]) {
        return NO;
    }
    NSDate *lastModifiedDate = [fileAttributes fileModificationDate];
    NSDate *lastUpdatedDate = _fileLastUpdatedDict[filePath];
    if (!lastUpdatedDate || ![lastModifiedDate isEqualToDate:lastUpdatedDate]) {
        _fileLastUpdatedDict[filePath] = lastModifiedDate;
        return NO;
        
    } else {
        return YES;
    }
}


- (void)syncUpToDateFileInfo {
    NSString *filePath = [_engineProjectDir stringByAppendingFormat:@"/BuildTool/resource_updated_info"];
    if (![_fileLastUpdatedDict writeToFile:filePath atomically:YES]) {
        printf("Warning: fail to sync up_to_date_info\n");
    }
}


@end










