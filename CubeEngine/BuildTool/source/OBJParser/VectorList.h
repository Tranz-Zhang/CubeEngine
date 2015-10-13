//
//  VectorList.h
//  CubeEngine
//
//  Created by chance on 9/28/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, VectorType) {
    VectorType1 = 1,    // float
    VectorType2,        // vec2
    VectorType3,        // vec3
    VectorType4,        // vec4
};

@interface VectorList : NSObject

@property (nonatomic, readonly) VectorType vectorType;
@property (nonatomic, readonly) NSUInteger count;

- (instancetype)initWithVectorType:(VectorType)vectorType;

// this method will preload space for vector list,
- (instancetype)initWithVectorType:(VectorType)vectorType itemCount:(NSInteger)itemCount;

- (void)addFloat:(float)floatValue;
- (void)addVector2:(GLKVector2)vec2;
- (void)addVector3:(GLKVector3)vec3;
- (void)addVector4:(GLKVector4)vec4;

- (void)setFloat:(float)floatValue atIndex:(NSInteger)index;
- (void)setVector2:(GLKVector2)vec2 atIndex:(NSInteger)index;
- (void)setVector3:(GLKVector3)vec3 atIndex:(NSInteger)index;
- (void)setVector4:(GLKVector4)vec4 atIndex:(NSInteger)index;

- (float)floatAtIndex:(NSInteger)index;
- (GLKVector2)vector2AtIndex:(NSInteger)index;
- (GLKVector3)vector3AtIndex:(NSInteger)index;
- (GLKVector4)vector4AtIndex:(NSInteger)index;


- (NSInteger)indexOfValueFloat:(float)floatValue;
- (NSInteger)indexOfValueVector2:(GLKVector2)vec2;
- (NSInteger)indexOfValueVector3:(GLKVector3)vec3;
- (NSInteger)indexOfValueVector4:(GLKVector4)vec4;

@end
