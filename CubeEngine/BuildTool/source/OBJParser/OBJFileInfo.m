//
//  OBJFileInfo.m
//  CubeEngine
//
//  Created by chance on 9/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "OBJFileInfo.h"

@implementation OBJFileInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _vertexDataList = [[VectorList alloc] initWithVectorType:VectorType3];
        _positionList = [[VectorList alloc] initWithVectorType:VectorType3];
        _uvList = [[VectorList alloc] initWithVectorType:VectorType2];
        _normalList = [[VectorList alloc] initWithVectorType:VectorType3];
        _tangentList = [[VectorList alloc] initWithVectorType:VectorType3];
    }
    return self;
}


- (NSData *)buildVertexData {
    NSMutableData *vertexData = [NSMutableData data];
    NSSet *attributes = [NSSet setWithArray:_attributes];
    for (int i = 0; i < _vertexDataList.count; i++) {
        GLKVector3 vertexIndex = [_vertexDataList vector3AtIndex:i];
        if ([attributes containsObject:@(CEVBOAttributePosition)]) {
            [vertexData appendBytes:[_positionList vector3AtIndex:vertexIndex.x].v length:sizeof(GLKVector3)];
        }
        if ([attributes containsObject:@(CEVBOAttributeUV)]) {
            [vertexData appendBytes:[_uvList vector2AtIndex:vertexIndex.y].v length:sizeof(GLKVector2)];
        }
        if ([attributes containsObject:@(CEVBOAttributeNormal)]) {
            [vertexData appendBytes:[_normalList vector3AtIndex:vertexIndex.z].v length:sizeof(GLKVector3)];
        }
        if ([attributes containsObject:@(CEVBOAttributeTangent)]) {
            [vertexData appendBytes:[_tangentList vector3AtIndex:vertexIndex.x].v length:sizeof(GLKVector3)];
        }
    }
    return vertexData.copy;
}

- (void)setFilePath:(NSString *)filePath {
    if (![_filePath isEqualToString:filePath]) {
        _filePath = filePath;
        _resourceID = HashValueWithString(filePath);
    }
}


- (BOOL)isEqual:(OBJFileInfo *)other {
    if (other == self) {
        return YES;
    }else {
        return _resourceID && _resourceID == other.resourceID;;
    }
}


- (NSUInteger)hash {
    return _resourceID;
}



@end

