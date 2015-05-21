//
//  CEObjParser.m
//  CubeEngine
//
//  Created by chance on 5/15/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEObjParser.h"
#import "CEVBOAttribute.h"

@implementation CEObjParser {
    NSMutableArray *_vertices;
    NSMutableArray *_textureCoordinates;
    NSMutableArray *_normals;
}


+ (CEObjParser *)parserWithFilePath:(NSString *)filePath {
    return [[CEObjParser alloc] initWithFilePath:filePath];
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
        CEError(@"Error: %@", error);
        return nil;
    }
    
    /*
     NOTE: I use [... componentsSeparatedByString:@" "] to seperate because it's short writing,
     if something wrong, use [... componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet] instead.
     */
    NSMutableArray *groups = [NSMutableArray array];
    _vertices = [NSMutableArray array];
    _textureCoordinates = [NSMutableArray array];
    _normals = [NSMutableArray array];
    CEObjMeshInfo *currentGroup = nil;
    NSArray *lines = [objContent componentsSeparatedByString:@"\n"];
    int vertextCount = 0;
    for (NSString *lineContent in lines) {
        // parse vertex "v 2.963007 0.335381 -0.052237"
        if ([lineContent hasPrefix:@"v "]) {
            NSString *valueString = [lineContent substringFromIndex:2];
            NSArray *vertexValues = [valueString componentsSeparatedByString:@" "];
            [_vertices addObject:[self dataWithFloatStringList:vertexValues]];
            continue;
        }
        
        // parse texture coordinate "vt 0.000000 1.000000"
        if ([lineContent hasPrefix:@"vt "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            NSArray *vertexValues = [valueString componentsSeparatedByString:@" "];
            [_textureCoordinates addObject:[self dataWithFloatStringList:vertexValues]];
            continue;
        }
        
        // parse normal "vn -0.951057 0.000000 0.309017"
        if ([lineContent hasPrefix:@"vn "]) {
            NSString *valueString = [lineContent substringFromIndex:3];
            NSArray *vertexValues = [valueString componentsSeparatedByString:@" "];
            [_normals addObject:[self dataWithFloatStringList:vertexValues]];
            continue;
        }
        
        // parse group "g group1 pPipe1 group2"
        if ([lineContent hasPrefix:@"g "]) {
            NSString *valueString = [lineContent substringFromIndex:2];
            NSArray *groupNames = [valueString componentsSeparatedByString:@" "];
            CEObjMeshInfo *newGroup = [CEObjMeshInfo new];
            newGroup.groupNames = groupNames;
            newGroup.meshData = [NSMutableData data];
            [groups addObject:newGroup];
            currentGroup = newGroup;
            continue;
        }
        
        // parse faces "f 10/16/25 9/15/26 29/36/27 30/37/28"
        if ([lineContent hasPrefix:@"f "]) {
            NSString *content = [lineContent substringFromIndex:2];
            NSArray *attributeIndies = [content componentsSeparatedByString:@" "];
            if (!currentGroup) {
                CEObjMeshInfo *newGroup = [CEObjMeshInfo new];
                newGroup.groupNames = nil;
                newGroup.meshData = [NSMutableData data];
                [groups addObject:newGroup];
                currentGroup = newGroup;
            }
            if (!currentGroup.attributes) {
                currentGroup.attributes = [self vertexAttributesWithFaceAttributes:attributeIndies[0]];
            }
            
            if (attributeIndies.count == 3) {
                for (NSString *indexString in attributeIndies) {
                    NSData *elementData = [self vertexElementDataWithIndies:indexString];
                    [currentGroup.meshData appendData:elementData];
                    vertextCount++;
                }
                
            } else if (attributeIndies.count == 4) {
                // quadrilateral to triangle
                NSData *vertex0 = [self vertexElementDataWithIndies:attributeIndies[0]];
                NSData *vertex1 = [self vertexElementDataWithIndies:attributeIndies[1]];
                NSData *vertex2 = [self vertexElementDataWithIndies:attributeIndies[2]];
                NSData *vertex3 = [self vertexElementDataWithIndies:attributeIndies[3]];
                [currentGroup.meshData appendData:vertex0];
                [currentGroup.meshData appendData:vertex1];
                [currentGroup.meshData appendData:vertex3];
                [currentGroup.meshData appendData:vertex3];
                [currentGroup.meshData appendData:vertex1];
                [currentGroup.meshData appendData:vertex2];
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
    _vertices = nil;
    _textureCoordinates = nil;
    _normals = nil;
    currentGroup = nil;
    
    // remove useless groups
    NSMutableArray *filteredGroups = [NSMutableArray array];
    for (CEObjMeshInfo *group in groups) {
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
