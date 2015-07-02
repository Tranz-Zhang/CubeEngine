//
//  CELight.m
//  CubeEngine
//
//  Created by chance on 4/21/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CELight.h"
#import "CEUtils.h"
#import "CELight_Rendering.h"

//static NSInteger kMaxLightCount = 8;

@implementation CELight

- (instancetype)init {
    self = [super init];
    if (self) {
        _lightInfo = [CELightInfo new];
        [self setLightColor:[UIColor whiteColor]];
        [self setEnabled:YES];
    }
    return self;
}

+ (NSArray *)defaultVertexBufferAttributes {
    static NSArray *_sDefaultVertexBufferAttributes = nil;
    if (!_sDefaultVertexBufferAttributes) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sDefaultVertexBufferAttributes = [CEVBOAttribute attributesWithNames:@[@(CEVBOAttributePosition), @(CEVBOAttributeColor)]];
        });
    }
    return _sDefaultVertexBufferAttributes;
}


- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        _lightInfo.isEnabled = enabled;
    }
}

- (void)setLightColor:(UIColor *)lightColor {
    if (_lightColor != lightColor) {
        _lightColor = [lightColor copy];
        _lightColorV3 = CEVec3WithColor(lightColor);
        _lightInfo.lightColor = _lightColorV3;
    }
}

/*
//- (void)setPosition:(GLKVector3)position {
//    _hasChanged = !GLKVector3AllEqualToVector3(_position, position);
//    [super setPosition:position];
//}





- (void)updateUniformsWithCamera:(CECamera *)camera {
    // MUST IMPLEMENT BY SUBCLASS
}


//- (GLKMatrix4)lightViewMatrix {
//    if (!self.hasChanged) {
//        return _lightViewMatrix;
//    }
//    
//    GLKMatrix4 tranformMatrix;
//    if (_hasChanged) {
//        // update local transfrom matrix
//        tranformMatrix = GLKMatrix4MakeTranslation(_position.x, _position.y, _position.z);
//        tranformMatrix = GLKMatrix4Multiply(tranformMatrix, GLKMatrix4MakeWithQuaternion(GLKQuaternionInvert(_rotation)));
//        tranformMatrix = GLKMatrix4ScaleWithVector3(tranformMatrix, GLKVector3Make(1, -1, 1));
//        if (_parentObject) {
//            _lightViewMatrix = GLKMatrix4Invert(GLKMatrix4Multiply(_parentObject.transformMatrix, tranformMatrix), NULL);
//        } else {
//            _lightViewMatrix = GLKMatrix4Invert(tranformMatrix, NULL);
//        }
//    }
//    
//    if (_parentObject && _parentObject.hasChanged) {
//        _lightViewMatrix = GLKMatrix4Invert(GLKMatrix4Multiply(_parentObject.transformMatrix, tranformMatrix), NULL);
//    }
//    
//    return _lightViewMatrix;
//}


- (void)updateLightVPMatrixWithModels:(NSSet *)models {
    // should be overwited by subclass
}
//*/

@end
