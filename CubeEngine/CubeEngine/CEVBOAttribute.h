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
 | CEVBOAttributePosition | CEVBOAttributeUV | CEVBOAttributeNormal |
 ------------------------------------------------------------------------------
 |      3 * GL_FLOAT      |        2 * GL_FLOAT        |     3 * GL_FLOAT     |
 ------------------------------------------------------------------------------
 |    elementOffset = 0   |     elementOffset = 12     |  elementOffset = 20  |
 ------------------------------------------------------------------------------
 */


// NOTE: these value also used as attribute index in shader program
typedef NS_ENUM(NSInteger, CEVBOAttributeName) {
    CEVBOAttributePosition = 0,
    CEVBOAttributeUV,
    CEVBOAttributeNormal,
    CEVBOAttributeTangent,
    CEVBOAttributeColor,
};

NSString *CEVBOAttributeNameString(CEVBOAttributeName name);

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

/**
 attribute id for a group of atrributes
 */
+ (uint32_t)attributesTypeWithNames:(NSArray *)names;


- (BOOL)isEqualToAttribute:(CEVBOAttribute *)attribute;
- (BOOL)isEqual:(id)object;


@end

