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

@interface CEMainProgram : CEProgram

@property (nonatomic, readonly) CEProgramConfig *config;

// basic
@property (nonatomic, readonly) GLint attribVec4Position;
@property (nonatomic, readonly) GLint uniMtx4MVPMatrix;
@property (nonatomic, readonly) GLint uniVec4BaseColor;

// lighting
@property (nonatomic, readonly) GLint attribVec3Normal;
@property (nonatomic, readonly) GLint uniMtx4MVMatrix;
@property (nonatomic, readonly) GLint uniMtx3NormalMatrix;
@property (nonatomic, readonly) GLint uniVec3EyeDirection;
@property (nonatomic, readonly) NSArray *uniLightInfos; // return array of CELightUniformInfo

// shadow map
@property (nonatomic, readonly) GLint uniMtx4DepthBiasMVP;
@property (nonatomic, readonly) GLint uniTexShadowMapTexture;


+ (instancetype)programWithConfig:(CEProgramConfig *)config;


@end

multiple shadowmapping
finish main renderer
