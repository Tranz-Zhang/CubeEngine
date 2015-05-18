//
//  CEObject.m
//  CubeEngine
//
//  Created by chance on 15/3/13.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CEObject.h"
#import "CEUtils.h"

@implementation CEObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _position = GLKVector3Make(0, 0, 0);
        _rotation = GLKQuaternionIdentity;
        _eulerAngles = GLKVector3Make(0, 0, 0);
        _transformMatrix = GLKMatrix4Identity;
        _scale = GLKVector3Make(1.0f, 1.0f, 1.0f);
        _right = GLKVector3Make(1.0f, 0.0f, 0.0f);
        _up = GLKVector3Make(0.0f, 1.0f, 0.0f);
        _forward = GLKVector3Make(0.0f, 0.0f, 1.0f);
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
        [self recursiveSetHasChanged:YES];
    }
}


- (void)setRotation:(GLKQuaternion)rotation {
    if (rotation.s != _rotation.s ||
        !GLKVector3AllEqualToVector3(rotation.v, _rotation.v)) {
        _rotation = rotation;
        _right = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(1, 0, 0));
        _up = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 1, 0));
        _forward = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 0, 1));
        
        float angleX, angleY, angleZ;
        CEGetEulerAngles(rotation, &angleY, &angleZ, &angleX);
        _eulerAngles = GLKVector3Make(angleX, angleY, angleZ);
        [self recursiveSetHasChanged:YES];
    }
}


- (void)setEulerAngles:(GLKVector3)eulerAngles {
    if (!GLKVector3AllEqualToVector3(_eulerAngles, eulerAngles)) {
        _eulerAngles = eulerAngles;
        _rotation = CEQuaternionWithEulerAngles(eulerAngles.y, eulerAngles.z, eulerAngles.x);
        _right = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(1, 0, 0));
        _up = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 1, 0));
        _forward = GLKQuaternionRotateVector3(_rotation, GLKVector3Make(0, 0, 1));
        [self recursiveSetHasChanged:YES];
//        CEPrintf("EulerAngles: (%.1f, %.1f, %.1f)\n", _eulerAngles.x, _eulerAngles.y, _eulerAngles.z);
    }
}


- (void)setScale:(GLKVector3)scale {
    if (!GLKVector3AllEqualToVector3(_scale, scale)) {
        _scale = scale;
        [self recursiveSetHasChanged:YES];
    }
}


- (BOOL)hasChanged {
    if (_hasChanged) {
        return YES;
        
    } else if (_parentObject) {
        return [_parentObject hasChanged];
        
    } else {
        return NO;
    }
}


- (void)recursiveSetHasChanged:(BOOL)hasChanged {
    _hasChanged = hasChanged;
    for (CEObject *child in _childObjects) {
        [child recursiveSetHasChanged:hasChanged];
    }
}


#pragma mark - Transform
- (void)moveTowards:(GLKVector3)directionVector withDistance:(float)direction {
    GLKVector3 normalizedVector = GLKVector3Normalize(directionVector);
    GLKVector3 newPosition = GLKVector3Make(_position.x + direction * normalizedVector.x,
                                            _position.y + direction * normalizedVector.y,
                                            _position.z + direction * normalizedVector.z);
    _position = newPosition;
    [self recursiveSetHasChanged:YES];
}


- (void)lookAt:(GLKVector3)targetPosition {
    GLKVector3 v1 = _right;//(1, 0, 0);
    GLKVector3 v2 = GLKVector3Make(targetPosition.x - _position.x,
                                   targetPosition.y - _position.y,
                                   targetPosition.z - _position.z);
    GLKVector3 deltaVector = GLKVector3CrossProduct(v1, v2);
    double w = sqrt(pow(GLKVector3Length(v1), 2) * pow(GLKVector3Length(v2), 2)) + GLKVector3DotProduct(v1, v2);
    GLKQuaternion deltaRotation;
    if (w < 0.0001) {
        // vectors are 180 degrees apart
        deltaRotation = GLKQuaternionNormalize(GLKQuaternionMake(-v1.z, v1.x, v1.y, 0));
        
    } else {
        deltaRotation = GLKQuaternionMake(deltaVector.x, deltaVector.y, deltaVector.z, w);
    }
    GLKQuaternion rotation = GLKQuaternionMultiply(GLKQuaternionNormalize(deltaRotation), _rotation);
    float angleX, angleY, angleZ;
    CEGetEulerAngles(rotation, &angleY, &angleZ, &angleX);
    // NOTE: the roll rotation is eliminated.
    [self setEulerAngles:GLKVector3Make(0, angleY, angleZ)];
}


- (GLKMatrix4)transformMatrix {
    if (!self.hasChanged) {
        return _transformMatrix;
    }
    
    if (_hasChanged) {
        // update local transfrom matrix
        GLKMatrix4 tranformMatrix = GLKMatrix4MakeTranslation(_position.x, _position.y, _position.z);
        tranformMatrix = GLKMatrix4Multiply(tranformMatrix, GLKMatrix4MakeWithQuaternion(_rotation));
        tranformMatrix = GLKMatrix4ScaleWithVector3(tranformMatrix, _scale);
        _localTransfromMatrix = tranformMatrix;
        if (_parentObject) {
            _transformMatrix = GLKMatrix4Multiply(_parentObject.transformMatrix, tranformMatrix);
        } else {
            _transformMatrix = tranformMatrix;
        }
        _hasChanged = NO;
    }
    
    if (_parentObject && _parentObject.hasChanged) {
        _transformMatrix = GLKMatrix4Multiply(_parentObject.transformMatrix, _localTransfromMatrix);
    }
    
    return _transformMatrix;
}


#pragma mark - Child Objects
- (NSSet *)childObjects {
    return _childObjects.copy;
}


- (void)addChildObject:(CEObject *)child {
    if (!_childObjects) {
        _childObjects = [NSMutableSet set];
    }
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


- (void)recursivePrint {
    _parentObject ? printf("-") : printf("\n");
    printf("%s\n", [[self debugDescription] UTF8String]);
    for (CEObject *child in _childObjects) {
        CEObject *obj = child;
        while (obj.parentObject) {
            printf("|");
            obj = obj.parentObject;
        }
        [child recursivePrint];
    }
}


- (NSString *)debugDescription {
    return [self description];
}

@end


