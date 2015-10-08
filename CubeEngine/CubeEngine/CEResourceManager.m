//
//  CEResourceManager.m
//  CubeEngine
//
//  Created by chance on 9/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEResourceManager.h"
#import "CEResourcesDefines.h"

// db
#import "CEDB.h"
#import "CEModelInfo.h"
#import "CEMeshInfo.h"
#import "CEMaterialInfo.h"
#import "CETextureInfo.h"



@implementation CEResourceManager {
    CEDatabase *_db;
    CEDatabaseContext *_objContext;
    CEDatabaseContext *_meshContext;
    CEDatabaseContext *_materialContext;
    CEDatabaseContext *_textureContext;
}


+ (instancetype)sharedManager {
    static CEResourceManager *_shareInstance;
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[[self class] alloc] init];
        });
    }
    return _shareInstance;
}


- (void)testLoadModel {
    CEModelInfo *model = (CEModelInfo *)[_objContext queryById:@"ram_original" error:nil];
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


