//
//  CEDirectionalLight.m
//  CubeEngine
//
//  Created by chance on 4/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEDirectionalLight.h"
#import "CELight_Rendering.h"

@implementation CEDirectionalLight

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSharedVertexBuffer];
        _hasChanged = YES;
        _shiniess = 20;
    }
    return self;
}

- (void)setupSharedVertexBuffer {
    static CEVertexBuffer *_sharedVertexBuffer;
    static CEIndicesBuffer *_sharedIndicesBuffer;
    if (!_sharedVertexBuffer) {
        GLfloat red = 200.0 / 255.0, green = 150.0 / 255.0, blue = 0.0, alpha = 1.0;
        GLfloat vertices[] = {
            -0.5, 0.0, 0.0, red, green, blue, alpha,
            0.25, 0.0, 0.0, red, green, blue, alpha,
            0.5, 0.0, 0.0, red, green, blue, alpha,
            0.25, 0.0, 0.05, red, green, blue, alpha,
            0.25, 0.0, -0.05, red, green, blue, alpha,
            0.25, 0.05, 0.0, red, green, blue, alpha,
            0.25, -0.05, 0.0, red, green, blue, alpha,
            -0.1, -0.1, -0.1, 1.0, 0.0, 0.0, 1.0,
            0.1, -0.1, -0.1, 1.0, 0.0, 0.0, 1.0,
            -0.1, -0.1, -0.1, 0.0, 1.0, 0.0, 1.0,
            -0.1, 0.1, -0.1, 0.0, 1.0, 0.0, 1.0,
            -0.1, -0.1, -0.1, 0.0, 0.0, 1.0, 1.0,
            -0.1, -0.1, 0.1, 0.0, 0.0, 1.0, 1.0,
        };
        NSData *vertexData = [NSData dataWithBytes:&vertices length:sizeof(vertices)];
        NSArray *attributes = [CELight defaultVertexBufferAttributes];
        _sharedVertexBuffer = [[CEVertexBuffer alloc] initWithData:vertexData attributes:attributes];
    }
    
    if (!_sharedIndicesBuffer) {
        GLubyte indices[] = {
            0, 1, 2, 3, 2, 4, 2, 5, 2, 6, 3, 5, 3, 6, 4, 5, 4, 6,// ARROW
            7, 8, 9, 10, 11, 12 // DIRECTION
        };
        NSData *indicesData = [NSData dataWithBytes:&indices length:sizeof(indices)];
        _sharedIndicesBuffer = [[CEIndicesBuffer alloc] initWithData:indicesData indicesCount:sizeof(indices)];
    }
    
    _vertexBuffer = _sharedVertexBuffer;
    _indicesBuffer = _sharedIndicesBuffer;
}

- (GLKVector3)lightDirection {
    return _right;
}


//- (void)setLightDirection:(GLKVector3)lightDirection {
//    if (!GLKVector3AllEqualToVector3(_lightDirection, lightDirection)) {
//        _lightDirection = lightDirection;
//        _hasLightChanged = YES;
//    }
//}

- (void)setShiniess:(GLint)shiniess {
    if (_shiniess != shiniess) {
        _shiniess = shiniess;
        _hasLightChanged = YES;
    }
}


- (void)updateUniformsWithCamera:(CECamera *)camera {
    if (!_uniformInfo || (!_hasLightChanged && !self.hasChanged && !camera.hasChanged)) return;
    
    glUniform1i(_uniformInfo.lightType_i, CEDirectionalLightType);
    glUniform1f(_uniformInfo.isEnabled_b, _enabled ? 1.0 : 0.0);
    glUniform3fv(_uniformInfo.lightColor_vec3, 1, _lightColorV3.v);
    glUniform3fv(_uniformInfo.ambientColor_vec3, 1, _ambientColorV3.v);
    glUniform1f(_uniformInfo.shiniess_f, (GLfloat)_shiniess);
    
    // !!!: transfer light direction in view space
    GLKVector3 lightDirection = GLKVector3Make(-_right.x, -_right.y, -_right.z);
    lightDirection = GLKMatrix4MultiplyVector3(camera.viewMatrix, lightDirection);
    glUniform3fv(_uniformInfo.lightDirection_vec3, 1, lightDirection.v);
    
    _hasLightChanged = NO;
    CEPrintf("Update Direational Light Uniform\n");
}




@end


