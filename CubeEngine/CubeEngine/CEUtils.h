//
//  CEUtils.h
//  CubeEngine
//
//  Created by chance on 15/3/18.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

// calculate in order of y, z, x (yaw, pitch, roll)
GLKQuaternion CEQuaternionWithEulerAngles(float y, float z, float x);

// get the rotation angles from quaternion, in degree
void CEGetEulerAngles(GLKQuaternion q, float *y, float *z, float *x);

