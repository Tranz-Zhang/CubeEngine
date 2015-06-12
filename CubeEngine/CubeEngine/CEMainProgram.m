//
//  CEMainProgram.m
//  CubeEngine
//
//  Created by chance on 5/20/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMainProgram.h"
#import "CEShaders.h"

@implementation CEMainProgram {
    GLint _uniIntLightCount;
    BOOL _hasEnabledPosition;
}


+ (instancetype)programWithConfig:(CEProgramConfig *)config {
    NSString *vertexShader = [CEMainProgram vertexShaderWithConfig:config];
    NSString *fragmentShader = [CEMainProgram fragmentShaderWithConfig:config];
    return [[self alloc] initWithVertexShaderString:vertexShader
                               fragmentShaderString:fragmentShader
                                             config:config];
}


- (instancetype)initWithVertexShaderString:(NSString *)vShaderString
                      fragmentShaderString:(NSString *)fShaderString
                                    config:(CEProgramConfig *)config {
    self = [super initWithVertexShaderString:vShaderString
                        fragmentShaderString:fShaderString];
    if (self) {
        _config = [config copy];
        [self setupProgram];
    }
    return self;
}


- (void)setupProgram {
    [self addAttribute:@"VertexPosition"];
    if (_config.lightCount > 0) {
        [self addAttribute:@"VertexNormal"];
    }
    
    BOOL isOK = [self link];
    if (isOK) {
        _attribVec4Position = [self attributeIndex:@"VertexPosition"];
        _uniMtx4MVPMatrix   = [self uniformIndex:@"MVPMatrix"];
        if (_config.lightCount > 0) {
            [self initializeLightUniforms];
            [self use];
            glUniform1i(_uniIntLightCount, _config.lightCount);
        }
        if (_config.enableShadowMapping) {
            [self initializeShadowMapUniforms];
        }
        
    } else {
        // print error info
        NSString *progLog = [self programLog];
        CEError(@"Program link log: %@", progLog);
        NSString *fragLog = [self fragmentShaderLog];
        CEError(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [self vertexShaderLog];
        CEError(@"Vertex shader compile log: %@", vertLog);
        NSAssert(0, @"Fail to Compile Program");
    }
}


#pragma makr - Initialize Uniforms {
- (void)initializeLightUniforms {
    _attribVec3Normal       = [self attributeIndex:@"VertexNormal"];
    _uniMtx3NormalMatrix    = [self uniformIndex:@"NormalMatrix"];
    _uniIntLightCount       = [self uniformIndex:@"LightCount"];
    _uniVec4BaseColor       = [self uniformIndex:@"BaseColor"];
    _uniMtx4MVMatrix        = [self uniformIndex:@"MVMatrix"];
    _uniVec3EyeDirection    = [self uniformIndex:@"EyeDirection"];
    
    NSMutableArray *uniformInfos = [NSMutableArray arrayWithCapacity:_config.lightCount];
    for (int i = 0; i < _config.lightCount; i++) {
        CELightUniformInfo *info = [CELightUniformInfo new];
        info.lightType_i = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightType", i]];
        if (info.lightType_i < 0) continue;
        info.isEnabled_b = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].IsEnabled", i]];
        if (info.isEnabled_b < 0) continue;
        info.lightPosition_vec4 = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightPosition", i]];
        if (info.lightPosition_vec4 < 0) continue;
        info.lightDirection_vec3 = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightDirection", i]];
        if (info.lightDirection_vec3 < 0) continue;
        info.lightColor_vec3 = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightColor", i]];
        if (info.lightColor_vec3 < 0) continue;
        info.ambientColor_vec3 = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].AmbientColor", i]];
        if (info.ambientColor_vec3 < 0) continue;
        info.specularIntensity_f = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpecularIntensity", i]];
        if (info.specularIntensity_f < 0) continue;
        info.shiniess_f = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].Shiniess", i]];
        if (info.shiniess_f < 0) continue;
        info.attenuation_f = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].Attenuation", i]];
        if (info.attenuation_f < 0) continue;
        info.spotCosCutoff_f = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpotConsCutoff", i]];
        if (info.spotCosCutoff_f < 0) continue;
        info.spotExponent_f = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpotExponent", i]];
        if (info.spotExponent_f < 0) continue;
        
        [uniformInfos addObject:info];
    }
    _uniLightInfos = [uniformInfos copy];
}


- (void)initializeShadowMapUniforms {
    _uniMtx4DepthBiasMVP    = [self uniformIndex:@"DepthBiasMVP"];
    _uniTexShadowMapTexture = [self uniformIndex:@"ShadowMapTexture"];
}


#pragma mark - Parse Shaders
+ (NSString *)vertexShaderWithConfig:(CEProgramConfig *)config {
    NSMutableString *vertexShaderString = [kVertexShader mutableCopy];
    if (config.lightCount > 0) {
        [vertexShaderString insertString:@"#define CE_ENABLE_LIGHTING\n" atIndex:0];
    }
    if (config.enableShadowMapping) {
        [vertexShaderString insertString:@"#define CE_ENABLE_SHADOW_MAPPING\n" atIndex:0];
    }
    return [vertexShaderString copy];
}


+ (NSString *)fragmentShaderWithConfig:(CEProgramConfig *)config {
    NSMutableString *fragmentShaderString = [kFragmentSahder mutableCopy];
    if (config.lightCount > 0) {
        [fragmentShaderString insertString:@"#define CE_ENABLE_LIGHTING\n" atIndex:0];
        [fragmentShaderString replaceOccurrencesOfString:@"CE_LIGHT_COUNT"
                                              withString:[NSString stringWithFormat:@"%d", config.lightCount]
                                                 options:0
                                                   range:NSMakeRange(0, fragmentShaderString.length)];
    }
    if (config.enableShadowMapping) {
        [fragmentShaderString insertString:@"#define CE_ENABLE_SHADOW_MAPPING\n" atIndex:0];
    }
    
    return [fragmentShaderString copy];
}


#pragma mark - Attributes & Uniforms
- (BOOL)setupPositionAttribute:(CEVBOAttribute *)attribute {
    if (!_hasEnabledPosition) {
        glEnableVertexAttribArray(_attribVec4Position);
        _hasEnabledPosition = YES;
    }
    ... setup attribute here
}


@end

