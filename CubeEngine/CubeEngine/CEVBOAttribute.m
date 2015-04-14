//
//  CEVertexBufferAttributeInfo.m
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEVBOAttribute.h"

@interface CEVBOAttribute ()

@property (nonatomic, readwrite) CEVBOAttributeName name;  //属性名称 如：CEVBOAttributePosition
@property (nonatomic, readwrite) GLint dataCount;          //组成属性的元数据个数 如：3
@property (nonatomic, readwrite) GLenum dataType;          //元数据类型 如：GL_INT, GL_FLOAT
@property (nonatomic, readwrite) GLushort dataSize;      // 元数据大小

@end

@implementation CEVBOAttribute

+ (instancetype)attributeWithname:(CEVBOAttributeName)name {
    CEVBOAttribute *attribute = [CEVBOAttribute new];
    attribute.name = name;
    switch (name) {
        case CEVBOAttributePosition:
        case CEVBOAttributeNormal:
            attribute.dataCount = 3;
            attribute.dataType = GL_FLOAT;
            attribute.dataSize = sizeof(GLfloat);
            break;
            
        case CEVBOAttributeTextureCoord:
            attribute.dataCount = 2;
            attribute.dataType = GL_FLOAT;
            attribute.dataSize = sizeof(GLfloat);
            break;
            
        case CEVBOAttributeColor:
            attribute.dataCount = 4;
            attribute.dataType = GL_FLOAT;
            attribute.dataSize = sizeof(GLfloat);
            break;
            
        default:
            return nil;
    }
    return attribute;
}

@end
