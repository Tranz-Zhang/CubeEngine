//
//  CEPointLight.m
//  CubeEngine
//
//  Created by chance on 4/24/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEPointLight.h"
#import "CELight_Rendering.h"

@implementation CEPointLight

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSharedVertexBuffer];
        _lightInfo.lightType = CELightTypePoint;
        [self setShiniess:20];
        [self setAttenuation:0.001];
    }
    return self;
}

- (void)setupSharedVertexBuffer {
    static CEVertexBuffer *_sharedVertexBuffer;
    static CEIndicesBuffer *_sharedIndicesBuffer;
    if (!_sharedVertexBuffer) {
        GLfloat red = 200.0 / 255.0, green = 150.0 / 255.0, blue = 0.0, alpha = 1.0;
        GLfloat vertices[] = {
            0.1, 0.0, 0.1, red, green, blue, alpha,
            -0.1, 0.0, 0.1, red, green, blue, alpha,
            0.1, 0.0, -0.1, red, green, blue, alpha,
            -0.1, 0.0, -0.1, red, green, blue, alpha,
            0.0, 0.2, 0.0, red, green, blue, alpha,
            0.0, -0.2, 0.0, red, green, blue, alpha,
            -0.15, -0.15, -0.15, 1.0, 0.0, 0.0, 1.0,
            0.15, -0.15, -0.15, 1.0, 0.0, 0.0, 1.0,
            -0.15, -0.15, -0.15, 0.0, 1.0, 0.0, 1.0,
            -0.15, 0.15, -0.15, 0.0, 1.0, 0.0, 1.0,
            -0.15, -0.15, -0.15, 0.0, 0.0, 1.0, 1.0,
            -0.15, -0.15, 0.15, 0.0, 0.0, 1.0, 1.0,
        };
        NSData *vertexData = [NSData dataWithBytes:&vertices length:sizeof(vertices)];
        NSArray *attributes = [CELight defaultVertexBufferAttributes];
        _sharedVertexBuffer = [[CEVertexBuffer alloc] initWithData:vertexData attributes:attributes];
    }
    
    if (!_sharedIndicesBuffer) {
        GLubyte indices[] = {
            0, 1, 0, 2, 3, 1, 3, 2,
            4, 0, 4, 1, 4, 2, 4, 3,
            5, 0, 5, 1, 5, 2, 5, 3,
            6, 7, 8, 9, 10, 11
        };
        NSData *indicesData = [NSData dataWithBytes:&indices length:sizeof(indices)];
        _sharedIndicesBuffer = [[CEIndicesBuffer alloc] initWithData:indicesData indicesCount:sizeof(indices)];
    }
    
    _vertexBuffer = _sharedVertexBuffer;
    _indicesBuffer = _sharedIndicesBuffer;
}

- (void)setShiniess:(GLint)shiniess {
    if (_shiniess != shiniess) {
        _shiniess = shiniess;
        _lightInfo.shiniess = shiniess;
    }
}

- (void)setAttenuation:(GLfloat)attenuation {
    if (_attenuation != attenuation) {
        _attenuation = attenuation;
        _lightInfo.attenuation = attenuation;
    }
}

- (void)setEnableShadow:(BOOL)enableShadow {
    CEWarning(@"Spot light shadow is disabled right now");
}


/*
- (CELightInfos *)generateLightInfoWithCamera:(CECamera *)camera {
    if (!_hasLightChanged && !self.hasChanged && !camera.hasChanged) {
        return _lightInfo;
    }
    
    CELightInfos *lightInfo = [CELightInfos new];
    lightInfo.lightType = CELightTypePoint;
    lightInfo.isEnabled = _enabled;
    lightInfo.lightColor = _lightColorV3;
    lightInfo.ambientColor = _ambientColorV3;
    lightInfo.shiniess = _shiniess;
    lightInfo.attenuation = _attenuation;
    // !!!: transfer light position in view space
    GLKVector4 lightPosition = GLKMatrix4MultiplyVector4([self transformMatrix], GLKVector4Make(0, 0, 0, 1));
    lightPosition = GLKMatrix4MultiplyVector4(camera.viewMatrix, lightPosition);
    lightInfo.lightPosition = lightPosition;
    _lightInfo = lightInfo;
    
//    glUniform1i(_uniformInfo.lightType_i, CELightTypePoint);
//    glUniform1f(_uniformInfo.isEnabled_b, _enabled ? 1.0 : 0.0);
//    glUniform3fv(_uniformInfo.lightColor_vec3, 1, _lightColorV3.v);
//    glUniform3fv(_uniformInfo.ambientColor_vec3, 1, _ambientColorV3.v);
//    glUniform1f(_uniformInfo.shiniess_f, (GLfloat)_shiniess);
//    glUniform1f(_uniformInfo.attenuation_f, _attenuation);
//    
//    // !!!: transfer light position in view space
//    GLKVector4 lightPosition = GLKMatrix4MultiplyVector4([self transformMatrix], GLKVector4Make(0, 0, 0, 1));
//    lightPosition = GLKMatrix4MultiplyVector4(camera.viewMatrix, lightPosition);
//    glUniform4fv(_uniformInfo.lightPosition_vec4, 1, lightPosition.v);
    
    _hasLightChanged = NO;
    if (self.hasChanged) {
        [self transformMatrix]; // call to set the hasChanged property to NO
    }
    CEPrintf("Update Point Light Uniform\n");
    return _lightInfo;
}
//*/


#pragma mark - Shadow Mapping
/*
- (void)updateLightVPMatrixWithModels:(NSSet *)models {
    
}
//*/


@end



