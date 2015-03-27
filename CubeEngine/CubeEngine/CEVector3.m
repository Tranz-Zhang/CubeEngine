//
//  CEVector3.m
//  CubeEngine
//
//  Created by chance on 15/3/13.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEVector3.h"
#import "CEVector3_Delegate.h"

@implementation CEVector3

+ (CEVector3 *)vectorWithGLKVector:(GLKVector3)vector3 {
    CEVector3 *vector = [CEVector3 new];
    vector.x = vector3.x;
    vector.y = vector3.y;
    vector.z = vector3.z;
    return vector;
}

- (BOOL)isEqual:(CEVector3 *)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return other.x == _x && other.y == _y && other.z == _z;
    }
}

- (NSUInteger)hash
{
    return [super hash];
}


- (void)setX:(float)x {
    if (_x != x) {
        _x = x;
        if ([_delegate respondsToSelector:@selector(onValueChanged:)]) {
            [_delegate onValueChanged:self];
        }
    }
}


- (void)setY:(float)y {
    if (_y != y) {
        _y = y;
        if ([_delegate respondsToSelector:@selector(onValueChanged:)]) {
            [_delegate onValueChanged:self];
        }
    }
}


- (void)setZ:(float)z {
    if (_z != z) {
        _z = z;
        if ([_delegate respondsToSelector:@selector(onValueChanged:)]) {
            [_delegate onValueChanged:self];
        }
    }
}



@end
