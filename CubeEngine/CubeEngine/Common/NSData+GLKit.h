//
//  NSData+GLKit.h
//  CubeEngine
//
//  Created by chance on 10/20/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface NSData (GLKit)

+ (NSData *)dataWithVector2:(GLKVector2)vec2;
+ (NSData *)dataWithVector3:(GLKVector3)vec3;
+ (NSData *)dataWithVector4:(GLKVector4)vec4;

@end

GLKVector2 GLKVector2MakeWithData(NSData *vec2Data);
GLKVector3 GLKVector3MakeWithData(NSData *vec3Data);
GLKVector4 GLKVector4MakeWithData(NSData *vec4Data);
