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
    
    NSMutableData *_vertexData;
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
    _vertexData = [NSMutableData data];
    
    NSString *fileName = [_filePath lastPathComponent];
    fileName = [fileName substringToIndex:fileName.length - 4];
    OBJFileInfo *objInfo = [OBJFileInfo new];
    objInfo.name = fileName;
    
    NSMutableArray *meshInfoList = [NSMutableArray array];
    MeshInfo *currentMesh = [MeshInfo new];
    currentMesh.indicesCount = 0;
    currentMesh.groupNames = @[@"DefaultGroup"];
    currentMesh.indicesData = [NSMutableData data];
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
            newMesh.indicesCount = 0;
            newMesh.groupNames = groupNames;
            newMesh.indicesData = [NSMutableData data];
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
        if (mesh.groupNames.count && mesh.indicesCount && mesh.indicesData.length) {
            [filteredMeshes addObject:mesh];
        }
    }
    objInfo.meshInfos = filteredMeshes.copy;
    objInfo.vertexData = _vertexData.copy;
    _vertexData = nil;
    
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
    NSMutableData *elementData = [NSMutableData data];
    [indies enumerateObjectsUsingBlock:^(NSString *indexString, NSUInteger idx, BOOL *stop) {
        if (indexString.length) {
            NSInteger index = [indexString integerValue] - 1;
            if (index >= 0) {
                switch (idx) {
                    case 0: // vertex
                        [elementData appendData:_vertexList[index]];
                        break;
                        
                    case 1: // texture coordinate
                        [elementData appendData:_uvList[index]];
                        break;
                        
                    case 2: // normal
                        [elementData appendData:_normalList[index]];
                        break;
                        
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
        u_index = _indicesDict.count;
        _indicesDict[indexString] = @(u_index);
        [_vertexData appendData:elementData];
        
        NSAssert((_indicesDict.count == _vertexData.length / elementData.length), @"wrong index");
    }
    mesh.indicesCount++;
    [mesh.indicesData appendBytes:&u_index length:sizeof(unsigned short)];
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
    
    return [CEVBOAttribute attributesWithNames:attributeNames];
}


// calcualte tengent data
+ (BOOL)addTengentDataToObjInfo:(OBJFileInfo *)objFileInfo {
    // check normal attribute
    BOOL containNormalAttribute = NO;
    for (CEVBOAttribute *attribute in objFileInfo.attributes) {
        if (attribute.name == CEVBOAttributeNormal) {
            containNormalAttribute = YES;
            break;
        }
    }
    if (!containNormalAttribute) {
        printf("Fail to add tengent data: obj file does not contain normal attribute\n");
        return NO;
    }
    
    // calculate tangent data
    CEVBOAttribute *positionAttrib, *textureAttrib;
    for (CEVBOAttribute *attribute in objFileInfo.attributes) {
        if (attribute.name == CEVBOAttributePosition) {
            positionAttrib = attribute;
            continue;
        }
        if (attribute.name == CEVBOAttributeTextureCoord) {
            textureAttrib = attribute;
            continue;
        }
    }
    NSData *vertexData = objFileInfo.vertexData;
    int stride = positionAttrib.elementStride;
    if (!positionAttrib || !textureAttrib || !vertexData.length ||
        vertexData.length % (stride * 3)) {
        
        // 这里需要从indcesData拿到三角形的数据，数据重新组合不是按顺序进行的，比较麻烦。
        // 考虑先建空数据，再逐一替代 ？ 替代时会不会重复？参考书中做法，必要时重新计算法线
        
        printf("Fail to add tengent data: wrong data & params");
        return NO;
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
    objFileInfo.vertexData = [newVertexData copy];
    
    // add tangent attribute
    NSMutableArray *attributeNames = [NSMutableArray array];
    for (CEVBOAttribute *attribute in objFileInfo.attributes) {
        [attributeNames addObject:@(attribute.name)];
    }
    [attributeNames addObject:@(CEVBOAttributeTangent)];
    objFileInfo.attributes = [CEVBOAttribute attributesWithNames:attributeNames];
    
    return YES;
}


@end
