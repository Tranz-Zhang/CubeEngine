//
//  CECamera.h
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CEProjectionType) {
    CEProjectionPerpective = 0,
    CEProjectionOrthographic,
};

/**
 Representing a camera in 3d world.
 */
@interface CECamera : NSObject

/**
 The projection type of the camera.
 */
@property (atomic, assign) CEProjectionType projectionType;

/**
 The angle of the vertical viewing area. Default is 65
 */
@property (atomic, assign) float radianDegree;

/**
 The ratio between the horizontal and the vertical viewing area.
 */
@property (atomic, assign) float aspect;

/** 
 The near clipping distance. Must be positive. Default is 0.1
 */
@property (atomic, assign) float nearZ;

/**
 The far clipping distance. Must be positive and greater than the near distance.
 Default is 100
 */
@property (atomic, assign) float farZ;


/**
 Location of the camera.
 */
@property (atomic) GLKVector3 location;

/**
 The angle of the rotation for the camera (a positive angle is counterclockwise).
 */
@property (atomic) GLKVector3 rotationAxis;

/**
 The axis to perform the rotation around.
 */
@property (atomic) float rotationRadians;


/**
 Make the camera facing to the target location, By default the camera is facing axis +Z
 */
- (void)lookAt:(GLKVector3)targetLocation;


@end

