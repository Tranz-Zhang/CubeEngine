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
        NSLog(@"App doesn't exist at path: %@\n", kAppPath);
        return;
    }
    
    // check config directory
    NSString *configDir = [kAppPath stringByAppendingPathComponent:kConfigDirectory];
    if (![self createDirectoryAtPath:configDir]){
        NSLog(@"\nFail to create config directory, ABORT!\n");
        return;
    }
//    [self cleanDirectory:configDir];
    
    if(![self processShaderResources]){
        NSLog(@"\nFail to process shader resources, ABORT!\n");
        return;
    }
    if(![self processModelResources]){
        NSLog(@"\nFail to process model resources, ABORT!\n");
        return;
    }
    
    [self testPVR];
    
//    [self testShaderBuilder];
    [[FileUpdateManager sharedManager] cleanUp];
}


- (void)testPVR {
    NSTask *task = [[NSTask alloc] init];
//    [task setStandardOutput:[NSPipe pipe]];
    task.currentDirectoryPath = @"~/Desktop/texturetool";
    task.launchPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool";
    // -f PVR -e PVRTC ./Brick.png -o ./Brick.pvr
//    task.arguments = @[@"-f", @"PVR", @"-e", @"PVRTC", @"~/Desktop/texturetool/Brick.png", @"-o", @"~/Desktop/texturetool/Brick_v.pvr"];
    task.arguments = @[@"-f", @"PVR", @"-e", @"PVRTC", @"~/Desktop/texturetool/Brick.png", @"-o", @"/Users/chance/My Development/cube-engine/CubeEngine/BuildTool/Brick_v.pvr"];
    [task launch];
    [task waitUntilExit];
    
    printf("");
}

