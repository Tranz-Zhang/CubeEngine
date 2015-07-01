//
//  CEDirectionalLight.m
//  CubeEngine
//
//  Created by chance on 4/22/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEDirectionalLight.h"
#import "CELight_Rendering.h"
#import "CEShadowLight_Rendering.h"

@implementation CEDirectionalLight

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSharedVertexBuffer];
        _lightInfo.lightType = CELightTypeDirectional;
        [self setShiniess:20];
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


- (void)setShiniess:(GLint)shiniess {
    if (_shiniess != shiniess) {
        _shiniess = shiniess;
        _lightInfo.shiniess = shiniess;
    }
}

/*
- (CELightInfos *)generateLightInfoWithCamera:(CECamera *)camera {
    if (!_hasLightChanged && !self.hasChanged && !camera.hasChanged) {
        return _lightInfo;
    }
    
    CELightInfos *lightInfo = [CELightInfos new];
    lightInfo.lightType = CELightTypeDirectional;
    lightInfo.isEnabled = _enabled;
    lightInfo.lightColor = _lightColorV3;
    lightInfo.ambientColor = _ambientColorV3;
    lightInfo.shiniess = _shiniess;
    // !!!: transfer light position in view space
    GLKVector3 lightDirection = GLKVector3Make(-_right.x, -_right.y, -_right.z);
    lightDirection = GLKMatrix4MultiplyVector3(camera.viewMatrix, lightDirection);
    lightInfo.lightDirection = lightDirection;
    _lightInfo = lightInfo;
    
//    glUniform1i(_uniformInfo.lightType_i, CELightTypeDirectional);
//    glUniform1f(_uniformInfo.isEnabled_b, _enabled ? 1.0 : 0.0);
//    glUniform3fv(_uniformInfo.lightColor_vec3, 1, _lightColorV3.v);
//    glUniform3fv(_uniformInfo.ambientColor_vec3, 1, _ambientColorV3.v);
//    glUniform1f(_uniformInfo.shiniess_f, (GLfloat)_shiniess);
//    
//    // !!!: transfer light direction in view space
//    GLKVector3 lightDirection = GLKVector3Make(-_right.x, -_right.y, -_right.z);
//    lightDirection = GLKMatrix4MultiplyVector3(camera.viewMatrix, lightDirection);
//    glUniform3fv(_uniformInfo.lightDirection_vec3, 1, lightDirection.v);
    
    _hasLightChanged = NO;
    if (self.hasChanged) {
        [self transformMatrix]; // call to set the hasChanged property to NO
    }
    CEPrintf("Update Direational Light Uniform\n");
    return _lightInfo;
}
//*/

#pragma mark - Shadow Mapping
- (void)updateLightVPMatrixWithModels:(NSArray *)models {
    if (!models.count) return;
    
    // update light projection matrix
    GLfloat maxX = 0, maxY = 0, maxZ = 0, minX = MAXFLOAT, minY = MAXFLOAT, minZ = MAXFLOAT;
    for (CEModel *model in models) {
        GLfloat modelMaxX = model.position.x + model.offsetFromOrigin.x + model.bounds.x / 2;
        GLfloat modelMaxY = model.position.y + model.offsetFromOrigin.y + model.bounds.y / 2;
        GLfloat modelMaxZ = model.position.z + model.offsetFromOrigin.z + model.bounds.z / 2;
        GLfloat modelMinX = model.position.x + model.offsetFromOrigin.x - model.bounds.x / 2;
        GLfloat modelMinY = model.position.y + model.offsetFromOrigin.y - model.bounds.y / 2;
        GLfloat modelMinZ = model.position.z + model.offsetFromOrigin.z - model.bounds.z / 2;
        if (maxX < modelMaxX) maxX = modelMaxX;
        if (maxY < modelMaxY) maxY = modelMaxY;
        if (maxZ < modelMaxZ) maxZ = modelMaxZ;
        if (minX > modelMinX) minX = modelMinX;
        if (minY > modelMinY) minY = modelMinY;
        if (minZ > modelMinZ) minZ = modelMinZ;
    }
    GLKVector3 center = GLKVector3Make((maxX + minX) / 2, (maxY + minY) / 2, (maxZ + minZ) / 2);
    GLfloat radius = GLKVector3Distance(center, GLKVector3Make(maxX, maxY, maxZ));
    GLfloat aspect = self.shadowMapBuffer.textureSize.width / self.shadowMapBuffer.textureSize.height;
    _lightProjectionMatrix = GLKMatrix4MakeOrtho(-radius, radius, -radius / aspect, radius / aspect, 0.1, radius * 2);
    
    GLKVector3 lightDirection;
    if (_parentObject) {
        lightDirection = GLKQuaternionRotateVector3(_parentObject.rotation, _right);
    } else {
        lightDirection = _right;
    }
    GLKVector3 position = GLKVector3Make(center.x - radius * lightDirection.x,
                                         center.y - radius * lightDirection.y,
                                         center.z - radius * lightDirection.z);
    _lightViewMatrix = GLKMatrix4MakeLookAt(position.x, position.y , position.z, center.x, center.y , center.z, 0, 1, 0);
}




@end


