//
//  Common.m
//  CubeEngineDev
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>
#include "Common.h"

GLKVector3 Vec3WithColor(UIColor *color) {
    CGFloat r, g, b;
    [color getRed:&r green:&g blue:&b alpha:NULL];
    return GLKVector3Make(r, g, b);
}

GLKVector4 Vec4WithColor(UIColor *color) {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return GLKVector4Make(r, g, b, a);
}

UIColor * ColorWithVec3(GLKVector3 vec3) {
    return [UIColor colorWithRed:vec3.r green:vec3.g blue:vec3.b alpha:1];
}

UIColor * ColorWithVec4(GLKVector4 vec4) {
    return [UIColor colorWithRed:vec4.r green:vec4.g blue:vec4.b alpha:vec4.a];
}


#pragma mark - Axis Color
UIColor *ColorOfAxisX() {
    return [UIColor colorWithRed:220/255.0 green:50/255.0 blue:50/255.0 alpha:1];
}

UIColor *ColosOfAxisY() {
    return [UIColor colorWithRed:70/255.0 green:160/255.0 blue:30/255.0 alpha:1];
}

UIColor *ColosOfAxisZ() {
    return [UIColor colorWithRed:30/255.0 green:100/255.0 blue:210/255.0 alpha:1];
}