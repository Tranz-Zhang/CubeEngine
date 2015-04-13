//
//  CEMesh.h
//  CubeEngine
//
//  Created by chance on 4/9/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CEVertexDataType) {
    CEVertexDataTypeUnknown = 0,
    CEVertexDataType_V,        // position[3]
    CEVertexDataType_V_VT,     // position[3] + textureCoord[2]
    CEVertexDataType_V_VN,     // position[3] + normal[3]
    CEVertexDataType_V_VT_VN,  // position[3] + textureCoord[2] + normal[3]
};

typedef NS_ENUM(NSInteger, CEIndicesDataType) {
    CEIndicesDataTypeUnknown = 0,
    CEIndicesDataTypeU8  = 1,   // unsigned byte  MAX:255
    CEIndicesDataTypeU16 = 2,   // unsigned short MAX:65535
    CEIndicesDataTypeU32 = 4,   // unsigned int
};

@interface CEMesh : NSObject

@property (nonatomic, readonly) GLKVector3 bounds;          // 模型空间大小
@property (nonatomic, readonly) GLKVector3 offsetFromOrigin; // 模型中心相对与坐标原点的偏移值
@property (nonatomic, assign) BOOL showWireframe; // 是否显示线框，会有额外的性能消耗，推荐调试时使用

- (instancetype)initWithVertexData:(NSData *)vertexData
                    vertexDataType:(CEVertexDataType)vertexDataType;

- (instancetype)initWithVertexData:(NSData *)vertexData
                    vertexDataType:(CEVertexDataType)vertexDataType
                       indicesData:(NSData *)indicesData
                   indicesDataType:(CEIndicesDataType)indicesDataType;

@end
