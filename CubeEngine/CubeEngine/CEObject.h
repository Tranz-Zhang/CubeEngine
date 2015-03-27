//
//  CEObject.h
//  CubeEngine
//
//  Created by chance on 15/3/13.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Represting an object in 3D world, which can be points, lines or meshes.
 */
@interface CEObject : NSObject

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, readonly) CEObject *parentObject;
@property (nonatomic, readonly) NSArray *childObjects;


#pragma mark - Transfrom

/**
 Position of the transform relative to the parent transform.
 
 Note that the parent transform's world rotation and scale are applied to the 
 local position when calculating the world position.
 */
@property (nonatomic, assign) GLKVector3 position;

/**
 The rotation of the transform relative to the parent transform's rotation.
 */
@property (nonatomic, assign) GLKQuaternion rotation;

/**
 The vector3 contain the euler angles around x, y, z axis, in degrees, relative 
 to the parent transform's rotation.
 The object rotates euler.x degrees around the x axis, euler.y degrees around
 the y axis and euler.z degrees around the z axis, and  (in that order).
 Only use this variable to read and set the angles to absolute values. Don't
 increment them, as it will fail when the angle exceeds 360 degrees. 
 Use Transform.Rotate instead.
 */
@property (nonatomic, assign) GLKVector3 eulerAngles;

/**
 The scale of the transform relative to the parent transform's rotation.
 */
@property (nonatomic, assign) GLKVector3 scale;

@property (nonatomic, readonly) GLKVector3 forward; /** The front side of the object ,default is axis +Z */
@property (nonatomic, readonly) GLKVector3 right;   /** The right side of the object ,default is axis +X */
@property (nonatomic, readonly) GLKVector3 up;      /** The up side of the object ,default is axis +Y */

/**
 A matrix representing the transform of the object, including translation, rotation and scale.
 */
@property (nonatomic, readonly) GLKMatrix4 transformMatrix;

- (void)moveTowards:(GLKVector3)directionVector withDistance:(float)direction;

- (void)lookAt:(GLKVector3)targetPosition;


#pragma mark - Object Hierarchy
- (void)addChildObject:(CEObject *)child;
- (void)removeFromParent;
- (CEObject *)childWithTag:(NSInteger)tag;

@end
