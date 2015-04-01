//
//  CEUtils.m
//  CubeEngine
//
//  Created by chance on 15/3/18.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEUtils.h"


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
        *y = 2 * atan2(q.x,q.w);
        *z = M_PI_2;
        *x = 0;
        return;
    }
    if (test < -0.49999 * unit) { // singularity at south pole
        *y = -2 * atan2(q.x,q.w);
        *z = -M_PI_2;
        *x = 0;
        return;
    }
    double angleY = atan2(2 * q.y * q.w - 2 * q.x * q.z , sqx - sqy - sqz + sqw);
    double angleZ = asin(2 * test / unit);
    double angleX = atan2(2 * q.x * q.w - 2 * q.y * q.z , -sqx + sqy - sqz + sqw);
    *y = GLKMathRadiansToDegrees(angleY);
    *z = GLKMathRadiansToDegrees(angleZ);
    *x = GLKMathRadiansToDegrees(angleX);
}

