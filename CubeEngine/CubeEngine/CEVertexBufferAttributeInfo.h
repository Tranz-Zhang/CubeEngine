//
//  CEVertexBufferAttributeInfo.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CEAttributeName) {
    CEAttributeNone = 0,
    CEAttributePosition,
    CEAttributeTextureCoord,
    CEAttributeNormal,
    CEAttributeColor,
    
    CEAttributeIndices = 999,
};


/**
 表示VertexBuffer的属性信息，如位置，纹理，法线等
 */
@interface CEVertexBufferAttributeInfo : NSObject

@property (nonatomic, assign) CEAttributeName name;     //属性名称 如：CEAttributePosition
@property (nonatomic, assign) GLushort elementCount;    //组成属性的元数据个数 如：3
@property (nonatomic, assign) GLushort elementSize;     //元数据数值大小 如：sizeof(GLfloat)

@property (nonatomic, readonly) GLsizei attibuteSize; // 整个属性所占的大小 如：3 * sizeof(GLfloat)

@end
