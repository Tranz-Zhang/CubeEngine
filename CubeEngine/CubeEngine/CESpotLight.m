//
//  CESpotLight.m
//  CubeEngine
//
//  Created by chance on 4/27/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CESpotLight.h"
#import "CELight_Rendering.h"

#define kCirclePointCount 16
@implementation CESpotLight {
    GLfloat _coneAngleCosine;
    GLfloat _vertices[(kCirclePointCount + 8) * 7];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setConeAngle:30];
        [self setupSharedVertexBuffer];
        _hasChanged = YES;
        _shiniess = 20;
        _attenuation = 0.001;
        _spotExponent = 10;
    }
    return self;
}


// We share the indicesBuffer, but not the vertexBuffer, because it may change accroding to the coneAngle.
- (void)setupSharedVertexBuffer {
    GLfloat red = 200.0 / 255.0, green = 150.0 / 255.0, blue = 0.0, alpha = 1.0;
    // create circle points
    for (int i = 0; i < kCirclePointCount; i++) {
        _vertices[i * 7] = 0.5;          // X
        _vertices[i * 7 + 1] = 0;        // Y, calculated later.
        _vertices[i * 7 + 2] = 0;        // Z, calculated later.
        _vertices[i * 7 + 3] = red;      // red
        _vertices[i * 7 + 4] = green;    // green
        _vertices[i * 7 + 5] = blue;     // blue
        _vertices[i * 7 + 6] = alpha;    // angle
    }
    [self updateVerticesWithConeAngle:_coneAngle];
    
    // add other points
    GLfloat otherVertices[8 * 7] = {
        0.0, 0.0, 0.0, red - 0.2, green - 0.2, blue - 0.2, alpha,
        0.75, 0.0, 0.0, red, green, blue, alpha,
        0.0, -0.15, -0.15, 1.0, 0.0, 0.0, 1.0,
        0.3, -0.15, -0.15, 1.0, 0.0, 0.0, 1.0,
        0.0, -0.15, -0.15, 0.0, 1.0, 0.0, 1.0,
        0.0, 0.15, -0.15, 0.0, 1.0, 0.0, 1.0,
        0.0, -0.15, -0.15, 0.0, 0.0, 1.0, 1.0,
        0.0, -0.15, 0.15, 0.0, 0.0, 1.0, 1.0,
    };
    int otherVerticesCount = sizeof(otherVertices) / sizeof(GLfloat);
    for (int i = 0; i < otherVerticesCount; i++) {
        _vertices[i + kCirclePointCount * 7] = otherVertices[i];
    }
    
    NSData *vertexData = [NSData dataWithBytes:&_vertices length:sizeof(_vertices)];
    NSArray *attributes = [CELight defaultVertexBufferAttributes];
    _vertexBuffer = [[CEVertexBuffer alloc] initWithData:vertexData attributes:attributes];
    
    static CEIndicesBuffer *_sharedIndicesBuffer;
    if (!_sharedIndicesBuffer) {
        int indexCount = 0;
        GLubyte indices[kCirclePointCount * 2 + 16] = {0};
        for (int i = 0; i < kCirclePointCount; i++) {
            indices[indexCount] = i;
            indices[indexCount + 1] = (i + 1) % kCirclePointCount;
             indexCount += 2;
            if (i % (kCirclePointCount / 4) == 0) {
                indices[indexCount] = i;
                indices[indexCount + 1] = kCirclePointCount;
                indexCount += 2;
            }
        }
        for (int i = 0; i < 8; i++) {
            indices[indexCount] = kCirclePointCount + i;
            indexCount++;
        }
        NSData *indicesData = [NSData dataWithBytes:&indices length:sizeof(indices)];
        _sharedIndicesBuffer = [[CEIndicesBuffer alloc] initWithData:indicesData indicesCount:sizeof(indices)];
    }
    _indicesBuffer = _sharedIndicesBuffer;
}

- (void)updateVerticesWithConeAngle:(GLfloat)coneAngle {
    GLfloat radius = 0.5 * tanf(GLKMathDegreesToRadians(_coneAngle));
    for (int i = 0; i < kCirclePointCount; i++) {
        GLfloat angle = i * 2 * M_PI / kCirclePointCount;
        _vertices[i * 7 + 1] = sin(angle) * radius;  // Y
        _vertices[i * 7 + 2] = cos(angle) * radius;  // Z
    }
}


- (void)setShiniess:(GLint)shiniess {
    if (_shiniess != shiniess) {
        _shiniess = shiniess;
        _hasLightChanged = YES;
    }
}


- (void)setAttenuation:(GLfloat)attenuation {
    if (_attenuation != attenuation) {
        _attenuation = attenuation;
        _hasLightChanged = YES;
    }
}


- (void)setConeAngle:(GLfloat)coneAngle {
    if (_coneAngle != coneAngle) {
        _coneAngle = coneAngle;
        // change model data
        [self updateVerticesWithConeAngle:coneAngle];
        NSData *vertexData = [NSData dataWithBytes:&_vertices length:sizeof(_vertices)];
        NSArray *attributes = [CELight defaultVertexBufferAttributes];
        [_vertexBuffer updateVertexData:vertexData attributes:attributes];
        _hasLightChanged = YES;
    }
}


- (void)setSpotExponent:(GLfloat)spotExponent {
    if (_spotExponent != spotExponent) {
        _spotExponent = spotExponent;
        _hasLightChanged = YES;
    }
}


- (void)updateUniformsWithCamera:(CECamera *)camera {
    if (!_uniformInfo || (!_hasLightChanged && !self.hasChanged && !camera.hasChanged)) return;
    
    glUniform1i(_uniformInfo.lightType_i, CESpotLightType);
    glUniform1f(_uniformInfo.isEnabled_b, _enabled ? 1.0 : 0.0);
    glUniform3fv(_uniformInfo.lightColor_vec3, 1, _lightColorV3.v);
    glUniform3fv(_uniformInfo.ambientColor_vec3, 1, _ambientColorV3.v);
    glUniform1f(_uniformInfo.shiniess_f, (GLfloat)_shiniess);
    glUniform1f(_uniformInfo.attenuation_f, _attenuation);
    GLfloat spotCosCutoff = cosf(GLKMathDegreesToRadians(_coneAngle));
    glUniform1f(_uniformInfo.spotCosCutoff_f, spotCosCutoff);
    glUniform1f(_uniformInfo.spotExponent_f, _spotExponent);
    
    // !!!: transfer light position in view space
    GLKVector4 lightPosition = GLKMatrix4MultiplyVector4([self transformMatrix], GLKVector4Make(0, 0, 0, 1));
    lightPosition = GLKMatrix4MultiplyVector4(camera.viewMatrix, lightPosition);
    glUniform4fv(_uniformInfo.lightPosition_vec4, 1, lightPosition.v);
    // !!!: transfer light direction in view space
    GLKVector3 lightDirection = GLKVector3Make(-_right.x, -_right.y, -_right.z);
    lightDirection = GLKMatrix4MultiplyVector3(camera.viewMatrix, lightDirection);
    glUniform3fv(_uniformInfo.lightDirection_vec3, 1, lightDirection.v);
    
    _hasLightChanged = NO;
    if (self.hasChanged) {
        [self transformMatrix]; // call to set the hasChanged property to NO
    }
//    CEPrintf("Update Spot Light Uniform\n");
}


#pragma mark - Shadow Mapping
- (void)updateLightVPMatrixWithModels:(NSSet *)models {
    
}



@end



