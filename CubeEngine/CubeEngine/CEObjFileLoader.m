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
#import "CEVertexBuffer_DEPRECATED.h"
#import "CEIndicesBuffer_DEPRECATED.h"
#import "CEVBOAttribute.h"


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
            CEMaterial *material = [materialDict[mesh.materialName] copy];
            NSData *vertexData = nil;
            NSArray *attributes = nil;
            if (material.normalTexture.length) {
                // add tangent & bitangent vertext
                vertexData = [self calculateTangentAndBitangentWithData:mesh.meshData attributes:mesh.attributes];
                NSMutableArray *attributeNames = [NSMutableArray array];
                for (CEVBOAttribute *attribute in mesh.attributes) {
                    [attributeNames addObject:@(attribute.name)];
                }
                [attributeNames addObject:@(CEVBOAttributeTangent)];
//                [attributeNames addObject:@(CEVBOAttributeBitangent)];
                attributes = [CEVBOAttribute attributesWithNames:attributeNames];
                
            } else {
                vertexData = mesh.meshData;
                attributes = mesh.attributes;
            }
            
            CEVertexBuffer_DEPRECATED *vertexBuffer = [[CEVertexBuffer_DEPRECATED alloc] initWithData:vertexData attributes:attributes];
            CEModel *model = nil;//[[CEModel alloc] initWithVertexBuffer:vertexBuffer indicesBuffer:nil];
            model.name = groupName;
            if (!material) {
                material = [CEMaterial new];
                material.name = @"DefaultMaterial";
                material.materialType = CEMaterialSolid;
                material.diffuseColor = GLKVector3Make(1.0, 1.0, 1.0);
            }
            model.material = material;
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


- (NSData *)calculateTangentAndBitangentWithData:(NSData *)vertexData attributes:(NSArray *)attributes {
    CEVBOAttribute *positionAttrib, *textureAttrib;
    for (CEVBOAttribute *attribute in attributes) {
        if (attribute.name == CEVBOAttributePosition) {
            positionAttrib = attribute;
            continue;
        }
        if (attribute.name == CEVBOAttributeUV) {
            textureAttrib = attribute;
            continue;
        }
    }
    int stride = positionAttrib.elementStride;
    if (!positionAttrib || !textureAttrib || !vertexData.length ||
        vertexData.length % (stride * 3)) {
        CEError(@"Fail to calculate tangent and bitangent data.");
        return nil;
    }
    
    int vertexCount = (int)vertexData.length / stride / 3;
    int offset = 0;
    NSMutableData *newVertexData = [NSMutableData data];
    for (int i = 0; i < vertexCount; i++) {
        GLKVector3 v[3];
        GLKVector2 uv[3];
        for (int idx = 0; idx < 3; idx++) {
            [vertexData getBytes:v[idx].v range:NSMakeRange(offset + positionAttrib.elementOffset, 12)];
            [vertexData getBytes:uv[idx].v range:NSMakeRange(offset + textureAttrib.elementOffset, 8)];
            offset += stride;
        }
        
        GLKVector3 deltaPos1 = GLKVector3Subtract(v[0], v[1]);
        GLKVector3 deltaPos2 = GLKVector3Subtract(v[0], v[2]);
        GLKVector2 deltaUV1 = GLKVector2Subtract(uv[1], uv[0]);
        GLKVector2 deltaUV2 = GLKVector2Subtract(uv[2], uv[0]);
        float r = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV1.y * deltaUV2.x);
        // tangent = (deltaPos1 * deltaUV2.y   - deltaPos2 * deltaUV1.y) * r
//        GLKVector3 tangent = GLKVector3MultiplyScalar(GLKVector3Subtract(GLKVector3MultiplyScalar(deltaPos1, deltaUV2.y),
//                                                                         GLKVector3MultiplyScalar(deltaPos2, deltaUV1.y)), r);
        GLKVector3 tangent;
        tangent.x = (deltaPos1.x * deltaUV2.y + deltaPos2.x * deltaUV1.y) * r;
        tangent.y = (deltaPos1.y * deltaUV2.y + deltaPos2.y * deltaUV1.y) * r;
        tangent.z = (deltaPos1.z * deltaUV2.y + deltaPos2.z * deltaUV1.y) * r;
        tangent = GLKVector3Normalize(tangent);

        offset -= 3 * stride;
        for (int idx = 0; idx < 3; idx++) {
            [newVertexData appendData:[vertexData subdataWithRange:NSMakeRange(offset, stride)]];
            [newVertexData appendBytes:tangent.v length:sizeof(tangent)];
            offset += stride;
        }
    }
    return newVertexData.copy;
}


@end
