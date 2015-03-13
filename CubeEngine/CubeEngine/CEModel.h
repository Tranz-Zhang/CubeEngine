//
//  CEObject.h
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, CEAxisMask) {
    CEAxisNone = 0,
    CEAxisX = 1 << 0,
    CEAxisY = 1 << 1,
    CEAxisZ = 1 << 2,
};


typedef NS_ENUM(NSInteger, CEVertextDataType) {
    CEVertextDataType_V3 = 0,   // vertex XYZ                           (size:3)
    CEVertextDataType_V3N3,     // vertex XYZ + normal XYZ              (size:6)
    CEVertextDataType_V3N3T2,   // vertex XYZ + normal XYZ + texture UV (size:8)
};

@interface CEModel : NSObject

// size of the model
@property (atomic, readonly) GLKVector3 size;

/**
 Act as the same as the anchorPoint of CALayer, but in 3D. the range of value should be 0.0f - 1.0f,
 The default value is (0.5f, 0.5f, 0.5f), which is the center of the model.
 */
@property (atomic, assign) GLKVector3 anchorPoint;

// transform properties
/**
 The location of the model, actually it's the location of model's anchor point.
 */
@property (atomic, assign) GLKVector3 location;

@property (atomic, readonly) GLfloat rotationDegree;
@property (atomic, readonly) CEAxisMask rotationAxis;

@property (atomic, assign) GLKVector3 scale;

+ (instancetype)modelWithVertexData:(NSData *)vertexData type:(CEVertextDataType)dataType;

- (void)setRotationWithDegree:(GLfloat)rotationDegree axis:(CEAxisMask)axis;
- (void)setScale:(GLfloat)scaleFactor axis:(CEAxisMask)axis ;


@end




