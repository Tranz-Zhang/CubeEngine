//
//  CEUtils.h
//  CubeEngine
//
//  Created by chance on 15/3/18.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

// calcualte the transfer quaternion between two vectors
GLKQuaternion QuaternionWithVectors(GLKVector3 fromVector, GLKVector3 toVector);

// calculate in order of y, z, x
GLKQuaternion QuaternionWithEulerAngles(float y, float z, float x);