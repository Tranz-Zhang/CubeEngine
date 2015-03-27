//
//  CEObject.m
//  CubeEngine
//
//  Created by chance on 15/3/13.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEObject.h"

@interface CEObject () {
    __weak CEObject *_parentObject;
    NSMutableArray *_childObjects;
    
    BOOL _hasChanged;
    GLKMatrix4 _localTransformMatrix;
}

@end



@implementation CEObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _childObjects = [NSMutableArray array];
        _position = GLKVector3Make(0, 0, 0);
        _rotation = GLKQuaternionIdentity;
        _eulerAngles = GLKVector3Make(0, 0, 0);
        _localTransformMatrix = GLKMatrix4Identity;
        _scale = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _hasChanged = YES;
    }
    return self;
}


#pragma mark - Setters & Getters

- (CEObject *)parentObject {
    return _parentObject;
}


- (void)setParentObject:(CEObject *)parentObject {
    if (_parentObject != parentObject) {
        _parentObject = parentObject;
    }
}


- (void)setPosition:(GLKVector3)position {
    if (!GLKVector3AllEqualToVector3(_position, position)) {
        _position = position;
        _hasChanged = YES;
    }
}


- (void)setRotation:(GLKQuaternion)rotation {
    if (rotation.s != _rotation.s ||
        !GLKVector3AllEqualToVector3(rotation.v, _rotation.v)) {
        _rotation = rotation;
        // TODO: calcuate angles
        
        _right = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(1, 0, 0));
        _up = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 1, 0));
        _forward = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 0, 1));
        
        _hasChanged = YES;
    }
}


- (void)setEulerAngles:(GLKVector3)eulerAngles {
#warning hey, you may want to change the order to y z x.
    /*
     roll yaw pitch
      x    y    z
      0    1    2
     */
    if (!GLKVector3AllEqualToVector3(_eulerAngles, eulerAngles)) {
        GLKQuaternion rotationX = GLKQuaternionIdentity;
        GLKQuaternion rotationY = GLKQuaternionIdentity;
        GLKQuaternion rotationZ = GLKQuaternionIdentity;
        GLKVector3 vectorY = GLKVector3Make(0, 1, 0);
        GLKVector3 vectorZ = GLKVector3Make(0, 0, 1);
        // axis X
        if (eulerAngles.x != 0) {
            rotationX = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(eulerAngles.x), 1, 0, 0);
            vectorY = GLKQuaternionRotateVector3(rotationX, vectorY);
            vectorZ = GLKQuaternionRotateVector3(rotationX, vectorZ);
        }
        
        // axis Y, should limit to [-PI_2, PI_2]?
        if (eulerAngles.y != 0) {
            rotationY = GLKQuaternionMakeWithAngleAndVector3Axis(GLKMathDegreesToRadians(eulerAngles.y), vectorY);
            vectorZ = GLKQuaternionRotateVector3(rotationY, vectorZ);
        }
        
        // axix Z
        if (eulerAngles.z != 0) {
            rotationZ = GLKQuaternionMakeWithAngleAndVector3Axis(GLKMathDegreesToRadians(eulerAngles.z), vectorZ);
        }
        _eulerAngles = eulerAngles;
        _rotation = GLKQuaternionMultiply(rotationZ, GLKQuaternionMultiply(rotationY, rotationX));
        _right = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(1, 0, 0));
        _up = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 1, 0));
        _forward = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 0, 1));
        
        GLKQuaternion q = _rotation;
        float angleX = atan2(2 * (q.x * q.w - q.y * q.z), 1 - 2 * (pow(q.x, 2) + pow(q.y, 2)));
        float angleY = asin(2 * (q.x * q.z + q.y * q.w));
        float angleZ = atan2(2 * (q.z * q.w - q.y * q.x), 1 - 2 * (pow(q.z, 2) + pow(q.y, 2)));
        
        
