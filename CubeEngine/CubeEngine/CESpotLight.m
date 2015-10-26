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
    // used for debug rendering
    GLfloat _lastConeAngle;
    GLfloat _vertices[(kCirclePointCount + 8) * 7];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setConeAngle:30];
        [self setupSharedVertexBuffer];
        _lightInfo.lightType = CELightTypeSpot;
        [self setShiniess:20];
        [self setAttenuation:0.001];
        [self setSpotExponent:10];
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
    _lastConeAngle = _coneAngle;
    
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
    NSArray *attributes = @[@(CEVBOAttributePosition), @(CEVBOAttributeColor)];
    CEVertexBuffer *vertexBuffer = [[CEVertexBuffer alloc] initWithData:vertexData attributes:attributes];
    
    static CEIndiceBuffer *sSharedIndicesBuffer = nil;
    if (!sSharedIndicesBuffer) {
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
        sSharedIndicesBuffer = [[CEIndiceBuffer alloc] initWithData:indicesData indiceCount:sizeof(indices) / sizeof(GLubyte) primaryType:GL_UNSIGNED_BYTE drawMode:GL_LINES];
    }
    _renderObject = [[CERenderObject alloc] init];
    _renderObject.vertexBuffer = vertexBuffer;
    _renderObject.indiceBuffer = sSharedIndicesBuffer;
}


- (void)updateVerticesWithConeAngle:(GLfloat)coneAngle {
    GLfloat radius = 0.5 * tanf(GLKMathDegreesToRadians(_coneAngle));
    for (int i = 0; i < kCirclePointCount; i++) {
        GLfloat angle = i * 2 * M_PI / kCirclePointCount;
        _vertices[i * 7 + 1] = sin(angle) * radius;  // Y
        _vertices[i * 7 + 2] = cos(angle) * radius;  // Z
    }
}


- (CERenderObject *)renderObject {
    if (_lastConeAngle != _coneAngle) { // change model data
        [self updateVerticesWithConeAngle:_coneAngle];
        _lastConeAngle = _coneAngle;
        
        NSData *vertexData = [NSData dataWithBytes:&_vertices length:sizeof(_vertices)];
        NSArray *attributes = @[@(CEVBOAttributePosition), @(CEVBOAttributeColor)];
        CEVertexBuffer *vertexBuffer = [[CEVertexBuffer alloc] initWithData:vertexData attributes:attributes];
        _renderObject.vertexBuffer = vertexBuffer;
    }
    return _renderObject;
}


- (void)setAttenuation:(GLfloat)attenuation {
    if (_attenuation != attenuation) {
        _attenuation = attenuation;
        _lightInfo.attenuation = attenuation;
    }
}


- (void)setConeAngle:(GLfloat)coneAngle {
    if (_coneAngle != coneAngle) {
        _coneAngle = coneAngle;
        _lightInfo.spotCosCutOff = cosf(GLKMathDegreesToRadians(coneAngle));
    }
}


- (void)setSpotExponent:(GLfloat)spotExponent {
    if (_spotExponent != spotExponent) {
        _spotExponent = spotExponent;
        _lightInfo.spotExponent = spotExponent;
    }
}

- (GLKVector3)lightDirection {
    return _right;
}


/*
- (CELightInfos *)generateLightInfoWithCamera:(CECamera *)camera {
    if (!_hasLightChanged && !self.hasChanged && !camera.hasChanged) {
        return _lightInfo;
    }
    
    CELightInfos *lightInfo = [CELightInfos new];
    lightInfo.lightType = CELightTypeSpot;
    lightInfo.isEnabled = _enabled;
    lightInfo.lightColor = _lightColorV3;
    lightInfo.ambientColor = _ambientColorV3;
    lightInfo.shiniess = _shiniess;
    lightInfo.attenuation = _attenuation;
    lightInfo.spotCosCutOff = cosf(GLKMathDegreesToRadians(_coneAngle));
    lightInfo.spotExponent = _spotExponent;
    // !!!: transfer light position in view space
    GLKVector4 lightPosition = GLKMatrix4MultiplyVector4([self transformMatrix], GLKVector4Make(0, 0, 0, 1));
    lightPosition = GLKMatrix4MultiplyVector4(camera.viewMatrix, lightPosition);
    lightInfo.lightPosition = lightPosition;
    // !!!: transfer light direction in view space
    GLKVector3 lightDirection = GLKVector3Make(-_right.x, -_right.y, -_right.z);
    lightDirection = GLKMatrix4MultiplyVector3(camera.viewMatrix, lightDirection);
    lightInfo.lightDirection = lightDirection;
    _lightInfo = lightInfo;
    
//    glUniform1i(_uniformInfo.lightType_i, CELightTypeSpot);
//    glUniform1f(_uniformInfo.isEnabled_b, _enabled ? 1.0 : 0.0);
//    glUniform3fv(_uniformInfo.lightColor_vec3, 1, _lightColorV3.v);
//    glUniform3fv(_uniformInfo.ambientColor_vec3, 1, _ambientColorV3.v);
//    glUniform1f(_uniformInfo.shiniess_f, (GLfloat)_shiniess);
//    glUniform1f(_uniformInfo.attenuation_f, _attenuation);
//    GLfloat spotCosCutoff = cosf(GLKMathDegreesToRadians(_coneAngle));
//    glUniform1f(_uniformInfo.spotCosCutoff_f, spotCosCutoff);
//    glUniform1f(_uniformInfo.spotExponent_f, _spotExponent);
//    // !!!: transfer light position in view space
    GLKVector4 lightPosition = GLKMatrix4MultiplyVector4([self transformMatrix], GLKVector4Make(0, 0, 0, 1));
    lightPosition = GLKMatrix4MultiplyVector4(camera.viewMatrix, lightPosition);
//    glUniform4fv(_uniformInfo.lightPosition_vec4, 1, lightPosition.v);
//    // !!!: transfer light direction in view space
    GLKVector3 lightDirection = GLKVector3Make(-_right.x, -_right.y, -_right.z);
    lightDirection = GLKMatrix4MultiplyVector3(camera.viewMatrix, lightDirection);
//    glUniform3fv(_uniformInfo.lightDirection_vec3, 1, lightDirection.v);

    
    _hasLightChanged = NO;
    if (self.hasChanged) {
        [self transformMatrix]; // call to set the hasChanged property to NO
    }
    CEPrintf("Update Spot Light Uniform\n");
    return _lightInfo;
}
//*/


#pragma mark - Shadow Mapping

/*
- (void)updateLightVPMatrixWithModels:(NSSet *)models {
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
    GLfloat positionToCenter = GLKVector3Distance(_position, center);
    _lightProjectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), aspect, MAX(0.1, positionToCenter - radius), positionToCenter + radius);
//    _lightProjectionMatrix = GLKMatrix4MakeOrtho(-radius, radius, -radius / aspect, radius / aspect, 0.1, radius * 2);
    
    GLKVector3 lightDirection;
    if (_parentObject) {
        lightDirection = GLKQuaternionRotateVector3(_parentObject.rotation, _right);
    } else {
        lightDirection = _right;
    }
    GLKVector3 target = GLKVector3Make(_position.x + positionToCenter * lightDirection.x,
                                       _position.y + positionToCenter * lightDirection.y,
                                       _position.z + positionToCenter * lightDirection.z);
    _lightViewMatrix = GLKMatrix4MakeLookAt(_position.x, _position.y , _position.z, target.x, target.y , target.z, 0, 1, 0);
}
//*/


@end



