//
//  CEUtils.m
//  CubeEngine
//
//  Created by chance on 15/3/18.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEUtils.h"
#import "CEDirectoryDefines.h"

#pragma mark - System Tools

// engine directory in bundle
NSString * CEEngineDirectory() {
    static NSString *sEngineDirectory = nil;
    if (!sEngineDirectory) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            sEngineDirectory = [bundlePath stringByAppendingPathComponent:kEngineDirectory];
        });
    }
    return sEngineDirectory;
}

// Engine/Shaders
NSString *CEShaderDirectory() {
    static NSString *sShaderDirectory = nil;
    if (!sShaderDirectory) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            sShaderDirectory = [bundlePath stringByAppendingPathComponent:kShaderDirectory];
        });
    }
    return sShaderDirectory;
}


#pragma mark - Math Tools

// ref: http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToQuaternion/
GLKQuaternion CEQuaternionWithEulerAngles(float y, float z, float x) {
    double c1 = cos(GLKMathDegreesToRadians(y) / 2);
    double s1 = sin(GLKMathDegreesToRadians(y) / 2);
    double c2 = cos(GLKMathDegreesToRadians(z) / 2);
    double s2 = sin(GLKMathDegreesToRadians(z) / 2);
    double c3 = cos(GLKMathDegreesToRadians(x) / 2);
    double s3 = sin(GLKMathDegreesToRadians(x) / 2);
    double c1c2 = c1*c2;
    double s1s2 = s1*s2;
    return GLKQuaternionMake(c1c2*s3 + s1s2*c3,
                             s1*c2*c3 + c1*s2*s3,
                             c1*s2*c3 - s1*c2*s3,
                             c1c2*c3 - s1s2*s3);
}


// ref: http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToEuler/index.htm
void CEGetEulerAngles(GLKQuaternion q, float *y, float *z, float *x) {
    double sqw = q.w * q.w;
    double sqx = q.x * q.x;
    double sqy = q.y * q.y;
    double sqz = q.z * q.z;
    double unit = sqx + sqy + sqz + sqw; // if normalised is one, otherwise is correction factor
    double test = q.x * q.y + q.z * q.w;
    if (test > 0.49999 * unit) { // singularity at north pole
        *y = GLKMathRadiansToDegrees(2 * atan2(q.x,q.w));
        *z = GLKMathRadiansToDegrees(M_PI_2);
        *x = GLKMathRadiansToDegrees(0);
        return;
    }
    if (test < -0.49999 * unit) { // singularity at south pole
        *y = GLKMathRadiansToDegrees(2 * atan2(q.x,q.w));
        *z = GLKMathRadiansToDegrees(-M_PI_2);
        *x = GLKMathRadiansToDegrees(0);
        return;
    }
    double angleY = atan2(2 * q.y * q.w - 2 * q.x * q.z , sqx - sqy - sqz + sqw);
    double angleZ = asin(2 * test / unit);
    double angleX = atan2(2 * q.x * q.w - 2 * q.y * q.z , -sqx + sqy - sqz + sqw);
    *y = GLKMathRadiansToDegrees(angleY);
    *z = GLKMathRadiansToDegrees(angleZ);
    *x = GLKMathRadiansToDegrees(angleX);
}


void CompressIndicesData(NSData *originalData, NSData **compressedData, GLsizei *elementSize) {
    if (!originalData || !compressedData || !elementSize || *elementSize <= 0) {
        CEError(@"Fail to compress indices data: wrong inputs");
        return;
    }
    
    if (originalData.length % *elementSize) {
        CEError(@"Fail to compress indices data: wrong data alignment");
        *compressedData = nil;
        return;
    }
    
    // get max index
    GLsizei inputStride = *elementSize;
    GLsizei indicesCount = (GLsizei)(originalData.length / inputStride);
    GLint maxIndex = -1;
    NSRange readRange = NSMakeRange(0, inputStride);
    for (int i = 0; i < indicesCount; i++) {
        GLint index = 0;
        [originalData getBytes:&index range:readRange];
        if (maxIndex < index) maxIndex = index;
        readRange.location += inputStride;
    }
    
    // output stride
    GLsizei outputStride = 0;
    if (maxIndex > 65525) {
        outputStride = sizeof(GLuint);
        
    } else if (maxIndex > 255) {
        outputStride = sizeof(GLushort);
        
    } else if (maxIndex >= 0) {
        outputStride = sizeof(GLubyte);
        
    } else {
        CEError(@"Fail to compress indices data: can not find max index");
        *compressedData = nil;
        return;
    }
    
    // compress
    if (outputStride == inputStride) {
        *compressedData = originalData;
        return;
    }
    
    NSUInteger outputSize = originalData.length * ((float)inputStride / outputStride);
    NSMutableData *outputData = [NSMutableData dataWithCapacity:outputSize];
    readRange.location = 0;
    for (int i = 0; i < indicesCount; i++) {
        GLint index = 0;
        [originalData getBytes:&index range:readRange];
        [outputData appendBytes:&index length:outputStride];
        readRange.location += inputStride;
    }
    *compressedData = [outputData copy];
    *elementSize = outputStride;
}


/*
void CompressUnsignedShortIndicesData(NSData *originalData, NSData **outputData, BOOL *hasCompressed) {
    if (!originalData.length || !outputData || !hasCompressed) {
        CEError(@"Fail to compress indices data: wrong inputs");
        *outputData = nil;
        return;
    }
    
    GLsizei elementSize = sizeof(GLushort);
    // check data alignment
    if (originalData.length % elementSize) {
        CEError(@"Fail to compress indices data: wrong data alignment");
        *outputData = nil;
        *hasCompressed = NO;
        return;
    }
    
    GLsizei indicesCount = (GLsizei)(originalData.length / elementSize);    
    // do compress
    NSMutableData *compressedData = [NSMutableData dataWithCapacity:originalData.length / 2];
    NSRange readRange = NSMakeRange(0, elementSize);
    for (int i = 0; i < indicesCount; i++) {
        GLushort ushortIndex = 0;
        [originalData getBytes:&ushortIndex range:readRange];
        if (ushortIndex > 255) { // max indices overflow, should not compress
            *outputData = originalData;
            *hasCompressed = NO;
            return;
        }
        GLbyte byteIndex = ushortIndex;
        [compressedData appendBytes:&byteIndex length:sizeof(GLbyte)];
        readRange.location += elementSize;
    }
    
    *hasCompressed = YES;
    *outputData = [compressedData copy];
}
//*/


#pragma mark - Color To Vector
GLKVector3 CEVec3WithColor(UIColor *color) {
    CGFloat r, g, b;
    [color getRed:&r green:&g blue:&b alpha:NULL];
    return GLKVector3Make(r, g, b);
}

GLKVector4 CEVec4WithColor(UIColor *color) {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return GLKVector4Make(r, g, b, a);
}

UIColor *CEColorWithVec3(GLKVector3 vec3) {
    return [UIColor colorWithRed:vec3.r green:vec3.g blue:vec3.b alpha:1.0];
}

UIColor *CEColorWithVec4(GLKVector4 vec4) {
    return [UIColor colorWithRed:vec4.r green:vec4.g blue:vec4.b alpha:vec4.a];
}














