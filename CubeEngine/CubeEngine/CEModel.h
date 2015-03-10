//
//  CEObject.h
//  CubeEngine
//
//  Created by chance on 15/3/6.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, CERotationPivot) {
    CERotationPivotNone = 0,
    CERotationPivotX = 1 << 0,
    CERotationPivotY = 1 << 1,
    CERotationPivotZ = 1 << 2,
};

typedef NS_ENUM(NSInteger, CEVertextDataType) {
    CEVertextDataType_V3 = 0,   // vertex XYZ                           (size:3)
    CEVertextDataType_V3N3,     // vertex XYZ + normal XYZ              (size:6)
    CEVertextDataType_V3N3T2,   // vertex XYZ + normal XYZ + texture UV (size:8)
};

@interface CEModel : NSObject

// size of the model
@property (nonatomic, readonly) GLKVector3 size;


// transform properties
@property (atomic, assign) GLKVector3 location;
@property (atomic, assign) float scale;
@property (atomic, readonly) CERotationPivot rotationPivot;
@property (atomic, readonly) float rotationDegree;

// positive value for counter clockwise
- (void)setRotation:(GLfloat)rotationDegree onPivot:(CERotationPivot)rotationPivot;


- (instancetype)initWithVertexData:(NSData *)vertexData dataType:(CEVertextDataType)dataType;

@end
