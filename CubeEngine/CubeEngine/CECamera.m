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
    GLKQuaternion _rotationQuaternion;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _location = GLKVector3Make(0, 0, 0);
        _rotationQuaternion = GLKQuaternionIdentity;
        _projectionType = CEProjectionPerpective;
    }
    return self;
}

- (void)lookAt:(GLKVector3)targetLocation {
    @synchronized(self) {
        GLKMatrix4 lookAtMatrix = GLKMatrix4MakeLookAt(_location.x, _location.y, _location.z, targetLocation.x, targetLocation.y, targetLocation.z, 0, 1, 0);
        _rotationQuaternion = GLKQuaternionMakeWithMatrix4(lookAtMatrix);
    }
}


- (GLKMatrix4)projectionMatrix {
    @synchronized(self) {
        GLKMatrix4 transformMatrix = GLKMatrix4MakeWithQuaternion(_rotationQuaternion);
        transformMatrix = GLKMatrix4Translate(transformMatrix, -_location.x, -_location.y, -_location.z);
        
        GLKMatrix4 projectionMatrix;
        if (_projectionType == CEProjectionPerpective) {
            projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_radianDegree), _aspect, _nearZ, _farZ);

        } else if (_projectionType == CEProjectionOrthographic) {
            projectionMatrix = GLKMatrix4MakeOrtho(-1, 1, -1 / _aspect, 1 / _aspect, _nearZ, _farZ);
            
        } else {
            CEError(@"Error: Unknown projection type");
            projectionMatrix = GLKMatrix4Identity;
        }
        
        projectionMatrix = GLKMatrix4Multiply(projectionMatrix, transformMatrix);
        return projectionMatrix;
    }
}




@end


