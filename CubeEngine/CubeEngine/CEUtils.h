//
//  CEUtils.h
//  CubeEngine
//
//  Created by chance on 15/3/18.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#pragma mark - System Tools

NSString *CEEngineDirectory(); // engine directory in bundle
NSString *CEShaderDirectory(); // Engine/Shaders

#pragma mark - Math Tools

// calculate in order of y, z, x (yaw, pitch, roll)
GLKQuaternion CEQuaternionWithEulerAngles(float y, float z, float x);

// get the rotation angles from quaternion, in degree
void CEGetEulerAngles(GLKQuaternion q, float *y, float *z, float *x);

/** 
 尝试压缩indices数据，根据最大的索引值来选择合适的数据类型存储数据
 [maxIndex < 256]    -> GLubyte
 [maxIndex < 65256]  -> GLushort
 [maxIndex >= 65256] -> GLuint
 
 @param originalData
    原始数据
 @param compressedData
    输出数据，指针类型。压缩失败时返回nil
 @param elementSize
    原始数据的元数据大小，数据类型在压缩过程中可能会变更。
 */
void CompressIndicesData(NSData *originalData, NSData **compressedData, GLsizei *elementSize);


#pragma mark - Color To Vector

GLKVector3 CEVec3WithColor(UIColor *color);
GLKVector4 CEVec4WithColor(UIColor *color);
UIColor *CEColorWithVec3(GLKVector3 vec3);
UIColor *CEColorWithVec4(GLKVector4 vec4);


#pragma mark - Hash

uint32_t CEHashValueWithString(NSString *string);


