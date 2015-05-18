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


#pragma mark - CEObjFileLoader

@implementation CEObjFileLoader  {
    CEObjParser *_objParser;
    CEMtlParser *_mtlParser;
}


- (NSSet *)loadModelWithObjFileName:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"obj"];
    if (!filePath) {
        return nil;
    }
    if (![filePath isEqualToString:_objParser.filePath]) {
        _objParser = [CEObjParser parserWithFilePath:filePath];
    }
    NSArray *groups = [_objParser parse];
    
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
    
    return [topMostModels copy];
}


@end