- (void)readCompleted:(NSNotification *)notification {
    NSLog(@"Read data: %@", [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];
}

#pragma mark - process shaders

- (BOOL)processShaderResources {
    NSLog(@"\n>> process shader resources...\n");
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
        NSLog(@"WARNING: process no shaders in Path:%@\n", fromDir);
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
            NSLog(@"process shader: %@.profile %@\n", fileName, isOK ? @"√" : @"X");
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
    NSLog(@"\n>> process model resources...\n");
    if (![[NSFileManager defaultManager] fileExistsAtPath:kResourcesDirectory]) {
        NSLog(@"Resources directory doesn't existed at path: %@\n", kResourcesDirectory);
        return NO;
    }
    
    // get obj file paths
    NSMutableArray *objFilePathList = [NSMutableArray array];
    [self parseObjFileAtPath:kResourcesDirectory objFiles:objFilePathList];
    if (!objFilePathList.count) {
        NSLog(@"WARNING: process no model in Path:%@\n", kResourcesDirectory);
        return YES;
    }
    
    NSLog(@"%@", objFilePathList);
    // parse obj file
    NSMutableArray *objFileInfos = [NSMutableArray array];
#if 0
    for (NSString *objFilePath in objFilePathList) {
        OBJFileInfo *info = [OBJFileParser parseBaseInfoWithFilePath:objFilePath];
        if (info) {
            [objFileInfos addObject:info];
        }
        NSLog(@"parsing obj file: %@ %@\n", info.name, info ? @"√" : @"X");
    }
#else
    NSString *objFilePath = objFilePathList[6];//[objFilePathList lastObject];
    OBJFileInfo *info = [OBJFileParser parseBaseInfoWithFilePath:objFilePath];
    if (info) {
        [objFileInfos addObject:info];
    }
    NSLog(@"parsing obj file: %@ %@\n", info.name, info ? @"√" : @"X");
    NSLog(@"%@", info);
    
//    NSString *floorMaxPath = objFilePathList[7];//[objFilePathList lastObject]; //
//    OBJFileInfo *floorMax = [OBJFileParser parseBaseInfoWithFilePath:floorMaxPath];
//    if (floorMax) {
//        [objFileInfos addObject:floorMax];
//    }
#endif
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
        NSLog(@"Fail to create model directory: %@", modelDir);
        return NO;
    }
    NSString *textureDir = [kAppPath stringByAppendingPathComponent:kTextureDirectory];
    if (![self createDirectoryAtPath:textureDir]){
        NSLog(@"Fail to create texture directory: %@", textureDir);
        return NO;
    }
    
    // get mesh table
    NSString *configDir = [kAppPath stringByAppendingPathComponent:kConfigDirectory];
    CEDatabase *db = [CEDatabase databaseWithName:kResourceInfoDBName inPath:configDir];
    CEDatabaseContext *modelContext = [CEDatabaseContext contextWithTableName:kDBTableModelInfo class:[CEModelInfo class] inDatabase:db];
    CEDatabaseContext *meshContext = [CEDatabaseContext contextWithTableName:kDBTableMeshInfo class:[CEMeshInfo class] inDatabase:db];
    
    ModelDataPacker *modelPacker = [[ModelDataPacker alloc] initWithAppPath:kAppPath];
    TextureDataPacker *texturePacker = [[TextureDataPacker alloc] initWithAppPath:kAppPath];
    // composite vertex data and indic data
    for (OBJFileInfo *objInfo in objFileInfos) {
        NSLog(@"process model: %@\n", objInfo.name);
        // process model data
        if (![[FileUpdateManager sharedManager] isFileUpToDateAtPath:objInfo.filePath autoDelete:YES]) {
            NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
            OBJFileParser *dataParser = [OBJFileParser dataParser];
            [dataParser parseDataWithFileInfo:objInfo];
            dataDict[@(objInfo.resourceID)] = [objInfo buildVertexData];
            BOOL hasOptimized = NO;
            for (MeshInfo *meshInfo in objInfo.meshInfos) {
                NSData *indiceData = nil;
                if (ENABLE_TRIANGLE_STRIP) {
                    indiceData = [meshInfo buildOptimizedIndiceData];
                }
                if (indiceData.length) {
                    if (!hasOptimized) hasOptimized = YES;
                    meshInfo.drawMode = GL_TRIANGLE_STRIP;
                    
                } else {
                    indiceData = [meshInfo buildIndiceData];
                    meshInfo.drawMode = GL_TRIANGLES;
                }
                if (meshInfo.maxIndex > 65525) {
                    meshInfo.indicePrimaryType = GL_UNSIGNED_INT;
                } else if (meshInfo.maxIndex > 255) {
                    meshInfo.indicePrimaryType = GL_UNSIGNED_SHORT;
                } else {
                    meshInfo.indicePrimaryType = GL_UNSIGNED_BYTE;
                }
                dataDict[@(meshInfo.resourceID)] = indiceData;
            }
            NSString *resultPath = [modelPacker packModelDataDict:dataDict];
            if (resultPath) {
                [[FileUpdateManager sharedManager] updateInfoWithSourcePath:objInfo.filePath resultPath:resultPath];
            }
            NSLog(@" - ModelData[%08X] %@%@ to:%@\n", objInfo.resourceID, resultPath ? @"√" : @"X", hasOptimized ? @"+" : @"", resultPath);
            
        } else {
            // get some required info from last db
            CEModelInfo *dbModelInfo = (CEModelInfo *)[modelContext queryById:objInfo.name error:nil];
            if (dbModelInfo) {
                objInfo.attributes = dbModelInfo.attributes;
                objInfo.bounds = GLKVector3MakeWithData(dbModelInfo.boundsData);
                objInfo.offsetFromOrigin = GLKVector3MakeWithData(dbModelInfo.offsetFromOriginData);
            } else {
                NSLog(@"WARNING: can't get db info for model: %@", objInfo.name);
            }
            
            // assign indice count
            for (MeshInfo *meshInfo in objInfo.meshInfos) {
                CEMeshInfo *dbInfo = (CEMeshInfo *)[meshContext queryById:@(meshInfo.resourceID) error:nil];
                if (!dbInfo) {
                    NSLog(@"WARNING: can't get db info for mesh:%@", meshInfo.name);
                    continue;
                }
                meshInfo.indicePrimaryType = dbInfo.indicePrimaryType;
                meshInfo.drawMode = dbInfo.drawMode;
                meshInfo.indiceCount = dbInfo.indiceCount;
                
            }
            
            NSLog(@" - ModelData[%08X] ∆\n", objInfo.resourceID);
        }
        
        // process texture data
        NSMutableSet *textureInfos = [NSMutableSet setWithCapacity:3];
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
                NSLog(@" - Texture[%08X]: %@ %@\n", info.resourceID, info.name, resultPath ? @"√" : @"X");
                
            } else {
                NSLog(@" - Texture[%08X]: %@ ∆\n", info.resourceID, info.name);
            }
        }
    }
    
    return YES;
}


