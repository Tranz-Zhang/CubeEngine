//
//  NSData+GLKit.m
//  CubeEngine
//
//  Created by chance on 10/20/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "NSData+GLKit.h"

@implementation NSData (GLKit)

+ (NSData *)dataWithVector2:(GLKVector2)vec2 {
    return [NSData dataWithBytes:vec2.v length:sizeof(GLKVector2)];
}

+ (NSData *)dataWithVector3:(GLKVector3)vec3 {
    return [NSData dataWithBytes:vec3.v length:sizeof(GLKVector3)];
}

+ (NSData *)dataWithVector4:(GLKVector4)vec4 {
    return [NSData dataWithBytes:vec4.v length:sizeof(GLKVector4)];
}

@end


GLKVector2 GLKVector2MakeWithData(NSData *vec2Data) {
    GLKVector2 vec2;
    [vec2Data getBytes:vec2.v length:sizeof(GLKVector2)];
    return vec2;
}

GLKVector3 GLKVector3MakeWithData(NSData *vec3Data) {
    GLKVector3 vec3;
    [vec3Data getBytes:vec3.v length:sizeof(GLKVector3)];
    return vec3;
}

GLKVector4 GLKVector4MakeWithData(NSData *vec4Data) {
    GLKVector4 vec4;
    [vec4Data getBytes:vec4.v length:sizeof(GLKVector4)];
    return vec4;
}

