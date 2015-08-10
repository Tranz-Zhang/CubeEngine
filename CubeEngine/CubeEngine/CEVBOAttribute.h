//
//  CEVertexBufferAttributeInfo.h
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Vertex Buffer Object Element Example
 ------------------------------------------------------------------------------
 | CEVBOAttributePosition | CEVBOAttributeTextureCoord | CEVBOAttributeNormal |
 ------------------------------------------------------------------------------
 |      3 * GL_FLOAT      |        2 * GL_FLOAT        |     3 * GL_FLOAT     |
 ------------------------------------------------------------------------------
 |    elementOffset = 0   |     elementOffset = 12     |  elementOffset = 20  |
 ------------------------------------------------------------------------------
 */


typedef NS_ENUM(NSInteger, CEVBOAttributeName) {
    CEVBOAttributeNone = 0,
    CEVBOAttributePosition,
    CEVBOAttributeTextureCoord,
    CEVBOAttributeNormal,
    CEVBOAttributeColor,
    CEVBOAttributeTangent,
    CEVBOAttributeBitangent,
};


/**
 表示VertexBuffer的属性信息，常用的属性为位置，纹理，法线等
 */
@interface CEVBOAttribute : NSObject

@property (nonatomic, readonly) CEVBOAttributeName name;    // 属性名称 如：CEVBOAttributePosition
@property (nonatomic, readonly) GLuint primaryCount;        // 组成属性的元数据个数 如：3
@property (nonatomic, readonly) GLenum primaryType;         // 元数据类型 如：GL_INT, GL_FLOAT
@property (nonatomic, readonly) GLushort primarySize;       // 元数据大小
@property (nonatomic, readonly) GLuint elementOffset;       // offset(Bytes) in data element
@property (nonatomic, readonly) GLuint elementStride;       // total size of element (bytes)

+ (instancetype)attributeWithName:(CEVBOAttributeName)name;

/**
 @[@(CEVBOAttributePosition), @(CEVBOAttributeNormal)] -> array of CEVBOAttributes
 */
+ (NSArray *)attributesWithNames:(NSArray *)names;


- (BOOL)isEqualToAttribute:(CEVBOAttribute *)attribute;
- (BOOL)isEqual:(id)object;

@end

