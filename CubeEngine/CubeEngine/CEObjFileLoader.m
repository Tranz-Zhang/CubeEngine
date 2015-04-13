//
//  CEObjFileLoader.m
//  CubeEngine
//
//  Created by chance on 15/4/2.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEObjFileLoader.h"

#pragma mark - CEMeshGroup
@interface CEMeshGroup : NSObject

@property (nonatomic, strong) NSArray *groupNames;
@property (nonatomic, assign) CEVertexDataType elementType;
@property (nonatomic, strong) NSMutableData *meshData;

@end

@implementation CEMeshGroup

@end



#pragma mark - CEObjFileLoader

@implementation CEObjFileLoader  {
    NSMutableArray *_vertices;
    NSMutableArray *_textureCoordinates;
    NSMutableArray *_normals;
    NSMutableArray *_indices;
}

- (CEModel *)loadModelWithObjFileName:(NSString *)fileName {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test_obj" ofType:@"obj"];
    NSError *error;
    NSString *objContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    /*
     NOTE: I use [... componentsSeparatedByString:@" "] to seperate because it's short writing,
     if something wrong, use [... componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet] instead.
     */
    _vertices = [NSMutableArray array];
    _textureCoordinates = [NSMutableArray array];
    _normals = [NSMutableArray array];
    NSMutableArray *groups = [NSMutableArray array];
    CEMeshGroup *currentGroup = nil;
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
            CEMeshGroup *newGroup = [CEMeshGroup new];
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
                CEMeshGroup *newGroup = [CEMeshGroup new];
                newGroup.groupNames = nil;
                newGroup.meshData = [NSMutableData data];
                [groups addObject:newGroup];
                currentGroup = newGroup;
            }
            if (currentGroup.elementType == CEVertexDataTypeUnknown) {
                currentGroup.elementType = [self elementTypeWithFaceAttributes:attributeIndies[0]];
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
                NSData *vertex1 = [self vertexElementDataWithIndies:attributeIndies[0]];
                NSData *vertex2 = [self vertexElementDataWithIndies:attributeIndies[0]];
                NSData *vertex3 = [self vertexElementDataWithIndies:attributeIndies[0]];
                [currentGroup.meshData appendData:vertex0];
                [currentGroup.meshData appendData:vertex1];
                [currentGroup.meshData appendData:vertex3];
                [currentGroup.meshData appendData:vertex3];
                [currentGroup.meshData appendData:vertex1];
                [currentGroup.meshData appendData:vertex2];
            }
            continue;
        }
        
        // parse meterial file
        // parse meterial ref
    }
    CEMeshGroup *group = groups[1];
    CEMesh *mesh = [[CEMesh alloc] initWithVertexData:group.meshData vertexDataType:CEVertexDataType_V];
    mesh.showWireframe = YES;
    CEModel *model = [[CEModel alloc] initWithMesh:mesh];
    
    return model;
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
                    //                    [elementData appendData:_textureCoordinates[index]];
                    break;
                    
                case 2: // normal
                    //                    [elementData appendData:_normals[index]];
                    break;
                    
                default:
                    break;
            }
        }
    }];
    return elementData;
}


// "1/2/3 -> VertexElementType_V_VT_VN"
// "1//3" -> VertexElementType_V_VN
- (CEVertexDataType)elementTypeWithFaceAttributes:(NSString *)attributeString {
    NSArray *attributes = [attributeString componentsSeparatedByString:@"/"];
    switch (attributes.count) {
        case 1:
            return CEVertexDataType_V;
        case 2:
            return CEVertexDataType_V_VT;
        case 3:
            if ([attributes[1] length]) {
                return CEVertexDataType_V_VT_VN;
            } else {
                return CEVertexDataType_V_VN;
            }
        default:
            return CEVertexDataTypeUnknown;
    }
}


@end
