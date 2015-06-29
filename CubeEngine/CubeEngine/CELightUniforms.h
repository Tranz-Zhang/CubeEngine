//
//  CELightUniforms.h
//  CubeEngine
//
//  Created by chance on 6/29/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CELightUniforms : NSObject

@property (nonatomic, assign) GLint lightType_i; // 0:none 1:directional 2:point 3:spot
@property (nonatomic, assign) GLint isEnabled_b;
@property (nonatomic, assign) GLint lightPosition_vec4;
@property (nonatomic, assign) GLint lightDirection_vec3;
@property (nonatomic, assign) GLint lightColor_vec3;
@property (nonatomic, assign) GLint ambientColor_vec3;
@property (nonatomic, assign) GLint specularIntensity_f;
@property (nonatomic, assign) GLint shiniess_f;
@property (nonatomic, assign) GLint attenuation_f;
@property (nonatomic, assign) GLint spotCosCutoff_f;
@property (nonatomic, assign) GLint spotExponent_f;

@end
