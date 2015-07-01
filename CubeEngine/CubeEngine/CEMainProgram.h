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
    GLint _uniBaseColor_vec4;
    
    // lighting
    GLint _attribNormal_vec3;
    GLint _uniLightCount_i;
    GLint _uniMVMatrix_mtx4;
    GLint _uniNormalMatrix_mtx3;
    GLint _uniEyeDirection_vec3;
    NSArray *_uniLightInfos;
    
    // texture
    GLint _attriTextureCoord_vec2;
    GLint _uniDiffuseTexture_tex;
    
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
- (BOOL)setBaseColor:(GLKVector4)colorVec4;

// lighting
- (BOOL)setLightUniformsWithInfo:(CELightInfo *)lightInfos atIndex:(int)index;
- (BOOL)setNormalAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setModelViewMatrix:(GLKMatrix4)mvMatrix4;
- (BOOL)setNormalMatrix:(GLKMatrix3)normalMatrix3;
- (BOOL)setEyeDirection:(GLKVector3)eyeDirectionVec3;

// texture
- (BOOL)setTextureCoordinateAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setDiffuseTexture:(GLuint)textureId;

// shadow map
- (BOOL)setDepthBiasModelViewProjectionMatrix:(GLKMatrix4)depthBiasMVPMatrix4;
- (BOOL)setShadowDarkness:(GLfloat)shadowDarkness;
- (BOOL)setShadowMapTexture:(GLuint)textureId;

// transparency
- (BOOL)setTransparency:(GLfloat)transparency;

@end






