//
//  CEVertexBufferAttributeInfo.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CEVBOAttributeName) {
    CEVBOAttributeNone = 0,
    CEVBOAttributePosition,
    CEVBOAttributeTextureCoord,
    CEVBOAttributeNormal,
    CEVBOAttributeColor,    
};


/**
 表示VertexBuffer的属性信息，常用的属性为位置，纹理，法线等
 */
@interface CEVBOAttribute : NSObject

@property (nonatomic, readonly) CEVBOAttributeName name;    // 属性名称 如：CEVBOAttributePosition
@property (nonatomic, readonly) GLint dataCount;            // 组成属性的元数据个数 如：3
@property (nonatomic, readonly) GLenum dataType;            // 元数据类型 如：GL_INT, GL_FLOAT
@property (nonatomic, readonly) GLushort dataSize;          // 元数据大小

+ (instancetype)attributeWithname:(CEVBOAttributeName)name;

@end
