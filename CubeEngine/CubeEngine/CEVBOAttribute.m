//
//  CEVertexBufferAttributeInfo.m
//  CubeEngine
//
//  Created by chance on 4/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEVBOAttribute.h"

/*
NSString *CEVBOAttributeNameString(CEVBOAttributeName name) {
    switch (name) {
        case CEVBOAttributePosition:
            return @"Position";
        case CEVBOAttributeUV:
            return @"TextureCoord";
        case CEVBOAttributeNormal:
            return @"Normal";
        case CEVBOAttributeColor:
            return @"Color";
        case CEVBOAttributeTangent:
            return @"Tangent";
        default:
            return nil;
    }
}
//*/

static NSDictionary *attributeKeywordDict = nil;
CEVBOAttributeName CEVBOAttributeNameWithShaderDeclaration(NSString *declaration) {
    if (!attributeKeywordDict) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            attributeKeywordDict = @{@"position"    : @(CEVBOAttributePosition),
                                     @"uv"          : @(CEVBOAttributeUV),
                                     @"texture"     : @(CEVBOAttributeUV),
                                     @"normal"      : @(CEVBOAttributeNormal),
                                     @"tangent"     : @(CEVBOAttributeTangent),
                                     @"color"       : @(CEVBOAttributeColor)};
        });
    }
    for (NSString *keyword in attributeKeywordDict.allKeys) {
        NSRange matchRange = [declaration rangeOfString:keyword options:NSCaseInsensitiveSearch];
        if (matchRange.location != NSNotFound) {
            return [attributeKeywordDict[keyword] integerValue];
        }
    }
    return CEVBOAttributeUnknown;
}


@interface CEVBOAttribute ()

@property (nonatomic, readwrite) CEVBOAttributeName name;    // 属性名称 如：CEVBOAttributePosition
@property (nonatomic, readwrite) GLuint primaryCount;         // 组成属性的元数据个数 如：3
@property (nonatomic, readwrite) GLenum primaryType;         // 元数据类型 如：GL_INT, GL_FLOAT
@property (nonatomic, readwrite) GLushort primarySize;       // 元数据大小
@property (nonatomic, readwrite) GLuint elementOffset;        // offset(Bytes) in data element
@property (nonatomic, readwrite) GLuint elementStride;       // total size of element

@end

@implementation CEVBOAttribute

+ (instancetype)attributeWithName:(CEVBOAttributeName)name {
    CEVBOAttribute *attribute = [CEVBOAttribute new];
    attribute.name = name;
    switch (name) {
        case CEVBOAttributePosition:
        case CEVBOAttributeNormal:
        case CEVBOAttributeTangent:
            attribute.primaryCount = 3;
            attribute.primaryType = GL_FLOAT;
            attribute.primarySize = sizeof(GLfloat);
            break;
            
        case CEVBOAttributeUV:
            attribute.primaryCount = 2;
            attribute.primaryType = GL_FLOAT;
            attribute.primarySize = sizeof(GLfloat);
            break;
            
        case CEVBOAttributeColor:
            attribute.primaryCount = 4;
            attribute.primaryType = GL_FLOAT;
            attribute.primarySize = sizeof(GLfloat);
            break;
            
        default:
            return nil;
    }
    attribute.elementStride = attribute.primarySize * attribute.primaryCount;
    return attribute;
}


+ (NSArray *)attributesWithNames:(NSArray *)names {
    int offset = 0;
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:names.count];
    for (NSNumber *name in names) {
        CEVBOAttribute *attribute = [CEVBOAttribute attributeWithName:[name integerValue]];
        if (attribute) {
            attribute.elementOffset = offset;
            [attributeList addObject:attribute];
            offset += attribute.primarySize * attribute.primaryCount;
        }
    }
    
    // setup stride
    for (CEVBOAttribute *attribute in attributeList) {
        attribute.elementStride = offset;
    }
    return attributeList.count ? attributeList.copy : nil;
}


+ (uint32_t)attributesTypeWithNames:(NSArray *)names {
    uint32_t type = 0;
    for (int i = 0; i < names.count; i++) {
        type += ([names[i] intValue] << (i * 4));
    }
    return type;
}


- (BOOL)isEqualToAttribute:(CEVBOAttribute *)attribute {
    return _name == attribute.name &&
    _primarySize == attribute.primarySize &&
    _elementStride == attribute.elementStride &&
    _elementOffset == attribute.elementOffset;
}


- (BOOL)isEqual:(id)object {
    return [self isEqualToAttribute:object];
}


@end
