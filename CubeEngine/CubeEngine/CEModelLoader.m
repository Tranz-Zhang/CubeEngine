//
//  CEModelLoader.m
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEModelLoader.h"
#import "CEResourcesDefines.h"
#import "CEDB.h"
#import "CEModelInfo.h"
#import "CEMeshInfo.h"
#import "CEMaterialInfo.h"
#import "CETextureInfo.h"

@implementation CEModelLoader {
    CEDatabase *_db;
    CEDatabaseContext *_objContext;
    CEDatabaseContext *_meshContext;
    CEDatabaseContext *_materialContext;
    CEDatabaseContext *_textureContext;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *bundlePath = [NSBundle mainBundle].bundlePath;
        NSString *configDirectory = [bundlePath stringByAppendingPathComponent:kConfigDirectory];
        _db = [CEDatabase databaseWithName:kResourcesDatabaseName inPath:configDirectory];
        _objContext = [CEDatabaseContext contextWithTableName:@"obj_info" class:[CEModelInfo class] inDatabase:_db];
        _meshContext = [CEDatabaseContext contextWithTableName:@"mesh_info" class:[CEMeshInfo class] inDatabase:_db];
        _materialContext = [CEDatabaseContext contextWithTableName:@"material_info" class:[CEMaterialInfo class] inDatabase:_db];
        _textureContext = [CEDatabaseContext contextWithTableName:@"texture_info" class:[CETextureInfo class] inDatabase:_db];
    }
    return self;
}

- (void)loadModelWithName:(NSString *)name {
    CEModelInfo *model = (CEModelInfo *)[_objContext queryById:name error:nil];
    if (!model) return;
    NSMutableArray *meshes = [NSMutableArray array];
    NSMutableArray *materials = [NSMutableArray array];
    for (NSNumber *meshID in model.meshIDs) {
        CEMeshInfo *meshInfo = (CEMeshInfo *)[_meshContext queryById:meshID error:nil];
        if (meshInfo) {
            [meshes addObject:meshInfo];
        }
        
        CEMaterialInfo *material = (CEMaterialInfo *)[_materialContext queryById:@(meshInfo.materialID) error:nil];
        if (material) {
            [materials addObject:material];
        }
    }
    
    
    printf("");
}



@end
