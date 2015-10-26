//
//  CEModelLoader.m
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEModelLoader.h"
#import "CEDB.h"
#import "CEResourceDefines.h"
#import "CEResourceManager.h"
#import "CETextureManager.h"

#import "CEModelInfo.h"
#import "CEMeshInfo.h"
#import "CEMaterialInfo.h"
#import "CETextureInfo.h"
#import "CERenderObject.h"
#import "CEModel_Rendering.h"

@interface CEModelLoadingCache : NSObject

// basic info
@property (nonatomic, strong) CEModelInfo *modelInfo;
@property (nonatomic, strong) NSDictionary *meshInfoDict;       // {@(meshID) : CEMeshInfo}
@property (nonatomic, strong) NSDictionary *materialInfoDict;   // @{@(materialID) : CEMaterialInfo}
@property (nonatomic, copy) CEModelLoadingCompletion completion;

// loading resources
@property (nonatomic, strong) CEVertexBuffer *vertexBuffer;
@property (nonatomic, strong) NSDictionary *indiceBufferDict;   // {@(meshID) : CEIndiceBuffer}
@property (nonatomic, strong) NSSet *loadedTextureIds;

@end

@implementation CEModelLoadingCache

@end



@implementation CEModelLoader {
    CEDatabase *_db;
    CEDatabaseContext *_modelContext;
    CEDatabaseContext *_meshContext;
    CEDatabaseContext *_materialContext;
    CEDatabaseContext *_textureContext;
    NSMutableDictionary *_modelLoadingDict;
}


+ (instancetype)defaultLoader {
    static CEModelLoader *_shareInstance;
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[[self class] alloc] init];
        });
    }
    return _shareInstance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *bundlePath = [NSBundle mainBundle].bundlePath;
        NSString *configDirectory = [bundlePath stringByAppendingPathComponent:kConfigDirectory];
        _db = [CEDatabase databaseWithName:kResourceInfoDBName inPath:configDirectory];
        _modelContext = [CEDatabaseContext contextWithTableName:kDBTableModelInfo class:[CEModelInfo class] inDatabase:_db];
        _meshContext = [CEDatabaseContext contextWithTableName:kDBTableMeshInfo class:[CEMeshInfo class] inDatabase:_db];
        _materialContext = [CEDatabaseContext contextWithTableName:kDBTableMaterialInfo class:[CEMaterialInfo class] inDatabase:_db];
        _textureContext = [CEDatabaseContext contextWithTableName:kDBTableTextureInfo class:[CETextureInfo class] inDatabase:_db];
        
        _modelLoadingDict = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)loadModelWithName:(NSString *)name completion:(void (^)(CEModel *))completion {
    CEModelInfo *model = (CEModelInfo *)[_modelContext queryById:name error:nil];
    if (!model) {
        CEError(@"Fail to get model info: %@", name);
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
        return;
    }
    
    // build loading cache
    CEModelLoadingCache *loadingCache = [CEModelLoadingCache new];
    loadingCache.modelInfo = model;
    loadingCache.completion = completion;
    
    // 1.collect neccessary infomations for the model
    NSMutableDictionary *meshInfoDict = [NSMutableDictionary dictionary];       // {@(meshID) : CEMeshInfo}
    NSMutableDictionary *materialInfoDict = [NSMutableDictionary dictionary];   // @{@(materialID) : CEMaterialInfo}
    NSMutableArray *textureInfos = [NSMutableArray array];
    for (NSNumber *meshID in model.meshIDs) {
        // get CEMeshInfo
        CEMeshInfo *meshInfo = (CEMeshInfo *)[_meshContext queryById:meshID error:nil];
        meshInfoDict[meshID] = meshInfo;
        
        // get CEMaterial
        CEMaterialInfo *materialInfo = (CEMaterialInfo *)[_materialContext queryById:@(meshInfo.materialID) error:nil];
        materialInfoDict[@(meshInfo.materialID)] = materialInfo;
        
        // get CETextureInfo
        CETextureInfo *diffuseTexture = (CETextureInfo *)[_textureContext queryById:@(materialInfo.diffuseTextureID) error:nil];
        if (diffuseTexture) {
            [textureInfos addObject:diffuseTexture];
        }
        CETextureInfo *normalTexture = (CETextureInfo *)[_textureContext queryById:@(materialInfo.normalTextureID) error:nil];
        if (normalTexture) {
            [textureInfos addObject:normalTexture];
        }
        CETextureInfo *specularTexture = (CETextureInfo *)[_textureContext queryById:@(materialInfo.specularTextureID) error:nil];
        if (specularTexture) {
            [textureInfos addObject:specularTexture];
        }
    }
    loadingCache.meshInfoDict = meshInfoDict.copy;
    loadingCache.materialInfoDict = materialInfoDict.copy;
    _modelLoadingDict[@(loadingCache.modelInfo.modelID)] = loadingCache;
    
    [self loadModelDataForCache:loadingCache];
    [self loadTextureDataWithTextureInfos:textureInfos.copy forCache:loadingCache];
}



