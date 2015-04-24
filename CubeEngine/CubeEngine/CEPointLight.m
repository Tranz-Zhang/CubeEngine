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
        _hasChanged = YES;
        _specularItensity = 1.0;
        _shiniess = 20;
        _attenuation = 0.00001;
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
        NSArray *attributes = @[[CEVBOAttribute attributeWithname:CEVBOAttributePosition],
                                [CEVBOAttribute attributeWithname:CEVBOAttributeColor]];
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
        _hasLightChanged = YES;
    }
}

- (void)setSpecularItensity:(GLfloat)specularItensity {
    if (_specularItensity != specularItensity) {
        _specularItensity = specularItensity;
        _hasLightChanged = YES;
    }
}

- (void)setAttenuation:(GLfloat)attenuation {
    if (_attenuation != attenuation) {
        _attenuation = attenuation;
        _hasLightChanged = YES;
    }
}

- (void)updateUniforms {
    if (!_uniformInfo || (!_hasLightChanged && !_hasChanged)) return;
    
    glUniform1i(_uniformInfo.iLightType, CEPointLightType);
    glUniform3f(_uniformInfo.vec3LightColor, _vec3LightColor.r, _vec3LightColor.g, _vec3LightColor.b);
    glUniform3f(_uniformInfo.vec3AmbientColor, _vec3AmbientColor.r, _vec3AmbientColor.g, _vec3AmbientColor.b);
    glUniform3f(_uniformInfo.vec3LightPosition, _position.x, _position.y, _position.z);
    glUniform1f(_uniformInfo.fShiniess, (GLfloat)_shiniess);
    glUniform1f(_uniformInfo.fSpecularIntensity, _specularItensity);
    glUniform1f(_uniformInfo.fAttenuation, _attenuation);
    _hasLightChanged = NO;
    CEPrintf("Update Direational Light Uniform\n");
}

@end
