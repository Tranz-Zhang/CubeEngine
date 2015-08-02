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
#import "CELightUniforms.h"


@interface CEMainProgram : CEProgram {
    /*naming rules:
     Attributes: _attrib[name]_[type]_V
     Uniforms:   _uni[name]_[type]_[V|F]
     
     V:used for VertexShader
     F:used for FragmentShader
     */
    
    // basic
    GLint _attribPosition_vec4_V;
    GLint _uni4MVPMatrix_mtx4_V;
    
    // material
    GLint _uniDiffuseColor_vec4_F;
    
    // lighting
    GLint _attribNormal_vec3_V;
    GLint _uniMVMatrix_mtx4_V;
    GLint _uniNormalMatrix_mtx3_V;
    
    CELightUniforms *_mainLight_F;
    GLint _uniEyeDirection_vec3_V;
    GLint _uniSpecularColor_vec3_F;
    GLint _uniAmbientColor_vec3_F;
    GLint _uniShininessExponent_f_F;
    
    // texture
    GLint _attribTextureCoord_vec2_V;
    GLint _uniDiffuseTexture_tex_F;
    
    // normal map
//    GLint _attribTangent_vec3;
//    GLint _uniLightPosition_vec3;
//    GLint _uniNormalMapTexture_tex;
    
    // shadow map
    GLint _uniDepthBiasMVP_mtx4_V;
    GLint _uniShadowDarkness_f_F;
    GLint _uniShadowMap_tex_F;
    
    // transparency
    GLint _uniTransparency_f_F;
}


@property (nonatomic, readonly) CEProgramConfig *config;
@property (nonatomic, readonly) BOOL isEditing;

+ (instancetype)programWithConfig:(CEProgramConfig *)config;

- (void)beginRendering;
- (void)endRendering;


// basic
- (BOOL)setPositionAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setModelViewProjectionMatrix:(GLKMatrix4)mvpMatrix4;
- (BOOL)setDiffuseColor:(GLKVector4)colorVec4;

// lighting
- (BOOL)setMainLightUniforms:(CELightInfo *)lightInfo;
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
//- (BOOL)setTangentAttribute:(CEVBOAttribute *)attribute;
//- (BOOL)setLightPosition:(GLKVector3)lightPosition;
//- (BOOL)setNormalMapTexture:(GLuint)textureId;

// shadow map
- (BOOL)setDepthBiasModelViewProjectionMatrix:(GLKMatrix4)depthBiasMVPMatrix4;
- (BOOL)setShadowDarkness:(GLfloat)shadowDarkness;
- (BOOL)setShadowMapTexture:(GLuint)textureId;

// transparency
- (BOOL)setTransparency:(GLfloat)transparency;



@end