- (void)loadModelDataForCache:(CEModelLoadingCache *)cache {
    NSMutableArray *resourceIDs = [NSMutableArray array];
    [resourceIDs addObject:@(cache.modelInfo.modelID)];
    [resourceIDs addObjectsFromArray:cache.modelInfo.meshIDs];
    uint32_t cacheID = cache.modelInfo.modelID;
    [[CEResourceManager sharedManager] loadResourceDataWithIDs:resourceIDs completion:^(NSDictionary *resourceDataDict) {
        CEModelLoadingCache *loadingCache = _modelLoadingDict[@(cacheID)];
        if (!loadingCache) return;
        
        // get vertexData
        CEModelInfo *model = loadingCache.modelInfo;
        NSData *vertexData = resourceDataDict[@(model.modelID)];
        if (!vertexData.length) {
            [self onCompleteLoadingForCacheID:cacheID];
            return;
        }
        loadingCache.vertexBuffer = [[CEVertexBuffer alloc] initWithData:vertexData attributes:model.attributes];
        
        // get indice Data
        NSMutableDictionary *indiceBufferDict = [NSMutableDictionary dictionary];
        [loadingCache.meshInfoDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *meshID, CEMeshInfo *meshInfo, BOOL *stop) {
            NSData *indiceData = resourceDataDict[meshID];
            if (indiceData.length) {
                CEIndiceBuffer *indiceBuffer = [[CEIndiceBuffer alloc] initWithData:indiceData
                                                                        indiceCount:meshInfo.indiceCount
                                                                        primaryType:meshInfo.indicePrimaryType
                                                                           drawMode:meshInfo.drawMode];
                indiceBufferDict[meshID] = indiceBuffer;
            }
        }];
        loadingCache.indiceBufferDict = indiceBufferDict.copy;
        
        if (loadingCache.loadedTextureIds) {
            [self onCompleteLoadingForCacheID:cacheID];
        }
    }];
}


- (void)loadTextureDataWithTextureInfos:(NSArray *)textureInfos forCache:(CEModelLoadingCache *)cache {
    uint32_t cacheID = cache.modelInfo.modelID;
    [[CETextureManager sharedManager] loadTextureWithInfos:textureInfos completion:^(NSSet *loadedTextureIds) {
        CEModelLoadingCache *loadingCache = _modelLoadingDict[@(cacheID)];
        if (!loadingCache) return;
        
        loadingCache.loadedTextureIds = loadedTextureIds;
        if (loadingCache.vertexBuffer || loadingCache.indiceBufferDict) {
            [self onCompleteLoadingForCacheID:cacheID];
        }
    }];
}


- (void)onCompleteLoadingForCacheID:(uint32_t)cacheID {
    CEModelLoadingCache *cache = _modelLoadingDict[@(cacheID)];
    [_modelLoadingDict removeObjectForKey:@(cacheID)];
    if (!cache.vertexBuffer || !cache.indiceBufferDict.count) {
        if (cache.completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cache.completion(nil);
            });
        }
        CEError(@"Fail to get model buffer data: %@", cache.modelInfo.modelName);
        return;
    }
    
    // try to build CEModel with cache
    NSMutableArray *renderObjects = [NSMutableArray array];
    for (CEMeshInfo *meshInfo in cache.meshInfoDict.allValues) {
        CERenderObject *renderObject = [CERenderObject new];
        renderObject.vertexBuffer = cache.vertexBuffer;
        renderObject.indiceBuffer = cache.indiceBufferDict[@(meshInfo.meshID)];
        if (!renderObject.indiceBuffer) {
            if (cache.completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cache.completion(nil);
                });
            }
            CEError(@"Fail to get mesh's indece data: %@-%08X",  cache.modelInfo.modelName, meshInfo.meshID);
            return;
        }
        
        CEMaterialInfo *materialInfo = cache.materialInfoDict[@(meshInfo.materialID)];
        CEMaterial *material = [CEMaterial new];
        material.materialType = materialInfo.materialType;
        material.ambientColor = [self vector3WithData:materialInfo.ambientColorData];
        material.diffuseColor = [self vector3WithData:materialInfo.diffuseColorData];
        material.specularColor = [self vector3WithData:materialInfo.specularColorData];
        material.shininessExponent = materialInfo.shininessExponent;
        material.transparency = materialInfo.transparent;
        if ([cache.loadedTextureIds containsObject:@(materialInfo.diffuseTextureID)]) {
            material.diffuseTextureID = materialInfo.diffuseTextureID;
        }
        if ([cache.loadedTextureIds containsObject:@(materialInfo.normalTextureID)]) {
            material.normalTextureID = materialInfo.normalTextureID;
        }
        if ([cache.loadedTextureIds containsObject:@(materialInfo.specularTextureID)]) {
            material.specularTextureID = materialInfo.specularTextureID;
        }
        renderObject.material = material;
        [renderObjects addObject:renderObject];
    }
    
    if (cache.completion) {
        CEModel *model = [[CEModel alloc] initWithRenderObjects:renderObjects.copy];
        if (cache.modelInfo.boundsData) {
            model.bounds = GLKVector3MakeWithData(cache.modelInfo.boundsData);
        }
        if (cache.modelInfo.offsetFromOriginData) {
            model.offsetFromOrigin = GLKVector3MakeWithData(cache.modelInfo.offsetFromOriginData);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            cache.completion(model);
        });
    }
}


- (GLKVector3)vector3WithData:(NSData *)vectorData {
    GLKVector3 vec3;
    [vectorData getBytes:vec3.v length:sizeof(GLKVector3)];
    return vec3;
}


@end

