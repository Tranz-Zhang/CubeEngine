//
//  ObjFileParser.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "OBJFileParser.h"
#import "MTLFileParser.h"
#import "CEVBOAttribute.h"

#define kDefaultMTLName @"defaultMTL"

@implementation OBJFileParser {
    // use only for parsing data
    OBJFileInfo *_objInfo;
    VectorList *_allPositionList;
    VectorList *_allUVList;
    VectorList *_allNormalList;
    BOOL _hasNormalMap;
    NSMutableDictionary *_indicesDict;
}


+ (OBJFileParser *)dataParser {
    return [[OBJFileParser alloc] init];
}


#pragma mark - info parsing

+ (OBJFileInfo *)parseBaseInfoWithFilePath:(NSString *)filePath {
    NSError *error;
    NSString *objContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    NSArray *lines = [objContent componentsSeparatedByString:@"\n"];
    
    // parse MTL file info
    NSString *mtlFileName;
    NSMutableSet *usedMtlNames = [NSMutableSet set];
    for (NSString *lineContent in lines) {
        // mtl file name
        if ([lineContent hasPrefix:@"mtllib"]) {
            mtlFileName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            continue;
        }
        
        // reference material
        if ([lineContent hasPrefix:@"usemtl"]) {
            NSString *materialName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            [usedMtlNames addObject:materialName];
            continue;
        }
    }
    NSMutableDictionary *mtlDict = [NSMutableDictionary dictionary];
    MaterialInfo *defaultMtlInfo = [MaterialInfo new]; // default material
    defaultMtlInfo.name = kDefaultMTLName;
    defaultMtlInfo.diffuseColor = GLKVector3Make(0.8, 0.8, 0.8);
    
    mtlDict[kDefaultMTLName] = defaultMtlInfo;
    if (mtlFileName.length) {
        NSString *currentDirectory = [filePath stringByDeletingLastPathComponent];
        NSString *mtlFilePath = [currentDirectory stringByAppendingPathComponent:mtlFileName];
        MTLFileParser *mtlParser = [MTLFileParser parserWithFilePath:mtlFilePath];
        NSDictionary *allMTLDict = [mtlParser parse];
        NSMutableDictionary *usedMtlDict = [NSMutableDictionary dictionary];
        for (NSString *mtlName in usedMtlNames) {
            if (allMTLDict[mtlName]) {
                usedMtlDict[mtlName] = allMTLDict[mtlName];
            }
        }
        [mtlDict addEntriesFromDictionary:usedMtlDict];
    }
    
    // parsing data
    NSString *fileName = [filePath lastPathComponent];
    fileName = [fileName substringToIndex:fileName.length - 4];
    OBJFileInfo *objInfo = [[OBJFileInfo alloc] init];
    objInfo.name = fileName;
    objInfo.filePath = filePath;
    
    NSMutableArray *meshInfoList = [NSMutableArray array];
    // create default group name
    MeshInfo *currentMesh = [MeshInfo new];
    currentMesh.groupNames = @[@"DefaultGroup"];
    currentMesh.indicesList = [NSMutableArray array];
    [meshInfoList addObject:currentMesh];
    for (NSString *lineContent in lines) {
        // parse group "g group1 pPipe1 group2"
        if ([lineContent hasPrefix:@"g "] || [lineContent hasPrefix:@"o "]) {
            NSString *valueString = [lineContent substringFromIndex:2];
            NSArray *groupNames = [valueString componentsSeparatedByString:@" "];
            MeshInfo *newMesh = [MeshInfo new];
            newMesh.groupNames = groupNames;
            newMesh.indicesList = [NSMutableArray array];
            [meshInfoList addObject:newMesh];
            currentMesh = newMesh;
            continue;
        }
        
        // mtl file name
        if ([lineContent hasPrefix:@"mtllib"]) {
            objInfo.mtlFileName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            continue;
        }
        
        // reference material
        if ([lineContent hasPrefix:@"usemtl"]) {
            NSString *materialName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            MaterialInfo *mtlInfo = mtlDict[materialName];
            if (!mtlInfo) {
                mtlInfo = mtlDict[kDefaultMTLName];
            }
            currentMesh.materialInfo = mtlInfo;
            continue;
        }
        
        if (!currentMesh.indiceCount && [lineContent hasPrefix:@"f "]) {
            NSString *content = [lineContent substringFromIndex:2];
            NSArray *indexStringList = [content componentsSeparatedByString:@" "];
            if (!objInfo.attributes) {
                objInfo.attributes = [self vertexAttributesWithFaceAttributes:indexStringList[0]];
            }
            currentMesh.indiceCount = 1;
        }
    }
    
    // remove useless groups &
    NSMutableArray *filteredMeshes = [NSMutableArray array];
    for (MeshInfo *mesh in meshInfoList) {
        if (mesh.groupNames.count && mesh.indiceCount) {
            [filteredMeshes addObject:mesh];
            if (!mesh.materialInfo) {
                mesh.materialInfo = mtlDict[kDefaultMTLName];
            }
        }
    }
    
    // get mesh name
    NSMutableDictionary *groupNameCountDict = [NSMutableDictionary dictionary]; // @{groupName: nameCount}
    for (MeshInfo *mesh in filteredMeshes) {
        for (NSString *groupName in mesh.groupNames) {
            NSNumber *nameCount = groupNameCountDict[groupName];
            if (nameCount) {
                groupNameCountDict[groupName] = @(nameCount.intValue + 1);
            } else {
                groupNameCountDict[groupName] = @(1);
            }
        }
    }
    NSMutableSet *duplicatedNames = [NSMutableSet set];
    [groupNameCountDict enumerateKeysAndObjectsUsingBlock:^(NSString *groupName, NSNumber *nameCount, BOOL *stop) {
        if (nameCount.intValue > 1) {
            [duplicatedNames addObject:groupName];
        }
    }];
    for (MeshInfo *mesh in filteredMeshes) {
        NSString *meshName = nil;
        for (NSString *groupName in mesh.groupNames) {
            if (![duplicatedNames containsObject:groupName]) {
                meshName = groupName;
                break;
            }
        }
        mesh.name = meshName;
    }
    
    // generate mesh, material, texture names
    NSMutableSet *mtlInfoSet = [NSMutableSet set];
    NSMutableSet *textureSet = [NSMutableSet set];
    for (MeshInfo *mesh in filteredMeshes) {
        mesh.name = [NSString stringWithFormat:@"%@_%@", objInfo.name, mesh.name];
        [mtlInfoSet addObject:mesh.materialInfo];
        if (mesh.materialInfo.diffuseTexture)     [textureSet addObject:mesh.materialInfo.diffuseTexture];
        if (mesh.materialInfo.normalTexture)      [textureSet addObject:mesh.materialInfo.normalTexture];
        if (mesh.materialInfo.specularTexture)    [textureSet addObject:mesh.materialInfo.specularTexture];
    }
    for (MaterialInfo *mtlInfo in mtlInfoSet) {
        mtlInfo.name = [NSString stringWithFormat:@"%@_%@", objInfo.name, mtlInfo.name];
    }
    for (TextureInfo *texture in textureSet) {
        texture.name = [NSString stringWithFormat:@"%@_%@", objInfo.name, [texture.name stringByDeletingPathExtension]];
    }
    
    objInfo.meshInfos = filteredMeshes.copy;
    return objInfo;
}


