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

#define kDefaultTextureSize 512

//static NSInteger kMaxLightCount = 8;

@implementation CELight

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setLightColor:[UIColor whiteColor]];
        [self setAmbientColor:[UIColor colorWithWhite:0.1 alpha:1]];
        _enabled = YES;
    }
    return self;
}

+ (NSArray *)defaultVertexBufferAttributes {
    static NSArray *_sDefaultVertexBufferAttributes = nil;
    if (!_sDefaultVertexBufferAttributes) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sDefaultVertexBufferAttributes = @[[CEVBOAttribute attributeWithname:CEVBOAttributePosition],
                                                [CEVBOAttribute attributeWithname:CEVBOAttributeColor]];
        });
    }
    return _sDefaultVertexBufferAttributes;
}


- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        _hasLightChanged = YES;
    }
}

- (void)setUniformInfo:(CELightUniformInfo *)uniformInfo {
    if (_uniformInfo != uniformInfo) {
        _uniformInfo = uniformInfo;
        _hasLightChanged = YES;
    }
}

- (void)setLightColor:(UIColor *)lightColor {
    if (_lightColor != lightColor) {
        _lightColor = [lightColor copy];
        _lightColorV3 = CEVec3WithColor(lightColor);
        _hasLightChanged = YES;
    }
}

- (void)setAmbientColor:(UIColor *)ambientColor {
    if (_ambientColor != ambientColor) {
        _ambientColor = [ambientColor copy];
        _ambientColorV3 = CEVec3WithColor(ambientColor);
        _hasLightChanged = YES;
    }
}

- (void)setPosition:(GLKVector3)position {
    _hasChanged = !GLKVector3AllEqualToVector3(_position, position);
    [super setPosition:position];
}





- (void)updateUniformsWithCamera:(CECamera *)camera {
    // MUST IMPLEMENT BY SUBCLASS
}


#pragma mark - Shadow Mapping

- (void)setEnableShadow:(BOOL)enableShadow {
    if (_enableShadow != enableShadow) {
        _enableShadow = enableShadow;
        if (enableShadow && !_shadowMapBuffer) {
            _shadowMapBuffer = [[CEShadowMapBuffer alloc] initWithTextureSize:CGSizeMake(kDefaultTextureSize, kDefaultTextureSize)];
            
        } else if (!enableShadow && _shadowMapBuffer) {
            _shadowMapBuffer = nil;
        }
    }
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


@end
