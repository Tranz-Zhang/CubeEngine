//
//  CETransformInfo.m
//  CubeEngine
//
//  Created by chance on 15/3/12.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CETransform.h"
#import "CEVector3_Delegate.h"

@interface CETransform () <CEVector3Delegate> {
    BOOL _hasChanged;
}

@end


@implementation CETransform

- (instancetype)init
{
    self = [super init];
    if (self) {
        _right = [CEVector3 new];
        _right.delegate = self;
        _up = [CEVector3 new];
        _up.delegate = self;
        _forward = [CEVector3 new];
        _forward.delegate = self;
        
        _position = [CEVector3 new];
        _position.delegate = self;
        _rotationAngles = [CEVector3 new];
        _rotationAngles.delegate = self;
        _scale = [CEVector3 new];
        _scale.delegate = self;
        
        _localPosition = [CEVector3 new];
        _localPosition.delegate = self;
        _localRotationAngles = [CEVector3 new];
        _localRotationAngles.delegate = self;
    }
    return self;
}


#pragma mark - Setters
- (void)setPosition:(CEVector3 *)position {
    if ([_position isEqual:position]) {
        _position = position;
        _hasChanged = YES;
    }
}

- (void)setRotationAngles:(CEVector3 *)rotationAngles {
    if ([_rotationAngles isEqual:rotationAngles]) {
        _rotationAngles = rotationAngles;
        _hasChanged = YES;
    }
}

- (void)setScale:(CEVector3 *)scale {
    if ([_scale isEqual:scale]) {
        _scale = scale;
        _hasChanged = YES;
    }
}

- (void)setLocalPosition:(CEVector3 *)localPosition {
    if ([_localPosition isEqual:localPosition]) {
        _localPosition = localPosition;
        _hasChanged = YES;
    }
}

- (void)setLocalRotationAngles:(CEVector3 *)localRotationAngles {
    if ([_localRotationAngles isEqual:localRotationAngles]) {
        _localRotationAngles = localRotationAngles;
        _hasChanged = YES;
    }
}

#pragma mark - CEVector3Delegate




#pragma mark - API

//- (void)lookAt:(GLKVector3)targetPosition {
//    
//}
//
//
//- (void)rotateAroundAxis:(GLKVector3)axisVector withAngle:(GLfloat)rotationDegree {
//    
//}
//
//
//- (void)rotateAroundPoint:(GLKVector3)centerPoint axis:(GLKVector3)axisVector withAngle:(GLfloat)rotationDegree {
//    
//}
//
//
//- (void)scaleAroundPoint:(GLKVector3)centerPoint withSacleFactor:(GLKVector3)scaleFactor {
//    
//}
//
//- (void)updateMatrix {
//    
//}

//- (GLKMatrix4)transformMatrix {
//    if (_hasChanged) {
//        [self updateMatrix];
//    }
//    
//    GLKMatrix4 tranformMatrix = GLKMatrix4MakeTranslation(self.position.x,
//                                                          self.position.y,
//                                                          self.position.z);
//    if (_rotationPivot) {
//        tranformMatrix = GLKMatrix4Rotate(tranformMatrix,
//                                          GLKMathDegreesToRadians(_rotationDegree),
//                                          _rotationPivot & CERotationPivotX ? 1 : 0,
//                                          _rotationPivot & CERotationPivotY ? 1 : 0,
//                                          _rotationPivot & CERotationPivotZ ? 1 : 0);
//    }
//    if (_scale != 1) {
//        GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(_scale, _scale, _scale);
//        GLKMatrix4 adjustMatrix = GLKMatrix4MakeTranslation(-1, 0, 0);
//        GLKMatrix4 transposeAdjustMatrix = GLKMatrix4Invert(adjustMatrix, NULL);
//        tranformMatrix = GLKMatrix4Multiply(transposeAdjustMatrix, GLKMatrix4Multiply(scaleMatrix, GLKMatrix4Multiply(adjustMatrix, tranformMatrix)));
//    }
//    
//}


@end