+ (NSArray *)vertexAttributesWithFaceAttributes:(NSString *)attributeString {
    NSArray *indices = [attributeString componentsSeparatedByString:@"/"];
    NSMutableArray *attributeNames = [NSMutableArray arrayWithCapacity:indices.count];
    if (indices.count >= 1) { // add position
        [attributeNames addObject:@(CEVBOAttributePosition)];
    }
    if (indices.count >= 2) {
        if ([indices[1] length]) {
            [attributeNames addObject:@(CEVBOAttributeUV)];
        } else {
            [attributeNames addObject:@(CEVBOAttributeNormal)];
        }
    }
    if (indices.count >= 3 && [indices[1] length]) {
        [attributeNames addObject:@(CEVBOAttributeNormal)];
    }
    
    return attributeNames;
}


#pragma mark - Data parsing


- (BOOL)parseDataWithFileInfo:(OBJFileInfo *)fileInfo {
    NSError *error;
    NSString *objContent = [[NSString alloc] initWithContentsOfFile:fileInfo.filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    NSArray *lines = [objContent componentsSeparatedByString:@"\n"];
    _indicesDict = [NSMutableDictionary dictionary];
    _allPositionList = [[VectorList alloc] initWithVectorType:VectorType3];
    _allUVList = [[VectorList alloc] initWithVectorType:VectorType2];
    _allNormalList = [[VectorList alloc] initWithVectorType:VectorType3];
    _objInfo = fileInfo;
    _hasNormalMap = NO;
    
    // check has normal map
    NSMutableDictionary *meshInfoDict = [NSMutableDictionary dictionary];
    for (MeshInfo *meshInfo in fileInfo.meshInfos) {
        if (!_hasNormalMap && meshInfo.materialInfo.normalTexture) {
            _hasNormalMap = YES;
        }
        NSString *meshString = [meshInfo.groupNames componentsJoinedByString:@"-"];
        meshInfoDict[meshString] = meshInfo;
    }
    MeshInfo *currentMesh = fileInfo.meshInfos.count ? fileInfo.meshInfos[0] : nil;
    for (NSString *lineContent in lines) {
        // parse vertex "v 2.963007 0.335381 -0.052237"
        if ([lineContent hasPrefix:@"v "]) {
            NSString *valueString = [lineContent substringFromIndex:2];
            [_allPositionList addVector3:[self vec3WithValueString:valueString]];
            continue;
        }
        
        // parse texture coordinate "vt 0.000000 1.000000"
        if ([lineContent hasPrefix:@"vt "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            [_allUVList addVector2:[self vec2WithValueString:valueString]];
            continue;
        }
        
        // parse normal "vn -0.951057 0.000000 0.309017"
        if (!_hasNormalMap && [lineContent hasPrefix:@"vn "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            [_allNormalList addVector3:[self vec3WithValueString:valueString]];
            continue;
        }
        
        // parse group "g group1 pPipe1 group2"
        if ([lineContent hasPrefix:@"g "] || [lineContent hasPrefix:@"o "]) {
            NSString *valueString = [lineContent substringFromIndex:2];
            NSArray *groupNames = [valueString componentsSeparatedByString:@" "];
            NSString *meshString = [groupNames componentsJoinedByString:@"-"];
            currentMesh = meshInfoDict[meshString];
            continue;
        }
        
        // parse faces "f 10/16/25 9/15/26 29/36/27 30/37/28"
        if (currentMesh && [lineContent hasPrefix:@"f "]) {
//            NSAssert(currentMesh, @"Fail to get current mesh");
            NSString *content = [lineContent substringFromIndex:2];
            NSArray *indexStringList = [content componentsSeparatedByString:@" "];
            if (indexStringList.count == 3) {
                for (NSString *indexString in indexStringList) {
                    [self appendIndexToMesh:currentMesh withIndexString:indexString];
                }
                
            } else if (indexStringList.count == 4) {
                // quadrilateral to triangle
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[0]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[1]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[3]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[3]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[1]];
                [self appendIndexToMesh:currentMesh withIndexString:indexStringList[2]];
            }
            continue;
        }
    }
    
    if (_hasNormalMap && ![self addTangentDataToObjInfo:_objInfo]) {
        NSLog(@"WARNING: fail to add tangent for model: %s\n", _objInfo.name.UTF8String);
    }
    
    // get bounds
    [self calculateBoundsForObjInfo:fileInfo];
    
    // clean up
    _indicesDict = nil;
    _allPositionList = nil;
    _allUVList = nil;
    _allNormalList = nil;
    
    return YES;
}


- (NSData *)dataWithFloatStringList:(NSArray *)floatStringList {
    NSMutableData *valueData = [NSMutableData data];
    for (NSString *floatString in floatStringList) {
        float value = [floatString floatValue];
        [valueData appendBytes:&value length:sizeof(float)];
    }
    return valueData;
}


// 根据索引获取对应的坐标，纹理，法线等值
- (void)appendIndexToMesh:(MeshInfo *)mesh withIndexString:(NSString *)indexString {
    NSArray *indies = [indexString componentsSeparatedByString:@"/"];
    __block int32_t positionIndex = -1, uvIndex = -1, normalIndex = -1;
    [indies enumerateObjectsUsingBlock:^(NSString *indexString, NSUInteger idx, BOOL *stop) {
        if (indexString.length) {
            int index = [indexString intValue] - 1;
            if (index >= 0) {
                switch (idx) {
                    case 0: { // position
                        positionIndex = index;
                        break;
                    }
                    case 1: { // texture coordinate
                        uvIndex = index;
                        break;
                    }
                    case 2: { // normal
                        normalIndex = index;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }];
    
    // append value to vector lists and adjust index
    if (positionIndex >= 0) {
        GLKVector3 positionValue = [_allPositionList vector3AtIndex:positionIndex];
        NSInteger actuallIndex = [_objInfo.positionList indexOfValueVector3:positionValue];
        if (actuallIndex == NSNotFound) {
            positionIndex = (int32_t)_objInfo.positionList.count;
            [_objInfo.positionList addVector3:positionValue];
        } else {
            positionIndex = (int32_t)actuallIndex;
        }
    }
    if (uvIndex >= 0) {
        GLKVector2 uvValue = [_allUVList vector2AtIndex:uvIndex];
        NSInteger actualIndex = [_objInfo.uvList indexOfValueVector2:uvValue];
        if (actualIndex == NSNotFound) {
            uvIndex = (int32_t)_objInfo.uvList.count;
            [_objInfo.uvList addVector2:uvValue];
        } else {
            uvIndex = (int32_t)actualIndex;
        }
    }
    if (!_hasNormalMap && normalIndex >= 0) { // normal data will be calculated if contain  normal map
        GLKVector3 normalValue = [_allNormalList vector3AtIndex:normalIndex];
        NSInteger actuallIndex = [_objInfo.normalList indexOfValueVector3:normalValue];
        if (actuallIndex == NSNotFound) {
            normalIndex = (int32_t)_objInfo.normalList.count;
            [_objInfo.normalList addVector3:normalValue];
        } else {
            normalIndex = (int32_t)actuallIndex;
        }
    }
    
    NSString *actualIndexString = [NSString stringWithFormat:@"%d%d%d", positionIndex, uvIndex, normalIndex];
    NSNumber *index = _indicesDict[actualIndexString];
    unsigned short u_index;
    if (index) {
        u_index = [index unsignedShortValue];
    } else {
        u_index = _objInfo.vertexDataList.count;
        _indicesDict[actualIndexString] = @(u_index);
        [_objInfo.vertexDataList addVector3:GLKVector3Make(positionIndex, uvIndex, normalIndex)];
        NSAssert((_indicesDict.count == _objInfo.vertexDataList.count), @"wrong index");
    }
    mesh.maxIndex = MAX(mesh.maxIndex, u_index);
    [mesh.indicesList addObject:@(u_index)];
}

// calcualte tengent data
- (BOOL)addTangentDataToObjInfo:(OBJFileInfo *)objInfo {
    if (!objInfo.vertexDataList.count ||
        ![objInfo.attributes containsObject:@(CEVBOAttributePosition)] ||
        ![objInfo.attributes containsObject:@(CEVBOAttributeUV)]) {
        NSLog(@"Fail to calculate tangent data for obj file:%s\n", [objInfo.name UTF8String]);
        return NO;
    }
    
    // erase old normal and tangent data
    objInfo.normalList = [[VectorList alloc] initWithVectorType:VectorType3 itemCount:objInfo.positionList.count];
    objInfo.tangentList = [[VectorList alloc] initWithVectorType:VectorType3 itemCount:objInfo.positionList.count];
    
    // calucate each triangle's normal and tangent data
    for (MeshInfo *meshInfo in objInfo.meshInfos) {
        if (!meshInfo.indicesList.count % 3) {
            NSLog(@"warning: skip mesh with wrong indice count\n");
            continue;
        }
        // loop triangles
        for (int i = 0; i < meshInfo.indicesList.count; i += 3) {
            GLKVector3 vertexIndex0 = [objInfo.vertexDataList vector3AtIndex:[meshInfo.indicesList[i] intValue]];
            GLKVector3 vertexIndex1 = [objInfo.vertexDataList vector3AtIndex:[meshInfo.indicesList[i + 1] intValue]];
            GLKVector3 vertexIndex2 = [objInfo.vertexDataList vector3AtIndex:[meshInfo.indicesList[i + 2] intValue]];
            // calculate normal vector
            GLKVector3 v1 = GLKVector3Subtract([objInfo.positionList vector3AtIndex:(int)vertexIndex0.x],
                                               [objInfo.positionList vector3AtIndex:(int)vertexIndex1.x]);
            GLKVector3 v2 = GLKVector3Subtract([objInfo.positionList vector3AtIndex:(int)vertexIndex0.x],
                                               [objInfo.positionList vector3AtIndex:(int)vertexIndex2.x]);
            GLKVector3 normal = GLKVector3CrossProduct(v1, v2);
            normal = GLKVector3Normalize(normal);
            
            // smooth normals
            GLKVector3 normal0 = [objInfo.normalList vector3AtIndex:(int)vertexIndex0.x];
            [objInfo.normalList setVector3:GLKVector3Add(normal0 ,normal) atIndex:(int)vertexIndex0.x];
            GLKVector3 normal1 = [objInfo.normalList vector3AtIndex:(int)vertexIndex1.x];
            [objInfo.normalList setVector3:GLKVector3Add(normal1 ,normal) atIndex:(int)vertexIndex1.x];
            GLKVector3 normal2 = [objInfo.normalList vector3AtIndex:(int)vertexIndex2.x];
            [objInfo.normalList setVector3:GLKVector3Add(normal2 ,normal) atIndex:(int)vertexIndex2.x];
            
            if (objInfo.uvList.count) {
                // tangent
                GLKVector2 uv1 = GLKVector2Subtract([objInfo.uvList vector2AtIndex:(int)vertexIndex2.y],
                                                    [objInfo.uvList vector2AtIndex:(int)vertexIndex0.y]);
                GLKVector2 uv2 = GLKVector2Subtract([objInfo.uvList vector2AtIndex:(int)vertexIndex1.y],
                                                    [objInfo.uvList vector2AtIndex:(int)vertexIndex0.y]);
                GLKVector3 tangent;
                float c = 1.0f / (uv1.x * uv2.y - uv2.x * uv1.y);
                tangent.x = (v1.x * uv2.y + v2.x * uv1.y) * c;
                tangent.y = (v1.y * uv2.y + v2.y * uv1.y) * c;
                tangent.z = (v1.z * uv2.y + v2.z * uv1.y) * c;
                
                GLKVector3 tangent0 = [objInfo.tangentList vector3AtIndex:(int)vertexIndex0.x];
                [objInfo.tangentList setVector3:GLKVector3Add(tangent0 ,tangent) atIndex:(int)vertexIndex0.x];
                GLKVector3 tangent1 = [objInfo.tangentList vector3AtIndex:(int)vertexIndex1.x];
                [objInfo.tangentList setVector3:GLKVector3Add(tangent1 ,tangent) atIndex:(int)vertexIndex1.x];
                GLKVector3 tangent2 = [objInfo.tangentList vector3AtIndex:(int)vertexIndex2.x];
                [objInfo.tangentList setVector3:GLKVector3Add(tangent2 ,tangent) atIndex:(int)vertexIndex2.x];
                
                
            }
        }
    }
    
    // normalized normals and tangent
    for (int i = 0; i < objInfo.positionList.count; i++) {
        GLKVector3 normal = GLKVector3Normalize([objInfo.normalList vector3AtIndex:i]);
        [objInfo.normalList setVector3:normal atIndex:i];
        GLKVector3 tangent = GLKVector3Normalize([objInfo.tangentList vector3AtIndex:i]);
        [objInfo.tangentList setVector3:tangent atIndex:i];
    }
    
    // fix normal index
    for (int i = 0; i < objInfo.vertexDataList.count; i++) {
        GLKVector3 vertexData = [objInfo.vertexDataList vector3AtIndex:i];
        vertexData.z = vertexData.x;
        [objInfo.vertexDataList setVector3:vertexData atIndex:i];
    }
    
    objInfo.attributes = @[@(CEVBOAttributePosition),
                           @(CEVBOAttributeUV),
                           @(CEVBOAttributeNormal),
                           @(CEVBOAttributeTangent)];
    return YES;
}


- (void)calculateBoundsForObjInfo:(OBJFileInfo *)objInfo {
    GLfloat maxX = FLT_MIN, maxY = FLT_MIN, maxZ = FLT_MIN;
    GLfloat minX = FLT_MAX, minY = FLT_MAX, minZ = FLT_MAX;
    
    for (int i = 0; i < objInfo.positionList.count; i++) {
        GLKVector3 position = [objInfo.positionList vector3AtIndex:i];
        maxX = MAX(maxX, position.x);
        maxY = MAX(maxY, position.y);
        maxZ = MAX(maxZ, position.z);
        minX = MIN(minX, position.x);
        minY = MIN(minY, position.y);
        minZ = MIN(minZ, position.z);
    }
    objInfo.offsetFromOrigin = GLKVector3Make((maxX + minX) / 2,
                                              (maxY + minY) / 2,
                                              (maxZ + minZ) / 2);
    objInfo.bounds = GLKVector3Make(maxX - minX, maxY - minY, maxZ - minZ);
}


#pragma mark - 
// "-0.951057 0.309017" -> GLKVector2
- (GLKVector2)vec2WithValueString:(NSString *)valueString {
    NSArray *values = [valueString componentsSeparatedByString:@" "];
    NSAssert(values.count >= 2, @"wrong vec2 string");
    return GLKVector2Make([values[0] floatValue], [values[1] floatValue]);
}

// "-0.951057 0.00000 0.309017" -> GLKVector3
- (GLKVector3)vec3WithValueString:(NSString *)valueString {
    NSArray *values = [valueString componentsSeparatedByString:@" "];
    NSAssert(values.count >= 3, @"wrong vec3 string");
    return GLKVector3Make([values[0] floatValue], [values[1] floatValue], [values[2] floatValue]);
}


@end





