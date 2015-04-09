//
//  CEMesh.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CEVertexDataType) {
    CEVertexDataType_Unknown = 0,
    CEVertexDataType_V,        // position[3]
    CEVertexDataType_V_VT,     // position[3] + textureCoord[2]
    CEVertexDataType_V_VN,     // position[3] + normal[3]
    CEVertexDataType_V_VT_VN,  // position[3] + textureCoord[2] + normal[3]
};

typedef NS_ENUM(NSInteger, CEIndicesDataType) {
    CEIndicesDataType_UByte = 0,  // unsigned short   MAX:255
    CEIndicesDataType_UShort,     // unsigned byte    MAX:65535
};

@interface CEMesh : NSObject

@property (nonatomic, readonly) GLKVector3 bounds;          // 模型空间大小
@property (nonatomic, readonly) GLKVector3 offsetFromOrigin; // 模型中心相对与坐标原点的偏移值


// 此方法会自动生成indicesData
- (instancetype)initWithVertexData:(NSData *)vertexData
                    vertexDataType:(CEVertexDataType)vertexDataType;

- (instancetype)initWithVertexData:(NSData *)vertexData
                    vertexDataType:(CEVertexDataType)vertexDataType
                       indicesData:(NSData *)indicesData
                   indicesDataType:(CEIndicesDataType)indicesDataType;

@end
