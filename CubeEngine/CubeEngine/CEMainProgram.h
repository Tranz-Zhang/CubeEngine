//
//  CEMainProgram.h
//  CubeEngine
//
//  Created by chance on 5/20/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEProgram.h"
#import "CEProgramConfig.h"
#import "CEVBOAttribute.h"
#import "CELightInfo.h"

@interface CEMainProgram : CEProgram {
    // basic
    GLint _attribPosition_vec4;
    GLint _uni4MVPMatrix_mtx4;
    
    // material
    GLint _uniDiffuseColor_vec4;
    
    // lighting
    GLint _attribNormal_vec3;
    GLint _uniLightCount_i;
    GLint _uniMVMatrix_mtx4;
    GLint _uniNormalMatrix_mtx3;
    GLint _uniEyeDirection_vec3;
    
    GLint _uniSpecularColor_vec3;
    GLint _uniAmbientColor_vec3;
    GLint _uniShininessExponent_f;
    NSArray *_uniLightInfos;
    
    // texture
    GLint _attribTextureCoord_vec2;
    GLint _uniDiffuseTexture_tex;
    
    // normal map
    GLint _attribTangent_vec3;
    GLint _uniLightPosition_vec3;
    GLint _uniNormalMapTexture_tex;
    
    // shadow map
    GLint _uniShadowDarkness_f;
    GLint _uniDepthBiasMVP_mtx4;
    GLint _uniShadowMap_tex;
    
    // transparency
    GLint _uniTransparency_f;
}


@property (nonatomic, readonly) CEProgramConfig *config;
@property (nonatomic, readonly) BOOL isEditing;
@property (nonatomic, readonly) NSArray *uniLightInfos; // return array of CELightUniformInfo

+ (instancetype)programWithConfig:(CEProgramConfig *)config;

- (void)beginRendering;
- (void)endRendering;


// basic
- (BOOL)setPositionAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setModelViewProjectionMatrix:(GLKMatrix4)mvpMatrix4;
- (BOOL)setDiffuseColor:(GLKVector4)colorVec4;

// lighting
- (BOOL)setLightUniformsWithInfo:(CELightInfo *)lightInfos atIndex:(int)index;
- (BOOL)setNormalAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setModelViewMatrix:(GLKMatrix4)mvMatrix4;
- (BOOL)setNormalMatrix:(GLKMatrix3)normalMatrix3;
- (BOOL)setEyeDirection:(GLKVector3)eyeDirectionVec3;

- (BOOL)setSpecularColor:(GLKVector3)specularColor;
- (BOOL)setAmbientColor:(GLKVector3)ambientColor;
- (BOOL)setShininessExponent:(GLfloat)shininessExponent;

// texture
- (BOOL)setTextureCoordinateAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setDiffuseTexture:(GLuint)textureId;

// normal map
- (BOOL)setTangentAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setLightPosition:(GLKVector3)lightPosition;
- (BOOL)setNormalMapTexture:(GLuint)textureId;

// shadow map
- (BOOL)setDepthBiasModelViewProjectionMatrix:(GLKMatrix4)depthBiasMVPMatrix4;
- (BOOL)setShadowDarkness:(GLfloat)shadowDarkness;
- (BOOL)setShadowMapTexture:(GLuint)textureId;

// transparency
- (BOOL)setTransparency:(GLfloat)transparency;



@end

next: single light? vertex lighting calculation;




