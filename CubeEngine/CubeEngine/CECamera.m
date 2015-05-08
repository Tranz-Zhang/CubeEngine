//
//  CECamera.m
//  CubeEngine
//
//  Created by chance on 15/3/9.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import "CECamera.h"
#import "CECamera_Rendering.h"

@implementation CECamera {
    GLKMatrix4 _projectionMatrix;
    BOOL _perspectiveChanged;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _projectionType = CEProjectionPerpective;
        _radianDegree = 65;
        _orthoBoxWidth = 10;
        _nearZ = 0.1;
        _farZ = 100;
        _perspectiveChanged = YES;
    }
    return self;
}

#pragma mark - Setter & Getters 
- (void)setProjectionType:(CEProjectionType)projectionType {
    if (_projectionType != projectionType) {
        _projectionType = projectionType;
        _perspectiveChanged = YES;
    }
}

- (void)setRadianDegree:(float)radianDegree {
    if (_radianDegree != radianDegree) {
        _radianDegree = radianDegree;
        _perspectiveChanged = YES;
    }
}

- (void)setOrthoBoxWidth:(float)orthoBoxWidth {
    if (!_orthoBoxWidth != orthoBoxWidth) {
        _orthoBoxWidth = orthoBoxWidth;
        _perspectiveChanged = YES;
    }
}

- (void)setAspect:(float)aspect {
    if (_aspect != aspect) {
        _aspect = aspect;
        _perspectiveChanged = YES;
    }
}

- (void)setNearZ:(float)nearZ {
    if (_nearZ != nearZ) {
        _nearZ = nearZ;
        _perspectiveChanged = YES;
    }
}

- (void)setFarZ:(float)farZ {
    if (_farZ != farZ) {
        _farZ = farZ;
        _perspectiveChanged = YES;
    }
}

#pragma mark - Rotation

- (void)lookAt:(GLKVector3)targetPosition {
    GLKMatrix4 lookAtMatrix = GLKMatrix4MakeLookAt(self.position.x, self.position.y, self.position.z, targetPosition.x, targetPosition.y, targetPosition.z, 0, 1, 0);
    lookAtMatrix = GLKMatrix4Invert(lookAtMatrix, NULL);
    GLKQuaternion lookAtQuaternion = GLKQuaternionMakeWithMatrix4(lookAtMatrix);
    self.rotation = lookAtQuaternion;
}


// !!!: Overwrite transformMatrix
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
            _transformMatrix = GLKMatrix4Invert(GLKMatrix4Multiply(_parentObject.transformMatrix, tranformMatrix), NULL);
        } else {
            _transformMatrix = GLKMatrix4Invert(tranformMatrix, NULL);
        }
        _hasChanged = NO;
    }
    
    if (_parentObject && _parentObject.hasChanged) {
        _transformMatrix = GLKMatrix4Invert(GLKMatrix4Multiply(_parentObject.transformMatrix, _localTransfromMatrix), NULL);
    }
    
    return _transformMatrix;
}


- (GLKMatrix4)projectionMatrix {
    if (!_perspectiveChanged) {
        return _projectionMatrix;
    }
    
    if (_perspectiveChanged) {
        if (_projectionType == CEProjectionPerpective) {
            _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_radianDegree), _aspect, _nearZ, _farZ);
            
        } else if (_projectionType == CEProjectionOrthographic) {
            _projectionMatrix = GLKMatrix4MakeOrtho(-_orthoBoxWidth, _orthoBoxWidth, -_orthoBoxWidth / _aspect, _orthoBoxWidth / _aspect, _nearZ, _farZ);
            
        } else {
            CEError(@"Error: Unknown projection type");
            _projectionMatrix = GLKMatrix4Identity;
        }
        _perspectiveChanged = NO;
    }
    
    return _projectionMatrix;
}

- (GLKMatrix4)viewMatrix {
    return [self transformMatrix];
}


@end


