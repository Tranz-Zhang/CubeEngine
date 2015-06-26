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
    BOOL _hasEnabledPosition;
    BOOL _hasEnableTexture;
    BOOL _hasEnabledNormal;
    
    int _textureCount;
}


+ (instancetype)programWithConfig:(CEProgramConfig *)config {
    NSString *vertexShader = [CEMainProgram vertexShaderWithConfig:config];
    NSString *fragmentShader = [CEMainProgram fragmentShaderWithConfig:config];
    return [[self alloc] initWithVertexShaderString:vertexShader
                               fragmentShaderString:fragmentShader
                                             config:config];
}


#pragma mark - Parse Shaders
+ (NSString *)vertexShaderWithConfig:(CEProgramConfig *)config {
    NSMutableString *vertexShaderString = [kVertexShader mutableCopy];
    if (config.lightCount > 0) {
        [vertexShaderString insertString:@"#define CE_ENABLE_LIGHTING\n" atIndex:0];
    }
    if (config.enableShadowMapping > 0) {
        [vertexShaderString insertString:@"#define CE_ENABLE_SHADOW_MAPPING\n" atIndex:0];
    }
    if (config.enableTexture) {
        [vertexShaderString insertString:@"#define CE_ENABLE_TEXTURE\n" atIndex:0];
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
    if (config.enableTexture) {
        [fragmentShaderString insertString:@"#define CE_ENABLE_TEXTURE\n" atIndex:0];
    }
    return [fragmentShaderString copy];
}




- (instancetype)initWithVertexShaderString:(NSString *)vShaderString
                      fragmentShaderString:(NSString *)fShaderString
                                    config:(CEProgramConfig *)config {
    self = [super initWithVertexShaderString:vShaderString
                        fragmentShaderString:fShaderString];
    if (self) {
        _config = [config copy];
        _attribVec4Position = -1;
        _uniMtx4MVPMatrix = -1;
        _uniVec4BaseColor = -1;
        
        // lighting
        _uniIntLightCount = -1;
        _attribVec3Normal = -1;
        _uniMtx4MVMatrix = -1;
        _uniMtx3NormalMatrix = -1;
        _uniVec3EyeDirection = -1;
        
        // shadow map
        _uniMtx4DepthBiasMVP = -1;
        _uniFloatShadowDarkness = -1;
        _uniTexShadowMap = -1;
        _textureCount = 0;
        [self setupProgram];
    }
    return self;
}


- (void)setupProgram {
    [self addAttribute:@"VertexPosition"];
    if (_config.lightCount > 0) {
        [self addAttribute:@"VertexNormal"];
    }
    if (_config.enableTexture) {
        [self addAttribute:@"TextureCoord"];
    }
    
    BOOL isOK = [self link];
    if (isOK) {
        _attribVec4Position = [self attributeIndex:@"VertexPosition"];
        _uniMtx4MVPMatrix   = [self uniformIndex:@"MVPMatrix"];
        _uniVec4BaseColor   = [self uniformIndex:@"BaseColor"];
        if (_config.lightCount > 0) {
            [self initializeLightUniforms];
            [self use];
            glUniform1i(_uniIntLightCount, _config.lightCount);
        }
        if (_config.enableShadowMapping) {
            [self initializeShadowMapUniforms];
        }
        if (_config.enableTexture) {
            [self initializeTextureUniforms];
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


- (void)beginRendering {
    [self use];
    _isEditing = YES;
    _textureCount = 0;
}

- (void)endRendering {
    _isEditing = NO;
    _textureCount = 0;
}


#pragma makr - Initialize Uniforms {
- (void)initializeLightUniforms {
    _attribVec3Normal       = [self attributeIndex:@"VertexNormal"];
    _uniMtx3NormalMatrix    = [self uniformIndex:@"NormalMatrix"];
    _uniIntLightCount       = [self uniformIndex:@"LightCount"];
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
    _uniFloatShadowDarkness = [self uniformIndex:@"ShadowDarkness"];
    _uniTexShadowMap        = [self uniformIndex:@"ShadowMapTexture"];
}


- (void)initializeTextureUniforms {
    _attriVec2TextureCoord  = [self attributeIndex:@"TextureCoord"];
    _uniTexTextureMap       = [self uniformIndex:@"TextureMap"];
}


#pragma mark - uniform setters
- (BOOL)setPositionAttribute:(CEVBOAttribute *)attribute {
    if (!_isEditing ||
        _attribVec4Position < 0) {
        CEWarning(@"Fail to setup position attribute");
        return NO;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_attribVec4Position);
        _hasEnabledPosition = NO;
        
    } else if (attribute.name != CEVBOAttributePosition ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        CEWarning(@"Fail to setup position attribute");
        return NO;
    }
    
    if (!_hasEnabledPosition) {
        glEnableVertexAttribArray(_attribVec4Position);
        _hasEnabledPosition = YES;
    }
//    ... setup attribute here
    glVertexAttribPointer(_attribVec4Position,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    return YES;
}


- (BOOL)setModelViewProjectionMatrix:(GLKMatrix4)mvpMatrix4 {
    if (!_isEditing || _uniMtx4MVPMatrix < 0) {
        return NO;
    }
    glUniformMatrix4fv(_uniMtx4MVPMatrix, 1, GL_FALSE, mvpMatrix4.m);
    return YES;
}


- (BOOL)setBaseColor:(GLKVector4)colorVec4 {
    if (!_isEditing || _uniVec4BaseColor < 0) {
        return NO;
    }
    glUniform4fv(_uniVec4BaseColor, 1, colorVec4.v);
    return YES;
}


#pragma mark - lighting
- (BOOL)setNormalAttribute:(CEVBOAttribute *)attribute {
    if (!_isEditing ||
        _attribVec3Normal < 0) {
        CEWarning(@"Fail to setup normal attribute");
        return NO;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_attribVec3Normal);
        _hasEnabledNormal = NO;
        
    } else if (attribute.name != CEVBOAttributeNormal ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        CEWarning(@"Fail to setup normal attribute");
        return NO;
    }
    
    if (!_hasEnabledNormal) {
        glEnableVertexAttribArray(_attribVec3Normal);
        _hasEnabledNormal = YES;
    }
    //    ... setup attribute here
    glVertexAttribPointer(_attribVec3Normal,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    return YES;
}


- (BOOL)setModelViewMatrix:(GLKMatrix4)mvMatrix4 {
    if (!_isEditing || _uniMtx4MVMatrix < 0) {
        return NO;
    }
    glUniformMatrix4fv(_uniMtx4MVMatrix, 1, GL_FALSE, mvMatrix4.m);
    return YES;
}


- (BOOL)setNormalMatrix:(GLKMatrix3)normalMatrix3 {
    if (!_isEditing || _uniMtx3NormalMatrix < 0) {
        return NO;
    }
    glUniformMatrix3fv(_uniMtx3NormalMatrix, 1, GL_FALSE, normalMatrix3.m);
    return YES;
}


- (BOOL)setEyeDirection:(GLKVector3)eyeDirectionVec3 {
    if (!_isEditing || _uniVec3EyeDirection < 0) {
        return NO;
    }
    glUniform3fv(_uniVec3EyeDirection, 1, eyeDirectionVec3.v);
    return YES;
}


#pragma mark - texture
- (BOOL)setTextureCoordinateAttribute:(CEVBOAttribute *)attribute {
    if (!_isEditing ||
        _attriVec2TextureCoord < 0) {
        CEWarning(@"Fail to setup texture attribute");
        return NO;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_attriVec2TextureCoord);
        _hasEnableTexture = NO;
        
    } else if (attribute.name != CEVBOAttributeTextureCoord ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        CEWarning(@"Fail to setup texture attribute");
        return NO;
    }
    
    if (!_hasEnableTexture) {
        glEnableVertexAttribArray(_attriVec2TextureCoord);
        _hasEnableTexture = YES;
    }
    //    ... setup attribute here
    glVertexAttribPointer(_attriVec2TextureCoord,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    return YES;
}

- (BOOL)setTexture:(GLuint)textureId {
    if (!_isEditing || _uniTexTextureMap < 0) {
        return NO;
    }
    glActiveTexture(GL_TEXTURE0 + _textureCount);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(_uniTexTextureMap, _textureCount);
    _textureCount++;
    
    return YES;
}


#pragma mark - shadow map
- (BOOL)setDepthBiasModelViewProjectionMatrix:(GLKMatrix4)depthBiasMVPMatrix4 {
    if (!_isEditing || _uniMtx4DepthBiasMVP < 0) {
        return NO;
    }
    glUniformMatrix4fv(_uniMtx4DepthBiasMVP, 1, GL_FALSE, depthBiasMVPMatrix4.m);
    return YES;
}

- (BOOL)setShadowDarkness:(GLfloat)shadowDarkness {
    if (!_isEditing || _uniFloatShadowDarkness < 0) {
        return NO;
    }
    glUniform1f(_uniFloatShadowDarkness, shadowDarkness);
    return YES;
}


- (BOOL)setShadowMapTexture:(GLuint)shadowMapTextureId {
    if (!_isEditing || _uniTexShadowMap < 0) {
        return NO;
    }
    glActiveTexture(GL_TEXTURE0 + _textureCount);
    glBindTexture(GL_TEXTURE_2D, shadowMapTextureId);
    glUniform1i(_uniTexShadowMap, _textureCount);
    _textureCount++;
    
    return YES;
}


@end