- (BOOL)buildDatabaseWithObjInfos:(NSArray *)objFileInfos {
    NSString *configDir = [kAppPath stringByAppendingPathComponent:kConfigDirectory];
    // build db info
    NSMutableSet *dbObjInfoList = [NSMutableSet set];
    NSMutableSet *dbMeshInfoList = [NSMutableSet set];
    NSMutableSet *dbMaterialInfoList = [NSMutableSet set];
    NSMutableSet *dbTextureInfoList = [NSMutableSet set];
    
    for (OBJFileInfo *info in objFileInfos) {
        CEModelInfo *dbObjInfo = [CEModelInfo new];
        dbObjInfo.modelName = info.name;
        dbObjInfo.attributes = info.attributes;
        dbObjInfo.modelID = info.resourceID;
        dbObjInfo.boundsData = [NSData dataWithVector3:info.bounds];
        dbObjInfo.offsetFromOriginData = [NSData dataWithVector3:info.offsetFromOrigin];
        
        NSMutableArray *meshIDs = [NSMutableArray arrayWithCapacity:info.meshInfos.count];
        for (int i = 0; i < info.meshInfos.count; i++) {
            // mesh info
            MeshInfo *meshInfo = info.meshInfos[i];
            CEMeshInfo *dbMeshInfo = [CEMeshInfo new];
            dbMeshInfo.meshID = meshInfo.resourceID;
            dbMeshInfo.materialID = meshInfo.materialInfo.resourceID;
            dbMeshInfo.indiceCount = meshInfo.indiceCount;
            dbMeshInfo.indicePrimaryType = meshInfo.indicePrimaryType;
            dbMeshInfo.drawMode = meshInfo.drawMode;
            [meshIDs addObject:@(dbMeshInfo.meshID)];
            [dbMeshInfoList addObject:dbMeshInfo];
            // material info
            MaterialInfo *mtlInfo = meshInfo.materialInfo;
            CEMaterialInfo *dbMaterialInfo = [CEMaterialInfo new];
            dbMaterialInfo.materialID = mtlInfo.resourceID;
            dbMaterialInfo.ambientColorData = [NSData dataWithVector3:mtlInfo.ambientColor];
            dbMaterialInfo.diffuseColorData = [NSData dataWithVector3:mtlInfo.diffuseColor];
            dbMaterialInfo.specularColorData = [NSData dataWithVector3:mtlInfo.specularColor];
            dbMaterialInfo.shininessExponent = mtlInfo.shininessExponent;
            dbMaterialInfo.transparent = MIN(mtlInfo.transparency > 0 ? mtlInfo.transparency : 1, 1);
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
                diffuseTextureInfo.format = mtlInfo.diffuseTexture.format;
                diffuseTextureInfo.textureSize = mtlInfo.diffuseTexture.size;
                diffuseTextureInfo.hasAlpha = mtlInfo.diffuseTexture.hasAlpha;
                [dbTextureInfoList addObject:diffuseTextureInfo];
            }
            if (mtlInfo.normalTexture) {
                CETextureInfo *normalTextureInfo = [CETextureInfo new];
                normalTextureInfo.textureID = mtlInfo.normalTexture.resourceID;
                normalTextureInfo.format = mtlInfo.normalTexture.format;
                normalTextureInfo.textureSize = mtlInfo.normalTexture.size;
                normalTextureInfo.hasAlpha = mtlInfo.normalTexture.hasAlpha;
                [dbTextureInfoList addObject:normalTextureInfo];
            }
            if (mtlInfo.specularTexture) {
                CETextureInfo *specularTextureInfo = [CETextureInfo new];
                specularTextureInfo.textureID = mtlInfo.specularTexture.resourceID;
                specularTextureInfo.format = mtlInfo.specularTexture.format;
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
    isOK = [modelContext insertObjects:dbObjInfoList.allObjects error:&error];
    if (!isOK || error) {
        NSLog(@"Fail to insert obj info to db: %@\n", [error localizedDescription]);
        [_fileManager removeItemAtPath:dbPath error:nil];
        return NO;
    }
    CEDatabaseContext *meshContext = [CEDatabaseContext contextWithTableName:kDBTableMeshInfo class:[CEMeshInfo class] inDatabase:db];
    isOK = [meshContext insertObjects:dbMeshInfoList.allObjects error:&error];
    if (!isOK || error) {
        NSLog(@"Fail to insert mesh info to db: %@\n", [error localizedDescription]);
        [_fileManager removeItemAtPath:dbPath error:nil];
        return NO;
    }
    CEDatabaseContext *materialContext = [CEDatabaseContext contextWithTableName:kDBTableMaterialInfo class:[CEMaterialInfo class] inDatabase:db];
    isOK = [materialContext insertObjects:dbMaterialInfoList.allObjects error:&error];
    if (!isOK || error) {
        NSLog(@"Fail to insert material info to db: %@\n", [error localizedDescription]);
        [_fileManager removeItemAtPath:dbPath error:nil];
        return NO;
    }
    CEDatabaseContext *textureContext = [CEDatabaseContext contextWithTableName:kDBTableTextureInfo class:[CETextureInfo class] inDatabase:db];
    isOK = [textureContext insertObjects:dbTextureInfoList.allObjects error:&error];
    if (!isOK || error) {
        NSLog(@"Fail to insert texture info to db: %@\n", [error localizedDescription]);
        [_fileManager removeItemAtPath:dbPath error:nil];
        return NO;
    }
    NSLog(@"Write model info to database Successfully!\n");
    
    return YES;
}


#pragma mark - others
- (BOOL)createDirectoryAtPath:(NSString *)directoryPath {
    if (![_fileManager fileExistsAtPath:directoryPath isDirectory:nil]) {
        BOOL isOK = [_fileManager createDirectoryAtPath:directoryPath
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
        NSLog(@"Create directory %@ at:%@\n", isOK ? @"OK" : @"FAIL", directoryPath);
        return isOK;
    }
    return YES;
}


// remove all content in directory
- (void)cleanDirectory:(NSString *)directoryPath {
    BOOL isDirectory = NO;
    BOOL existed = [_fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!existed || !isDirectory) {
        NSLog(@"Warning: directory does not exist at path: %@\n", directoryPath);
    }
    
    NSArray *lastShaderFiles = [_fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString *fileName in lastShaderFiles) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        [_fileManager removeItemAtPath:filePath error:nil];
    }
}


@end










