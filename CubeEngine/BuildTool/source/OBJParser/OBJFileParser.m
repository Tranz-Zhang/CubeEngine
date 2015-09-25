//
//  ObjFileParser.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "OBJFileParser.h"
#import "CEVBOAttribute.h"

@implementation OBJFileParser {
    NSMutableArray *_vertexList;
    NSMutableArray *_uvList;
    NSMutableArray *_normalList;
    
    NSMutableArray *_vertexDataList;
    NSMutableDictionary *_indicesDict;
}


+ (OBJFileParser *)parserWithFilePath:(NSString *)filePath {
    return [[OBJFileParser alloc] initWithFilePath:filePath];
}


- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = filePath;
    }
    return self;
}


- (OBJFileInfo *)parse {
    NSError *error;
    NSString *objContent = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    /*
     NOTE: I use [... componentsSeparatedByString:@" "] to seperate because it's short writing,
     if something wrong, use [... componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet] instead.
     */
    
    _vertexList = [NSMutableArray array];
    _uvList = [NSMutableArray array];
    _normalList = [NSMutableArray array];
    _indicesDict = [NSMutableDictionary dictionary];
    _vertexDataList = [NSMutableArray array];
    
    NSString *fileName = [_filePath lastPathComponent];
    fileName = [fileName substringToIndex:fileName.length - 4];
    OBJFileInfo *objInfo = [OBJFileInfo new];
    objInfo.name = fileName;
    
    NSMutableArray *meshInfoList = [NSMutableArray array];
    MeshInfo *currentMesh = [MeshInfo new];
    currentMesh.groupNames = @[@"DefaultGroup"];
    currentMesh.indicesList = [NSMutableArray array];
    [meshInfoList addObject:currentMesh];
    
    NSArray *lines = [objContent componentsSeparatedByString:@"\n"];
    for (NSString *lineContent in lines) {
        // parse vertex "v 2.963007 0.335381 -0.052237"
        if ([lineContent hasPrefix:@"v "]) {
            NSString *valueString = [lineContent substringFromIndex:2];
            NSArray *vertexValues = [valueString componentsSeparatedByString:@" "];
            [_vertexList addObject:[self dataWithFloatStringList:vertexValues]];
            continue;
        }
        
        // parse texture coordinate "vt 0.000000 1.000000"
        if ([lineContent hasPrefix:@"vt "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            NSArray *vertexValues = [valueString componentsSeparatedByString:@" "];
            [_uvList addObject:[self dataWithFloatStringList:vertexValues]];
            continue;
        }
        
        // parse normal "vn -0.951057 0.000000 0.309017"
        if ([lineContent hasPrefix:@"vn "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            NSArray *vertexValues = [valueString componentsSeparatedByString:@" "];
            [_normalList addObject:[self dataWithFloatStringList:vertexValues]];
            continue;
        }
        
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
        
        // parse faces "f 10/16/25 9/15/26 29/36/27 30/37/28"
        if ([lineContent hasPrefix:@"f "]) {
            NSString *content = [lineContent substringFromIndex:2];
            NSArray *indexStringList = [content componentsSeparatedByString:@" "];
            if (!objInfo.attributes) {
                objInfo.attributes = [self vertexAttributesWithFaceAttributes:indexStringList[0]];
            }
            
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
        
        // mtl file name
        if ([lineContent hasPrefix:@"mtllib"]) {
            objInfo.mtlFileName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            continue;
        }
        
        // reference material
        if ([lineContent hasPrefix:@"usemtl"]) {
            currentMesh.materialName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
            continue;
        }
    }
    
    // clean up
    _vertexList = nil;
    _uvList = nil;
    _normalList = nil;
    _indicesDict = nil;
    currentMesh = nil;
    // remove useless groups
    NSMutableArray *filteredMeshes = [NSMutableArray array];
    for (MeshInfo *mesh in meshInfoList) {
        if (mesh.groupNames.count && mesh.indicesList.count) {
            [filteredMeshes addObject:mesh];
        }
    }
    objInfo.meshInfos = filteredMeshes.copy;
    objInfo.vertexDataList = _vertexDataList.copy;
    _vertexDataList = nil;
    
    return objInfo;
}


#pragma mark - Element Extract

- (NSData *)dataWithFloatStringList:(NSArray *)floatStringList {
    NSMutableData *valueData = [NSMutableData data];
    for (NSString *floatString in floatStringList) {
        float value = [floatString floatValue];
        [valueData appendBytes:&value length:sizeof(float)];
    }
    return valueData;
}


// 根据索引获取对应的坐标，纹理，法线等值，组成NSData返回
- (void)appendIndexToMesh:(MeshInfo *)mesh withIndexString:(NSString *)indexString {
    NSArray *indies = [indexString componentsSeparatedByString:@"/"];
    VertexData *vertex = [VertexData new];
    [indies enumerateObjectsUsingBlock:^(NSString *indexString, NSUInteger idx, BOOL *stop) {
        if (indexString.length) {
            NSInteger index = [indexString integerValue] - 1;
            if (index >= 0) {
                switch (idx) {
                    case 0: { // position
                        GLKVector3 positon;
                        [_vertexList[index] getBytes:positon.v length:sizeof(GLKVector3)];
                        vertex.position = positon;
                        break;
                    }
                    case 1: { // texture coordinate
                        GLKVector2 uv;
                        [_uvList[index] getBytes:uv.v length:sizeof(GLKVector2)];
                        vertex.uv = uv;
                        break;
                    }
                    case 2: { // normal
                        GLKVector3 normal;
                        [_normalList[index] getBytes:normal.v length:sizeof(GLKVector3)];
                        vertex.normal = normal;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }];
    
    NSNumber *index = _indicesDict[indexString];
    unsigned short u_index;
    if (index) {
        u_index = [index unsignedShortValue];
    } else {
        u_index = _vertexDataList.count;
        _indicesDict[indexString] = @(u_index);
        [_vertexDataList addObject:vertex];
        NSAssert((_indicesDict.count == _vertexDataList.count), @"wrong index");
    }
    mesh.maxIndex = MAX(mesh.maxIndex, u_index);
    [mesh.indicesList addObject:@(u_index)];
}


- (NSArray *)vertexAttributesWithFaceAttributes:(NSString *)attributeString {
    NSArray *indices = [attributeString componentsSeparatedByString:@"/"];
    NSMutableArray *attributeNames = [NSMutableArray arrayWithCapacity:indices.count];
    if (indices.count >= 1) { // add position
        [attributeNames addObject:@(CEVBOAttributePosition)];
    }
    if (indices.count >= 2) {
        if ([indices[1] length]) {
            [attributeNames addObject:@(CEVBOAttributeTextureCoord)];
        } else {
            [attributeNames addObject:@(CEVBOAttributeNormal)];
        }
    }
    if (indices.count >= 3 && [indices[1] length]) {
        [attributeNames addObject:@(CEVBOAttributeNormal)];
    }
    
    return attributeNames;
}


// calcualte tengent data
+ (BOOL)addTengentDataToObjInfo:(OBJFileInfo *)objFileInfo {
    if (!objFileInfo.vertexDataList.count ||
        ![objFileInfo.attributes containsObject:@(CEVBOAttributePosition)] ||
        ![objFileInfo.attributes containsObject:@(CEVBOAttributeNormal)]) {
        printf("Fail to calculate tangent data for obj file:%s\n", [objFileInfo.name UTF8String]);
        return NO;
    }
    
    // erase old normal and tangent data
    GLKVector3 emptyVec3 = GLKVector3Make(0, 0, 0);
    for (VertexData *vertex in objFileInfo.vertexDataList) {
        vertex.normal = emptyVec3;
        vertex.tangent = emptyVec3;
    }
    
    // calucate each triangle's normal and tangent data
    for (MeshInfo *meshInfo in objFileInfo.meshInfos) {
        if (!meshInfo.indicesList.count % 3) {
            printf("warning: skip mesh with wrong indice count\n");
            continue;
        }
        // loop triangles
        int triangleCount = (int)meshInfo.indicesList.count / 3;
        for (int i = 0; i < triangleCount; i += 3) {
//            int idx0 = [meshInfo.indicesList[i] intValue];
//            int idx1 = [meshInfo.indicesList[i+1] intValue];
//            int idx2 = [meshInfo.indicesList[i+2] intValue];
//            printf("(%d, %d, %d)\n", idx0, idx1, idx2);
            // three triangle vertex data
            VertexData *vertex0 = objFileInfo.vertexDataList[[meshInfo.indicesList[i] intValue]];
            VertexData *vertex1 = objFileInfo.vertexDataList[[meshInfo.indicesList[i + 1] intValue]];
            VertexData *vertex2 = objFileInfo.vertexDataList[[meshInfo.indicesList[i + 2] intValue]];
            // calculate normal vector
            GLKVector3 v1 = GLKVector3Subtract(vertex0.position, vertex1.position);
            GLKVector3 v2 = GLKVector3Subtract(vertex0.position, vertex2.position);
            GLKVector3 normal = GLKVector3CrossProduct(v1, v2);
            normal = GLKVector3Normalize(normal);
            // smooth normals
            vertex0.normal = GLKVector3Add(vertex0.normal, normal);
            vertex1.normal = GLKVector3Add(vertex1.normal, normal);
            vertex2.normal = GLKVector3Add(vertex2.normal, normal);
            // tangent
            GLKVector2 uv1 = GLKVector2Subtract(vertex2.uv, vertex0.uv);
            GLKVector2 uv2 = GLKVector2Subtract(vertex1.uv, vertex0.uv);
            GLKVector3 tangent;
            float c = 1.0f / (uv1.x * uv2.y - uv2.x * uv1.y);
            tangent.x = (v1.x * uv2.y + v2.x * uv1.y) * c;
            tangent.y = (v1.y * uv2.y + v2.y * uv1.y) * c;
            tangent.z = (v1.z * uv2.y + v2.z * uv1.y) * c;
            vertex0.tangent = GLKVector3Add(vertex0.tangent, tangent);
            vertex1.tangent = GLKVector3Add(vertex1.tangent, tangent);
            vertex2.tangent = GLKVector3Add(vertex2.tangent, tangent);
        }
    }
    
    // normalize normal and tangent vector
    for (VertexData *vertex in objFileInfo.vertexDataList) {
        vertex.normal = GLKVector3Normalize(vertex.normal);
        printf("(%.5f, %.5f, %.5f)\n", vertex.normal.x, vertex.normal.y, vertex.normal.z);
        vertex.tangent = GLKVector3Normalize(vertex.tangent);
    }
    
    return YES;
}


#pragma mark - 




@end












