//
//  CEMainProgram.h
//  CubeEngine
//
//  Created by chance on 5/20/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEProgram.h"
#import "CEProgramConfig.h"
#import "CELightUniformInfo.h"
#import "CEVBOAttribute.h"

@interface CEMainProgram : CEProgram {
    // basic
    GLint _attribVec4Position;
    GLint _uniMtx4MVPMatrix;
    GLint _uniVec4BaseColor;
    
    // lighting
    GLint _uniIntLightCount;
    GLint _attribVec3Normal;
    GLint _uniMtx4MVMatrix;
    GLint _uniMtx3NormalMatrix;
    GLint _uniVec3EyeDirection;
    NSArray *_uniLightInfos;
    
    // shadow map
    GLint _uniFloatShadowDarkness;
    GLint _uniMtx4DepthBiasMVP;
    GLint _uniTexShadowMap;
}

@property (nonatomic, readonly) CEProgramConfig *config;
@property (nonatomic, readonly) BOOL isEditing;
@property (nonatomic, readonly) NSArray *uniLightInfos; // return array of CELightUniformInfo

+ (instancetype)programWithConfig:(CEProgramConfig *)config;

- (void)beginEditing;
- (void)endEditing;


// basic
- (BOOL)setPositionAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setModelViewProjectionMatrix:(GLKMatrix4)mvpMatrix4;
- (BOOL)setBaseColor:(GLKVector4)colorVec4;


// lighting
- (BOOL)setNormalAttribute:(CEVBOAttribute *)attribute;
- (BOOL)setModelViewMatrix:(GLKMatrix4)mvMatrix4;
- (BOOL)setNormalMatrix:(GLKMatrix3)normalMatrix3;
- (BOOL)setEyeDirection:(GLKVector3)eyeDirectionVec3;


// shadow map
- (BOOL)setDepthBiasModelViewProjectionMatrix:(GLKMatrix4)depthBiasMVPMatrix4;
- (BOOL)setShadowDarkness:(GLfloat)shadowDarkness;
- (BOOL)setShadowMapTexture:(GLuint)shadowMapTextureId;

@end





