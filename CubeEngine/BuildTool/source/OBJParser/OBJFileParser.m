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


- (NSArray *)parse {
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
    NSMutableArray *groups = [NSMutableArray array];
    _vertexList = [NSMutableArray array];
    _uvList = [NSMutableArray array];
    _normalList = [NSMutableArray array];
    _indicesDict = [NSMutableDictionary dictionary];
    NSArray *lines = [objContent componentsSeparatedByString:@"\n"];
    
    MeshInfo *currentGroup = [MeshInfo new];
    currentGroup.groupNames = @[@"DefaultGroup"];
    currentGroup.meshData = [NSMutableData data];
    currentGroup.indicesData = [NSMutableData data];
    [groups addObject:currentGroup];
    
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
            MeshInfo *newGroup = [MeshInfo new];
            newGroup.groupNames = groupNames;
            newGroup.meshData = [NSMutableData data];
            newGroup.indicesData = [NSMutableData data];
            [groups addObject:newGroup];
            currentGroup = newGroup;
            continue;
        }
        
        // parse faces "f 10/16/25 9/15/26 29/36/27 30/37/28"
        if ([lineContent hasPrefix:@"f "]) {
            NSString *content = [lineContent substringFromIndex:2];
            NSArray *attributeIndies = [content componentsSeparatedByString:@" "];
            if (!currentGroup.attributes) {
                currentGroup.attributes = [self vertexAttributesWithFaceAttributes:attributeIndies[0]];
            }
            
            if (attributeIndies.count == 3) {
                for (NSString *indexString in attributeIndies) {
                    [self appendMeshDataToGroup:currentGroup withIndexString:indexString];
                }
                
            } else if (attributeIndies.count == 4) {
                // quadrilateral to triangle
                [self appendMeshDataToGroup:currentGroup withIndexString:attributeIndies[0]];
                [self appendMeshDataToGroup:currentGroup withIndexString:attributeIndies[1]];
                [self appendMeshDataToGroup:currentGroup withIndexString:attributeIndies[3]];
                [self appendMeshDataToGroup:currentGroup withIndexString:attributeIndies[3]];
                [self appendMeshDataToGroup:currentGroup withIndexString:attributeIndies[1]];
                [self appendMeshDataToGroup:currentGroup withIndexString:attributeIndies[2]];
            }
            continue;
        }
        
        // mtl file name
        if ([lineContent hasPrefix:@"mtllib"]) {
            _mtlFileName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
        }
        
        // reference material
        if ([lineContent hasPrefix:@"usemtl"]) {
            currentGroup.materialName = [lineContent substringWithRange:NSMakeRange(7, lineContent.length - 7)];
        }
    }
    
    // clean up
    _vertexList = nil;
    _uvList = nil;
    _normalList = nil;
    _indicesDict = nil;
    currentGroup = nil;
    
    // remove useless groups
    NSMutableArray *filteredGroups = [NSMutableArray array];
    for (MeshInfo *group in groups) {
        if (group.groupNames.count && group.attributes.count && group.meshData.length) {
            [filteredGroups addObject:group];
        }
    }
    groups = filteredGroups;
    
    return [groups copy];
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
- (void)appendMeshDataToGroup:(MeshInfo *)group withIndexString:(NSString *)indexString {
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
        [group.meshData appendData:elementData];
        
        NSAssert((_indicesDict.count == group.meshData.length / elementData.length), @"wrong index");
    }
    [group.indicesData appendBytes:&u_index length:sizeof(unsigned short)];
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


@end
