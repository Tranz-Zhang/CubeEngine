//
//  CECamera.h
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEObject.h"

typedef NS_ENUM(NSInteger, CEProjectionType) {
    CEProjectionPerpective = 0,
    CEProjectionOrthographic,
};

/**
 Representing a camera in 3d world.
 IMPORTANT!!!: The camera's direction is -z after creation. So the rotation is kind of 
 different with normal CEObject in the scene. 
 
 Here's the difference:
 eulerAngles.X is used for up-down rotation,
 eulerAngles.Z rotate along the camera's direction, so it will rotate the entire screen.
 */
@interface CECamera : CEObject

/**
 The projection type of the camera.
 */
@property (nonatomic, assign) CEProjectionType projectionType;

/**
 The angle of the vertical viewing area for Perspective View. Default is 65
 */
@property (nonatomic, assign) float radianDegree;

/**
 The width of the orthographic box. default is 10;
 */
@property (nonatomic, assign) float orthoBoxWidth;

/**
 The ratio between the horizontal and the vertical viewing area.
 */
@property (nonatomic, assign) float aspect;

/** 
 The near clipping distance. Must be positive. Default is 0.1
 */
@property (nonatomic, assign) float nearZ;

/**
 The far clipping distance. Must be positive and greater than the near distance.
 Default is 100
 */
@property (nonatomic, assign) float farZ;

/**
 Make the camera facing to the target location, By default the camera is facing axis +Z
 */
- (void)lookAt:(GLKVector3)targetPosition;


@end