//        GLKQuaternion q = _rotation;
        double sqw = q.w*q.w;
        double sqx = q.x*q.x;
        double sqy = q.y*q.y;
        double sqz = q.z*q.z;
        double unit = sqx + sqy + sqz + sqw; // if normalised is one, otherwise is correction factor
        double test = q.x*q.z + q.y*q.w;
        if (test > 0.499 * unit) { // singularity at north pole
            angleX = M_PI_2;
            angleY = 2 * atan2(q.z, q.w);
            angleZ = 0;
            
        } else if (test < -0.499 * unit) { // singularity at south pole
            angleX = M_PI_2;
            angleY = -2 * atan2(q.z, q.w);
            angleZ = 0;
            
        } else {
            angleX = atan2(2 * (q.x * q.w - q.y * q.z) , sqw + sqz - sqx - sqy);
            angleY = asin(2 * test / unit);
            angleZ = atan2(2 * (q.z * q.w - q.y * q.x) , sqw + sqx - sqy - sqz);
        }
//        angleX = atan2(2 * (q.x * q.w - q.y * q.z) , sqw + sqz - sqx - sqy);
//        angleY = asin(2 * test / unit);
//        angleZ = atan2(2 * (q.z * q.w - q.y * q.x) , sqw + sqx - sqy - sqz);
        
        angleX = GLKMathRadiansToDegrees(angleX);
        angleY = GLKMathRadiansToDegrees(angleY);
        angleZ = GLKMathRadiansToDegrees(angleZ);
        printf("(%.1f, %.1f, %.1f) -> (%.1f, %.1f, %.1f)\n",_eulerAngles.x, _eulerAngles.y, _eulerAngles.z, angleX, angleY, angleZ);
        
        _hasChanged = YES;
    }
}




- (void)setScale:(GLKVector3)scale {
    if (!GLKVector3AllEqualToVector3(_scale, scale)) {
        _scale = scale;
        _hasChanged = YES;
    }
}


#pragma mark - Transform
- (void)lookAt:(GLKVector3)targetPosition {
//    GLKMatrix4 rotationMatrix = GLKMatrix4MakeLookAt(_position.x, _position.y, _position.z, targetPosition.x, targetPosition.y, targetPosition.z, 0.0f, 1.0f, 0.0f);
//    // calculate axis angles
//    float angleX = atan2(rotationMatrix.m22, rotationMatrix.m12);
//    float angleY = atan2(-rotationMatrix.m02, sqrt(pow(rotationMatrix.m12, 2) + pow(rotationMatrix.m22, 2)));
//    float angleZ = atan2(rotationMatrix.m01, rotationMatrix.m00);
//    [self setRotation:GLKVector3Make(GLKMathRadiansToDegrees(angleX),
//                                     GLKMathRadiansToDegrees(angleY),
//                                     GLKMathRadiansToDegrees(angleZ))];
//    _rotation = GLKVector3Make(GLKMathRadiansToDegrees(angleX),
//                               GLKMathRadiansToDegrees(angleY),
//                               GLKMathRadiansToDegrees(angleZ));
//    _hasChanged = YES;
}


- (GLKMatrix4)transformMatrix {
    if (_hasChanged) {
        // update direction vector
        _forward = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 0, 1));
        _right = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(1, 0, 0));
        _up = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 2, 0));
        
        // update local transfrom matrix
        GLKMatrix4 tranformMatrix = GLKMatrix4MakeTranslation(_position.x, _position.y, _position.z);
        tranformMatrix = GLKMatrix4Multiply(tranformMatrix, GLKMatrix4MakeWithQuaternion(_rotation));
        tranformMatrix = GLKMatrix4ScaleWithVector3(tranformMatrix, _scale);
        
        _localTransformMatrix = tranformMatrix;
        _hasChanged = NO;
    }
    
    if (_parentObject) {
        return GLKMatrix4Multiply(_parentObject.transformMatrix, _localTransformMatrix);
        
    } else {
        return _localTransformMatrix;
    }
}


#pragma mark - Child Objects
- (NSArray *)childObjects {
    return _childObjects.copy;
}

- (void)addChildObject:(CEObject *)child {
    if ([child isKindOfClass:[CEObject class]]) {
        [_childObjects addObject:child];
        [child setParentObject:self];
    }
}

- (void)removeChildObject:(CEObject *)child {
    if ([child isKindOfClass:[CEObject class]]) {
        [_childObjects removeObject:child];
    }
}

- (void)removeFromParent {
    [self.parentObject removeChildObject:self];
    self.parentObject = nil;
}


- (CEObject *)childWithTag:(NSInteger)tag {
    for (CEObject *childObject in _childObjects) {
        if (childObject.tag == tag) {
            return childObject;
        }
    }
    return nil;
}


@end


