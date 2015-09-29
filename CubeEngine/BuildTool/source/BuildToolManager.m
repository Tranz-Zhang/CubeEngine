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

// db object
#import "CEObjFileInfo.h"
#import "CEMeshInfo.h"
#import "CEMaterialInfo.h"
#import "CETextureInfo.h"


#define kShaderResourceDir @"CubeEngine/ShaderResources"
#define kResourcesDatabaseName @"resources_info"

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
    // check model & texture directory in app
    NSString *modelDir = [_appPath stringByAppendingPathComponent:kModelDirectory];
    if (![self createDirectoryAtPath:modelDir]){
        return NO;
    }
    NSString *textureDir = [_appPath stringByAppendingPathComponent:kTextureDirectory];
    if (![self createDirectoryAtPath:textureDir]){
        return NO;
    }
    // remove old files
    [self cleanDirectory:modelDir];
    [self cleanDirectory:textureDir];
    
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
//    }
    
    
    NSString *objFilePath = objFiles[11];//[objFiles lastObject];
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
                hasNormalMap = (mesh.materialInfo.normalTextureName != nil);
            }
        }
    }
    if (hasNormalMap) {
        [OBJFileParser addTengentDataToObjInfo:info];
    }
    
    // build db info
    NSMutableArray *dbObjInfoList = [NSMutableArray array];
    NSMutableArray *dbMeshInfoList = [NSMutableArray array];
    NSMutableArray *dbMaterialInfoList = [NSMutableArray array];
    NSMutableArray *dbTextureInfoList = [NSMutableArray array];
    int modelID =       0x10000000;
    int meshID =        0x20000000;
    int materialID =    0x30000000;
    int textureID =     0x40000000;
    CEObjFileInfo *dbObjInfo = [CEObjFileInfo new];
    dbObjInfo.fileName = info.name;
    dbObjInfo.attributes = info.attributes;
    dbObjInfo.vertexDataID = modelID++;
    // transfer vertex data to app
    NSMutableData *modelData = [NSMutableData data];
    NSData *vertexData = [info buildVertexData];
    [self appendData:vertexData toModelData:modelData withID:dbObjInfo.vertexDataID];
    
    NSMutableArray *meshIDs = [NSMutableArray arrayWithCapacity:info.meshInfos.count];
    for (int i = 0; i < info.meshInfos.count; i++) {
        // parse mesh info
        MeshInfo *meshInfo = info.meshInfos[i];
        CEMeshInfo *dbMeshInfo = [CEMeshInfo new];
        dbMeshInfo.meshID = meshID++;
        dbMeshInfo.indicePrimaryType = [meshInfo indicePrimaryType];
        dbMeshInfo.drawMode = GL_TRIANGLES;
        // build mesh indice data
        NSData *indiceData = [meshInfo buildIndiceData];
        [self appendData:indiceData toModelData:modelData withID:dbMeshInfo.meshID];
        [meshIDs addObject:@(dbMeshInfo.meshID)];
        
        // parse material info
        MTLInfo *mtlInfo = meshInfo.materialInfo;
        CEMaterialInfo *dbMaterialInfo = [CEMaterialInfo new];
        dbMaterialInfo.materialID = materialID++;
        dbMaterialInfo.ambientColorData = [NSData dataWithBytes:mtlInfo.ambientColor.v length:sizeof(GLKVector3)];
        dbMaterialInfo.diffuseColorData = [NSData dataWithBytes:mtlInfo.ambientColor.v length:sizeof(GLKVector3)];
        dbMaterialInfo.specularColorData = [NSData dataWithBytes:mtlInfo.ambientColor.v length:sizeof(GLKVector3)];
        dbMaterialInfo.shininessExponent = mtlInfo.shininessExponent;
        dbMaterialInfo.transparent = mtlInfo.transparency;
        dbMaterialInfo.materialType = 0; // TODO: materialType
        
        // parse textures
        if (mtlInfo.diffuseTextureName.length) {
            CETextureInfo *diffuseTextureInfo = [CETextureInfo new];
            diffuseTextureInfo.textureID = textureID++;
            #warning copy texture data to app
            
            
            
            
            
            dbMaterialInfo.diffuseTextureID = diffuseTextureInfo.textureID;
            [dbTextureInfoList addObject:diffuseTextureInfo];
        }
        if (mtlInfo.normalTextureName.length) {
            CETextureInfo *normalTextureInfo = [CETextureInfo new];
            normalTextureInfo.textureID = textureID++;
            #warning copy texture data to app
            
            
            
            
            
            dbMaterialInfo.normalTextureID = normalTextureInfo.textureID;
            [dbTextureInfoList addObject:normalTextureInfo];
        }
        
        [dbMaterialInfoList addObject:dbMaterialInfo];
        [dbMeshInfoList addObject:dbMeshInfo];
    }
    dbObjInfo.meshIDs = meshIDs.copy;
    [dbObjInfoList addObject:dbObjInfo];
    
    // save model data to model directory
    if (modelData.length) {
        NSString *modelPath = [modelDir stringByAppendingPathComponent:dbObjInfo.fileName];
        BOOL isOK = [modelData writeToFile:modelPath atomically:YES];
        
        printf("process model data: %s %s", dbObjInfo.fileName.UTF8String, isOK ? "OK" : "Fail");
    }
    
    // save db info
    NSString *dbPath = [_engineDir stringByAppendingPathComponent:kResourcesDatabaseName];
    if ([_fileManager fileExistsAtPath:dbPath isDirectory:nil]) {
        [_fileManager removeItemAtPath:dbPath error:nil];
    }
    
    NSError *error;
    BOOL isOK;
    CEDatabase *db = [CEDatabase databaseWithName:kResourcesDatabaseName inPath:_engineDir];
    CEDatabaseContext *objContext = [CEDatabaseContext contextWithTableName:@"obj_info" class:[CEObjFileInfo class] inDatabase:db];
    isOK = [objContext insertObjects:dbObjInfoList.copy error:&error];
    if (!isOK || error) {
        printf("Fail to insert obj info to db: %s\n", [[error localizedDescription] UTF8String]);
        return NO;
    }
    CEDatabaseContext *meshContext = [CEDatabaseContext contextWithTableName:@"mesh_info" class:[CEMeshInfo class] inDatabase:db];
    isOK = [meshContext insertObjects:dbMeshInfoList error:&error];
    if (!isOK || error) {
        printf("Fail to insert mesh info to db: %s\n", [[error localizedDescription] UTF8String]);
        return NO;
    }
    CEDatabaseContext *materialContext = [CEDatabaseContext contextWithTableName:@"material_info" class:[CEMaterialInfo class] inDatabase:db];
    isOK = [materialContext insertObjects:dbMaterialInfoList error:&error];
    if (!isOK || error) {
        printf("Fail to insert material info to db: %s\n", [[error localizedDescription] UTF8String]);
        return NO;
    }
    CEDatabaseContext *textureContext = [CEDatabaseContext contextWithTableName:@"texture_info" class:[CETextureInfo class] inDatabase:db];
    isOK = [textureContext insertObjects:dbTextureInfoList error:&error];
    if (!isOK || error) {
        printf("Fail to insert texture info to db: %s\n", [[error localizedDescription] UTF8String]);
        return NO;
    }
    
    return YES;
}


- (void)appendData:(NSData *)appendingData toModelData:(NSMutableData *)modelData withID:(int32_t)dataID {
    if (!appendingData.length || !modelData) {
        return;
    }
    uint32 dataLength = (uint32)appendingData.length + sizeof(uint32) * 2;
    [modelData appendBytes:&dataLength length:sizeof(uint32)];
    [modelData appendBytes:&dataID length:sizeof(int32_t)];
    [modelData appendData:appendingData];
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










