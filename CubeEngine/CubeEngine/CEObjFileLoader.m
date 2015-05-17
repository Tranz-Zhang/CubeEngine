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
    
    NSMutableArray *_vertices;
    NSMutableArray *_textureCoordinates;
    NSMutableArray *_normals;
    NSMutableArray *_indices;
}


- (CEModel *)loadModelWithObjFileName:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"obj"];
    if (!filePath) {
        return nil;
    }
    if (![filePath isEqualToString:_objParser.filePath]) {
        _objParser = [CEObjParser parserWithFilePath:filePath];
    }
    NSArray *groups = [_objParser parse];
    
    // sort groups
    // [A B], [A C] -> @{A : [B C]}, @{B : [A]}, @{C : [A]}
    NSMutableDictionary *groupDict = [NSMutableDictionary dictionary];
    for (CEObjMeshGroup *group in groups) {
        for (NSString *groupName in group.groupNames) {
            NSMutableSet *relativeNames = groupDict[groupName];
            if (!relativeNames) {
                relativeNames = [NSMutableSet set];
                groupDict[groupName] = relativeNames;
            }
            NSMutableArray *otherNames = group.groupNames.mutableCopy;
            [otherNames removeObject:groupName];
            [relativeNames addObjectsFromArray:otherNames];
        }
    }
    
    // transfer to models
    NSMutableSet *topMostModels = [NSMutableSet set];
    NSMutableDictionary *modelDict = [NSMutableDictionary dictionaryWithCapacity:groupDict.count];
    [groupDict enumerateKeysAndObjectsUsingBlock:^(NSString *groupName, NSArray *relativeNames, BOOL *stop) {
        CEModel *model = modelDict[groupName];
        if (!model) { // create new model
            if (relativeNames.count == 1) {
                // leaf model(child model). created with vertexData
                CEObjMeshGroup *refGroup = nil;
                for (CEObjMeshGroup *group in groups) {
                    if ([group.groupNames containsObject:groupName]) {
                        refGroup = group;
                        break;
                    }
                }
                if (refGroup) {
                    CEVertexBuffer *vertexBuffer = [[CEVertexBuffer alloc] initWithData:refGroup.meshData
                                                                             attributes:refGroup.attributes];
                    model = [[CEModel alloc] initWithVertexBuffer:vertexBuffer indicesBuffer:nil];
                    model.name = groupName;
                }
                
            } else {
                // create empty model
                model = [CEModel new];
                model.name = groupName;
            }
        }
        
        if (model) {
            for (NSString *otherModelName in relativeNames) {
                CEModel *otherModel = modelDict[otherModelName];
                if (!otherModel) continue;
                if (relativeNames.count < [groupDict[otherModelName] count]) { // as child
                    [otherModel addChildObject:model];
                    
                } else if (relativeNames.count > [groupDict[otherModelName] count]) { // as parent
                    [model addChildObject:otherModel];
                }
            }
            modelDict[groupName] = model;
            
            // check top most model
            CEModel *topMostModel = [topMostModels anyObject];
            if (topMostModel.childObjects.count < model.childObjects.count) {
                [topMostModels removeAllObjects];
                [topMostModels addObject:model];
                
            } else if (topMostModel.childObjects.count == model.childObjects.count) {
                [topMostModels addObject:model];
            }
        }
    }];

    groupDict = [NSMutableDictionary dictionary];
    for (CEObjMeshGroup *group in groups) {
        for (NSString *groupName in group.groupNames) {
            NSMutableSet *relativeNames = groupDict[groupName];
            if (!relativeNames) {
                relativeNames = [NSMutableSet set];
                groupDict[groupName] = relativeNames;
            }
            [relativeNames addObject:group];
        }
    }
    NSArray *sortedGroupNames = [groupDict keysSortedByValueUsingComparator:^NSComparisonResult(NSSet *set1, NSSet *set2) {
        return set1.count - set2.count;
    }];

    NSMutableArray *models = [NSMutableArray array];
    modelDict = [NSMutableDictionary dictionary];
    for (NSString *groupName in sortedGroupNames) {
        NSSet *refGroups = groupDict[groupName];
        if (refGroups.count == 1 && !modelDict[[[refGroups anyObject] description]]) { // create model object
            CEObjMeshGroup *refGroup = [refGroups anyObject];
            CEVertexBuffer *vertexBuffer = [[CEVertexBuffer alloc] initWithData:refGroup.meshData
                                                                     attributes:refGroup.attributes];
            CEModel *model = [[CEModel alloc] initWithVertexBuffer:vertexBuffer indicesBuffer:nil];
            model.name = groupName;
            modelDict[[refGroup description]] = model;
            [models addObject:model];
            
        } else if (refGroups.count > 1) { // create model group
            CEModel *emptyModel = [CEModel new];
            emptyModel.name = groupName;
            for (CEObjMeshGroup *group in refGroups) {
                CEModel *model = modelDict[[group description]];
                
                if (!model) continue;
                if (model.parentObject) {
                    NSSet *parentRefGroups = groupDict[[(CEModel *)model.parentObject name]];
                    if ([parentRefGroups isSubsetOfSet:refGroups]) {
                        [emptyModel addChildObject:model.parentObject];
                        
                    } else {
                        
                    }
                    
                } else {
                    [emptyModel addChildObject:model];
                }
            }
            [models addObject:emptyModel];
        }
        
    }
    
    return [topMostModels anyObject];
}


- (void)cleanUp {
    _vertices = nil;
    _textureCoordinates = nil;
    _normals = nil;
}


#pragma mark - others

- (NSData *)dataWithFloatStringList:(NSArray *)floatStringList {
    NSMutableData *valueData = [NSMutableData data];
    for (NSString *floatString in floatStringList) {
        float value = [floatString floatValue];
        [valueData appendBytes:&value length:sizeof(float)];
    }
    return valueData;
}


// 根据索引获取对应的坐标，纹理，法线等值，组成NSData返回
- (NSData *)vertexElementDataWithIndies:(NSString *)elementIndies {
    NSArray *indies = [elementIndies componentsSeparatedByString:@"/"];
    NSMutableData *elementData = [NSMutableData data];
    [indies enumerateObjectsUsingBlock:^(NSString *indexString, NSUInteger idx, BOOL *stop) {
        if (indexString.length) {
            NSInteger index = [indexString integerValue] - 1;
            switch (idx) {
                case 0: // vertex
                    [elementData appendData:_vertices[index]];
                    break;
                    
                case 1: // texture coordinate
                    [elementData appendData:_textureCoordinates[index]];
                    break;
                    
                case 2: // normal
                    [elementData appendData:_normals[index]];
                    break;
                    
                default:
                    break;
            }
        }
    }];
    return elementData;
}


- (NSArray *)vertexAttributesWithFaceAttributes:(NSString *)attributeString {
    NSArray *indices = [attributeString componentsSeparatedByString:@"/"];
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:indices.count];
    if (indices.count >= 1) { // add position
        [attributes addObject:[CEVBOAttribute attributeWithname:CEVBOAttributePosition]];
    }
    if (indices.count >= 2) {
        if ([indices[1] length]) {
            [attributes addObject:[CEVBOAttribute attributeWithname:CEVBOAttributeTextureCoord]];
        } else {
            [attributes addObject:[CEVBOAttribute attributeWithname:CEVBOAttributeNormal]];
        }
    }
    if (indices.count >= 3 && [indices[1] length]) {
       [attributes addObject:[CEVBOAttribute attributeWithname:CEVBOAttributeNormal]];
    }
    
    return [attributes copy];
}


@end
