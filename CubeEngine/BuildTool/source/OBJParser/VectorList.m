//
//  VectorList.m
//  CubeEngine
//
//  Created by chance on 9/28/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "VectorList.h"

@implementation VectorList {
    NSMutableData *_vectorData;
}

- (instancetype)initWithVectorType:(VectorType)vectorType {
    return [self initWithVectorType:vectorType itemCount:0];
}


- (instancetype)initWithVectorType:(VectorType)vectorType itemCount:(NSInteger)itemCount {
    self = [super init];
    if (self) {
        NSAssert(vectorType > 0 && vectorType < 5, @"unsupport vector type");
        _vectorType = vectorType;
        if (itemCount) {
            _vectorData = [NSMutableData dataWithLength:(_vectorType * sizeof(float) * itemCount)];
        } else {
            _vectorData = [NSMutableData data];
        }
        _count = itemCount;
    }
    return self;
}


- (void)addFloat:(float)floatValue {
    if (_vectorType != VectorType1) return;
    [_vectorData appendBytes:&floatValue length:sizeof(float)];
    _count++;
}

- (void)addVector2:(GLKVector2)vec2 {
    if (_vectorType != VectorType2) return;
    [_vectorData appendBytes:vec2.v length:sizeof(GLKVector2)];
    _count++;
}

- (void)addVector3:(GLKVector3)vec3 {
    if (_vectorType != VectorType3) return;
    [_vectorData appendBytes:vec3.v length:sizeof(GLKVector3)];
    _count++;
}

- (void)addVector4:(GLKVector4)vec4 {
    if (_vectorType != VectorType4) return;
    [_vectorData appendBytes:vec4.v length:sizeof(GLKVector4)];
    _count++;
}


- (void)setFloat:(float)floatValue atIndex:(NSInteger)index {
    NSRange valueRange = NSMakeRange(index * sizeof(float), sizeof(float));
    if (NSMaxRange(valueRange) > _vectorData.length) {
        return;
    }
    [_vectorData replaceBytesInRange:valueRange withBytes:&floatValue];
}

- (void)setVector2:(GLKVector2)vec2 atIndex:(NSInteger)index {
    NSRange valueRange = NSMakeRange(index * sizeof(GLKVector2), sizeof(GLKVector2));
    if (NSMaxRange(valueRange) > _vectorData.length) {
        return;
    }
    [_vectorData replaceBytesInRange:valueRange withBytes:vec2.v];
}

- (void)setVector3:(GLKVector3)vec3 atIndex:(NSInteger)index {
    NSRange valueRange = NSMakeRange(index * sizeof(GLKVector3), sizeof(GLKVector3));
    if (NSMaxRange(valueRange) > _vectorData.length) {
        return;
    }
    [_vectorData replaceBytesInRange:valueRange withBytes:vec3.v];
}

- (void)setVector4:(GLKVector4)vec4 atIndex:(NSInteger)index {
    NSRange valueRange = NSMakeRange(index * sizeof(GLKVector4), sizeof(GLKVector4));
    if (NSMaxRange(valueRange) > _vectorData.length) {
        return;
    }
    [_vectorData replaceBytesInRange:valueRange withBytes:vec4.v];
}


- (float)floatAtIndex:(NSInteger)index {
    if (index >= _vectorData.length / _vectorType) {
        return 0;
    }
    
    float floatValue = 0.0f;
    [_vectorData getBytes:&floatValue range:NSMakeRange(index * sizeof(float), sizeof(float))];
    return floatValue;
}

- (GLKVector2)vector2AtIndex:(NSInteger)index {
    if (index >= _vectorData.length / _vectorType) {
        return GLKVector2Make(0, 0);
    }
    
    GLKVector2 vec2;
    [_vectorData getBytes:&vec2 range:NSMakeRange(index * sizeof(GLKVector2), sizeof(GLKVector2))];
    return vec2;

}

- (GLKVector3)vector3AtIndex:(NSInteger)index {
    if (index >= _vectorData.length / _vectorType) {
        return GLKVector3Make(0, 0, 0);
    }
    GLKVector3 vec3;
    [_vectorData getBytes:&vec3 range:NSMakeRange(index * sizeof(GLKVector3), sizeof(GLKVector3))];
    return vec3;
}

- (GLKVector4)vector4AtIndex:(NSInteger)index {
    if (index >= _vectorData.length / _vectorType) {
        return GLKVector4Make(0, 0, 0, 0);
    }
    GLKVector4 vec4;
    [_vectorData getBytes:&vec4 range:NSMakeRange(index * sizeof(GLKVector4), sizeof(GLKVector4))];
    return vec4;
}


- (NSInteger)indexOfValueFloat:(float)floatValue {
    for (int i = 0; i < _count; i++) {
        float value = [self floatAtIndex:i];
        if (value == floatValue) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSInteger)indexOfValueVector2:(GLKVector2)vec2 {
    for (int i = 0; i < _count; i++) {
        GLKVector2 value = [self vector2AtIndex:i];
        if (GLKVector2AllEqualToVector2(value, vec2)) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSInteger)indexOfValueVector3:(GLKVector3)vec3 {
    for (int i = 0; i < _count; i++) {
        GLKVector3 value = [self vector3AtIndex:i];
        if (GLKVector3AllEqualToVector3(value, vec3)) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSInteger)indexOfValueVector4:(GLKVector4)vec4 {
    for (int i = 0; i < _count; i++) {
        GLKVector4 value = [self vector4AtIndex:i];
        if (GLKVector4AllEqualToVector4(value, vec4)) {
            return i;
        }
    }
    return NSNotFound;
}


- (NSString *)description {
    NSMutableString *des = [NSMutableString string];
    for (int i = 0; i < _count; i++) {
        switch (_vectorType) {
            case VectorType3: {
                GLKVector3 vec3 = [self vector3AtIndex:i];
                [des appendFormat:@"(%.5f, %.5f, %.5f)\n", vec3.x, vec3.y, vec3.z];
                break;
            }
            case VectorType2: {
                GLKVector2 vec2 = [self vector2AtIndex:i];
                [des appendFormat:@"(%.5f, %.5f)\n", vec2.x, vec2.y];
                break;
            }
            case VectorType4: {
                GLKVector4 vec4 = [self vector4AtIndex:i];
                [des appendFormat:@"(%.5f, %.5f, %.5f, %.5f)\n", vec4.x, vec4.y, vec4.z, vec4.w];
                break;
            }
            case VectorType1: {
                float floatValue = [self floatAtIndex:i];
                [des appendFormat:@"%.5f\n", floatValue];
                break;
            }
            default:
                break;
        }
    }
    
    return des.copy;
}


@end

