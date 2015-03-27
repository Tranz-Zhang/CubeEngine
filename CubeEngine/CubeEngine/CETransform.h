//
//  CETransformInfo.h
//  CubeEngine
//
//  Created by chance on 15/3/12.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEVector3.h"

typedef NS_ENUM(NSInteger, CERelativeSpace) {
    CERelativeSpaceSelf = 0,
    CERelativeSpaceWorld,
};

/**
 Transform Infos
 */
@interface CETransform : NSObject

@property (nonatomic, readonly) CEVector3 *right;     // The axis X of the transform in world space.
@property (nonatomic, readonly) CEVector3 *up;        // The axis Y of the transform in world space.
@property (nonatomic, readonly) CEVector3 *forward;   // The axis Z of the transform in world space.

// world space, absolute value
@property (nonatomic, strong) CEVector3 *position;      // The position of the transform in world space.
@property (nonatomic, strong) CEVector3 *rotationAngles;   // The eular angles in XYZ axis, in degree.
@property (nonatomic, strong) CEVector3 *scale;         // The scale of the transform in world space.

// self space, ref to parent
@property (nonatomic, strong) CEVector3 *localPosition;     // Position of the transform relative to the parent transform.
@property (nonatomic, strong) CEVector3 *localRotationAngles;  // The rotation as Euler angles in degrees relative to the parent transform's rotation.

// Rotates the transform so the forward vector points at the target's position.
- (void)lookAt:(GLKVector3)targetPosition;

// Rotate around self's axis with angle
- (void)rotateAroundAxis:(GLKVector3)axisVector withAngle:(GLfloat)rotationDegree;

// Rotate around a fixed point's axis with angle
- (void)rotateAroundPoint:(GLKVector3)centerPoint axis:(GLKVector3)axisVector withAngle:(GLfloat)rotationDegree;

// scale around specific point other than the object's center.
- (void)scaleAroundPoint:(GLKVector3)centerPoint withSacleFactor:(GLKVector3)scaleFactor;


#pragma mark - Transform child
@property (nonatomic, readonly) CETransform *parentTransform;

- (void)addChildTransform:(CETransform *)childTransform;
- (void)removeChildTransfrom:(CETransform *)childTransform;


#pragma mark - Matrix
@property (nonatomic, readonly) GLKMatrix4 transformMatrix;

@end


