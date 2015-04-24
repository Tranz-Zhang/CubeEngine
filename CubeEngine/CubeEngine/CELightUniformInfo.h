//
//  CELightUniformInfo.h
//  CubeEngine
//
//  Created by chance on 4/23/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CERenderer.h"

typedef NS_ENUM(NSInteger, CELightType) {
    CEDirectionalLightType = 1,
    CEPointLightType,
    CESpotLightType,
};

// Save the uniform index of LightInfo struct in the program
@interface CELightUniformInfo : CERenderer

@property (nonatomic, assign) GLint iLightType; // 0:none 1:directional 2:point 3:spot
@property (nonatomic, assign) GLint vec3LightPosition;
@property (nonatomic, assign) GLint vec3LightDirection;
@property (nonatomic, assign) GLint vec3LightColor;
@property (nonatomic, assign) GLint vec3AmbientColor;
@property (nonatomic, assign) GLint fSpecularIntensity;
@property (nonatomic, assign) GLint fShiniess;
@property (nonatomic, assign) GLint fAttenuation;

@end
