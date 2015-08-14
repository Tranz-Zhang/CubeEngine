//
//  CEShaderRoutineDirectionalLight.m
//  CubeEngine
//
//  Created by chance on 8/14/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShaderRoutineDirectionalLight.h"

@implementation CEShaderRoutineDirectionalLight

- (NSString *)vertexShaderVariables {
    return CE_SHADER_STRING
    (
     struct LightInfo {
         bool IsEnabled;
         lowp int LightType; // 0:none 1:directional 2:point 3:spot
         mediump vec4 LightPosition;  // in eye space
         lowp vec3 LightDirection; // in eye space
         mediump vec3 LightColor;
         mediump float Attenuation;
         mediump float SpotConsCutoff;
         mediump float SpotExponent;
     };
     uniform LightInfo MainLight;
     uniform lowp vec3 EyeDirection; // in eye space
    );
}


- (NSString *)vertexShaderImplementation {
    return CE_SHADER_STRING
    (
     LightDirection = MainLight.LightDirection;
     Attenuation = 1.0;
    );
}


@end




