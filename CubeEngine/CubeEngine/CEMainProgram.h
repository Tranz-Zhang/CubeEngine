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
    GLint _uniMtx4DepthBiasMVP;
    NSArray *_uniShadowMapIndexes;
}

@property (nonatomic, readonly) CEProgramConfig *config;

//// basic
//@property (nonatomic, readonly) GLint attribVec4Position;
//@property (nonatomic, readonly) GLint uniMtx4MVPMatrix;
//@property (nonatomic, readonly) GLint uniVec4BaseColor;
//
//// lighting
//@property (nonatomic, readonly) GLint attribVec3Normal;
//@property (nonatomic, readonly) GLint uniMtx4MVMatrix;
//@property (nonatomic, readonly) GLint uniMtx3NormalMatrix;
//@property (nonatomic, readonly) GLint uniVec3EyeDirection;
@property (nonatomic, readonly) NSArray *uniLightInfos; // return array of CELightUniformInfo

// shadow map
//@property (nonatomic, readonly) GLint uniMtx4DepthBiasMVP;
//@property (nonatomic, readonly) GLint uniTexShadowMapTexture;
@property (nonatomic, readonly) NSArray *uniShadowMapIndexes;


+ (instancetype)programWithConfig:(CEProgramConfig *)config;


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



@end


//multiple shadowmapping: we create a list of shadowmapping, add shadow info in Light Infos
//finish main renderer




