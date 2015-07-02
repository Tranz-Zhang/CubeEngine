//
//  CEObjFileLoader.m
//  CubeEngine
//
//  Created by chance on 15/4/2.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEObjFileLoader.h"
#import "CEObjParser.h"
#import "CEMtlParser.h"
#import "CEModel_Rendering.h"


@implementation CEObjFileLoader


- (NSSet *)loadModelWithObjFileName:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"obj"];
    if (!filePath) {
        return nil;
    }
    
    CEObjParser *objParser = [CEObjParser parserWithFilePath:filePath];
    NSArray *groups = [objParser parse];
    NSDictionary *materialDict = nil;
    if (objParser.mtlFileName) {
        NSString *mtlPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:objParser.mtlFileName];
        CEMtlParser *mtlParser = [CEMtlParser parserWithFilePath:mtlPath];
        materialDict = [mtlParser parse];
    }
    
    // get the group structure from meshes and create models
    NSMutableDictionary *groupDict = [NSMutableDictionary dictionary];
    for (CEObjMeshInfo *mesh in groups) {
        for (NSString *groupName in mesh.groupNames) {
            NSMutableSet *relativeNames = groupDict[groupName];
            if (!relativeNames) {
                relativeNames = [NSMutableSet set];
                groupDict[groupName] = relativeNames;
            }
            [relativeNames addObject:mesh];
        }
    }
    NSArray *sortedGroupNames = [groupDict keysSortedByValueUsingComparator:^NSComparisonResult(NSSet *set1, NSSet *set2) {
        return set1.count - set2.count;
    }];
    
    NSMutableDictionary *modelDict = [NSMutableDictionary dictionary];
    NSMutableSet *topMostModels = [NSMutableSet set];
    for (NSString *groupName in sortedGroupNames) {
        NSSet *refGroups = groupDict[groupName];
        if (refGroups.count == 1 && !modelDict[[[refGroups anyObject] description]]) {
            // *** create model object ***
            CEObjMeshInfo *mesh = [refGroups anyObject];
            CEVertexBuffer *vertexBuffer = [[CEVertexBuffer alloc] initWithData:mesh.meshData
                                                                     attributes:mesh.attributes];
            CEModel *model = [[CEModel alloc] initWithVertexBuffer:vertexBuffer indicesBuffer:nil];
            model.name = groupName;
            model.material = [materialDict[mesh.materialName] copy];
            if (!model.material) {
                CEMaterial *defaultMaterial = [CEMaterial new];
                defaultMaterial.name = @"DefaultMaterial";
                defaultMaterial.materialType = CEMaterialSolid;
                defaultMaterial.diffuseColor = GLKVector3Make(1.0, 1.0, 1.0);
                model.material = defaultMaterial;
            }
            modelDict[[mesh description]] = model;
            [topMostModels addObject:model];
            
        } else if (refGroups.count > 1) {
            // *** create model group ***
            CEModel *emptyModel = [CEModel new];
            emptyModel.name = groupName;
            
            NSSet *refMeshes = groupDict[groupName];
            [topMostModels enumerateObjectsUsingBlock:^(CEModel *topMostModel, BOOL *stop) {
                NSSet *topMostMeshes = groupDict[topMostModel.name];
                if ([topMostMeshes isSubsetOfSet:refMeshes] &&
                    ![topMostMeshes isEqualToSet:refMeshes]) {
                    [emptyModel addChildObject:topMostModel];
                    [topMostModels removeObject:topMostModel];
                }
            }];
            // dump useless group
            if (emptyModel.childObjects.count) {
                [topMostModels addObject:emptyModel];
            }
        }
    }
    
    //parse material
    
    
    return [topMostModels copy];
}


@end
