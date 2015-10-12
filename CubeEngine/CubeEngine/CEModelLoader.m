//
//  CEModelLoader.m
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEModelLoader.h"
#import "CEResourceDefines.h"
#import "CEDB.h"
#import "CEModelInfo.h"
#import "CEMeshInfo.h"
#import "CEMaterialInfo.h"
#import "CETextureInfo.h"
#import "CERenderObject.h"
#import "CEResourceManager.h"

@implementation CEModelLoader {
    CEDatabase *_db;
    CEDatabaseContext *_modelContext;
    CEDatabaseContext *_meshContext;
    CEDatabaseContext *_materialContext;
    CEDatabaseContext *_textureContext;
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
    }
    return self;
}


- (void)loadModelWithName:(NSString *)name completion:(void (^)(CEModel *))completion {
    CEModelInfo *model = (CEModelInfo *)[_modelContext queryById:name error:nil];
    if (!model) return;
    
    /** create CERenderObject
    NSMutableDictionary *renderObjectDict = [NSMutableDictionary dictionary]; // {@(MeshID) : CERenderObject}
    NSMutableDictionary *meshInfoDict = [NSMutableDictionary dictionary];   // {@(MeshID) : CEMeshInfo}
    NSMutableArray *textureInfos = [NSMutableArray array];
    for (NSNumber *meshID in model.meshIDs) {
        CERenderObject *renderObject = [CERenderObject new];
        
        CEMeshInfo *meshInfo = (CEMeshInfo *)[_meshContext queryById:meshID error:nil];
        CEMaterialInfo *materialInfo = (CEMaterialInfo *)[_materialContext queryById:@(meshInfo.materialID) error:nil];
        CEMaterial *material = [CEMaterial new];
        material.materialType = materialInfo.materialType;
        material.diffuseTextureID = materialInfo.diffuseTextureID;
        material.normalTextureID = materialInfo.normalTextureID;
        material.specularTextureID = materialInfo.specularTextureID;
        material.ambientColor = [self vector3WithData:materialInfo.ambientColorData];
        material.diffuseColor = [self vector3WithData:materialInfo.diffuseColorData];
        material.specularColor = [self vector3WithData:materialInfo.specularColorData];
        material.shininessExponent = materialInfo.shininessExponent;
        material.transparency = materialInfo.transparent;
        renderObject.material = material;
        
        // get texture Infos
        CETextureInfo *diffuseTexture = (CETextureInfo *)[_textureContext queryById:@(materialInfo.diffuseTextureID) error:nil];
        if (diffuseTexture) {
            [textureInfos addObject:diffuseTexture];
        }
        
        meshInfoDict[meshID] = meshInfo;
        renderObjectDict[meshID] = renderObject;
    }
    //*/
     
    // load model data
    NSMutableArray *resourceIDs = [NSMutableArray array];
    [resourceIDs addObject:@(model.vertexDataID)];
    [resourceIDs addObjectsFromArray:model.meshIDs];
    
    
    [[CEResourceManager sharedManager] loadResourceDataWithIDs:resourceIDs completion:^(NSDictionary *resourceDataDict) {
        // get vertexData
        NSData *vertexData = resourceDataDict[@(model.vertexDataID)];
        if (!vertexData.length) {
            if (completion) completion(nil);
            return;
        }
        CEVertexBuffer *vertexBuffer = [[CEVertexBuffer alloc] initWithData:vertexData attributes:model.attributes];
        NSMutableArray *renderObjects = [NSMutableArray array];
        for (NSNumber *meshID in model.meshIDs) {
            CERenderObject *renderObject = [CERenderObject new];
            renderObject.vertexBuffer = vertexBuffer;
            // create indice buffer
            CEMeshInfo *meshInfo = (CEMeshInfo *)[_meshContext queryById:meshID error:nil];
            NSData *indiceData = resourceDataDict[meshID];
            if (!indiceData.length) {
                continue;
            }
            CEIndiceBuffer *indiceBuffer = [[CEIndiceBuffer alloc] initWithData:indiceData
                                                                    primaryType:meshInfo.indicePrimaryType
                                                                       drawMode:meshInfo.drawMode];
            renderObject.indexBuffer = indiceBuffer;
            // get material
            CEMaterialInfo *materialInfo = (CEMaterialInfo *)[_materialContext queryById:@(meshInfo.materialID) error:nil];
            CEMaterial *material = [CEMaterial new];
            material.materialType = materialInfo.materialType;
            material.diffuseTextureID = materialInfo.diffuseTextureID;
            material.normalTextureID = materialInfo.normalTextureID;
            material.specularTextureID = materialInfo.specularTextureID;
            material.ambientColor = [self vector3WithData:materialInfo.ambientColorData];
            material.diffuseColor = [self vector3WithData:materialInfo.diffuseColorData];
            material.specularColor = [self vector3WithData:materialInfo.specularColorData];
            material.shininessExponent = materialInfo.shininessExponent;
            material.transparency = materialInfo.transparent;
            renderObject.material = material;
            // load texture for material
            
            
            [renderObjects addObject:renderObject];
        }
        
        if (completion) {
            completion(nil);
        }
    }];

}

- (GLKVector3)vector3WithData:(NSData *)vectorData {
    GLKVector3 vec3;
    [vectorData getBytes:vec3.v length:sizeof(GLKVector3)];
    return vec3;
}

/**
 @property (nonatomic, strong) NSString *name;
 @property (nonatomic, assign) CEMaterialType materialType;
 
 @property (nonatomic, strong) NSString *diffuseTexture;
 @property (nonatomic, strong) NSString *normalTexture;
 
 @property (nonatomic, assign) uint32_t diffuseTextureID;
 @property (nonatomic, assign) uint32_t normalTextureID;
 
 @property (nonatomic, assign) GLKVector3 ambientColor;
 @property (nonatomic, assign) GLKVector3 diffuseColor; // base color
 @property (nonatomic, assign) GLKVector3 specularColor;
 @property (nonatomic, assign) float shininessExponent;
 
 @property (nonatomic, assign) float transparency;
 */


@end
