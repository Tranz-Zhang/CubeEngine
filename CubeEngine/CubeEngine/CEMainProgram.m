//
//  CEMainProgram.m
//  CubeEngine
//
//  Created by chance on 5/20/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEMainProgram.h"
#import "CEShaders.h"
#import "CELightUniforms.h"
#import "CEShader_test.h"

#define kMaxTextureUnitCount 8

typedef NS_ENUM(GLuint, CETextureUnit) {
    CETextureUnitModel      = 0,
    CETextureUnitNormalMap  = 1,
    CETextureUnitShadowMap  = 2,
    // max = 8
};


@implementation CEMainProgram {
    BOOL _hasEnabledPosition;
    BOOL _hasEnableTexture;
    BOOL _hasEnableTangent;
    BOOL _hasEnabledNormal;
    GLuint _textureIds[kMaxTextureUnitCount]; // _textureIds[textureUnit] = textureId
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
        if (config.enableNormalMapping) {
            [vertexShaderString insertString:@"#define CE_ENABLE_NORMAL_MAPPING\n" atIndex:0];
        }
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
    
    if (config.renderMode == CERenderModeAlphaTest) {
        [fragmentShaderString insertString:@"#define CE_RENDER_ALPHA_TESTED_OBJECT\n" atIndex:0];
        
    } else if (config.renderMode == CERenderModeTransparent) {
        [fragmentShaderString insertString:@"#define CE_RENDER_TRANSPARENT_OBJECT\n" atIndex:0];
    }
    
    if (config.lightCount > 0) {
        [fragmentShaderString insertString:@"#define CE_ENABLE_LIGHTING\n" atIndex:0];
        [fragmentShaderString replaceOccurrencesOfString:@"CE_LIGHT_COUNT"
                                              withString:[NSString stringWithFormat:@"%d", config.lightCount]
                                                 options:0
                                                   range:NSMakeRange(0, fragmentShaderString.length)];
        if (config.enableNormalMapping) {
            [fragmentShaderString insertString:@"#define CE_ENABLE_NORMAL_MAPPING\n" atIndex:0];
        }
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
        _attribPosition_vec4 = -1;
        _uni4MVPMatrix_mtx4 = -1;
        _uniDiffuseColor_vec4 = -1;
        
        // lighting
        _uniLightCount_i = -1;
        _attribNormal_vec3 = -1;
        _uniMVMatrix_mtx4 = -1;
        _uniNormalMatrix_mtx3 = -1;
        _uniEyeDirection_vec3 = -1;
        
        // shadow map
        _uniDepthBiasMVP_mtx4 = -1;
        _uniShadowDarkness_f = -1;
        _uniShadowMap_tex = -1;
        
        memset(_textureIds, 0, sizeof(_textureIds));
        [self setupProgram];
    }
    return self;
}


- (void)setupProgram {
    [self addAttribute:@"VertexPosition"];
    if (_config.lightCount > 0) {
        [self addAttribute:@"VertexNormal"];
        if (_config.enableNormalMapping) {
            [self addAttribute:@"VertexTangent"];
        }
    }
    if (_config.enableTexture) {
        [self addAttribute:@"TextureCoord"];
    }
    
    BOOL isOK = [self link];
    if (isOK) {
        _attribPosition_vec4    = [self attributeIndex:@"VertexPosition"];
        _uni4MVPMatrix_mtx4     = [self uniformIndex:@"MVPMatrix"];
        _uniDiffuseColor_vec4   = [self uniformIndex:@"DiffuseColor"];
        if (_config.lightCount > 0) {
            [self initializeLightUniforms];
            [self use];
            glUniform1i(_uniLightCount_i, _config.lightCount);
        }
        if (_config.enableShadowMapping) {
            [self initializeShadowMapUniforms];
        }
        if (_config.enableTexture) {
            [self initializeTextureUniforms];
        }
        if (_config.renderMode == CERenderModeTransparent) {
            _uniTransparency_f = [self uniformIndex:@"Transparency"];
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
}

- (void)endRendering {
    _isEditing = NO;
}


#pragma makr - Initialize Uniforms {
- (void)initializeLightUniforms {
    _attribNormal_vec3      = [self attributeIndex:@"VertexNormal"];
    _uniNormalMatrix_mtx3   = [self uniformIndex:@"NormalMatrix"];
    _uniLightCount_i        = [self uniformIndex:@"LightCount"];
    _uniMVMatrix_mtx4       = [self uniformIndex:@"MVMatrix"];
    _uniEyeDirection_vec3   = [self uniformIndex:@"EyeDirection"];
    _uniSpecularColor_vec3  = [self uniformIndex:@"SpecularColor"];
    _uniAmbientColor_vec3   = [self uniformIndex:@"AmbientColor"];
    _uniShininessExponent_f = [self uniformIndex:@"ShininessExponent"];
    
    NSMutableArray *uniformInfos = [NSMutableArray arrayWithCapacity:_config.lightCount];
    for (int i = 0; i < _config.lightCount; i++) {
        CELightUniforms *info = [CELightUniforms new];
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
        
        info.attenuation_f = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].Attenuation", i]];
        if (info.attenuation_f < 0) continue;
        
        info.spotCosCutoff_f = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpotConsCutoff", i]];
        if (info.spotCosCutoff_f < 0) continue;
        
        info.spotExponent_f = [self uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpotExponent", i]];
        if (info.spotExponent_f < 0) continue;
        
        [uniformInfos addObject:info];
    }
    _uniLightInfos = [uniformInfos copy];
    
    if (_config.enableNormalMapping) {
        _attribTangent_vec3 = [self attributeIndex:@"VertexTangent"];
        _uniLightPosition_vec3 = [self uniformIndex:@"LightPosition"];
        _uniNormalMapTexture_tex = [self uniformIndex:@"NormalMapTexture"];
    }
}


- (void)initializeShadowMapUniforms {
    _uniDepthBiasMVP_mtx4    = [self uniformIndex:@"DepthBiasMVP"];
    _uniShadowDarkness_f = [self uniformIndex:@"ShadowDarkness"];
    _uniShadowMap_tex        = [self uniformIndex:@"ShadowMapTexture"];
}


- (void)initializeTextureUniforms {
    _attribTextureCoord_vec2  = [self attributeIndex:@"TextureCoord"];
    _uniDiffuseTexture_tex       = [self uniformIndex:@"DiffuseTexture"];
}


#pragma mark - uniform setters
- (BOOL)setPositionAttribute:(CEVBOAttribute *)attribute {
    if (!_isEditing ||
        _attribPosition_vec4 < 0) {
        CEWarning(@"Fail to setup position attribute");
        return NO;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_attribPosition_vec4);
        _hasEnabledPosition = NO;
        return YES;
        
    } else if (attribute.name != CEVBOAttributePosition ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        CEWarning(@"Fail to setup position attribute");
        return NO;
    }
    
    if (!_hasEnabledPosition) {
        glEnableVertexAttribArray(_attribPosition_vec4);
        _hasEnabledPosition = YES;
    }
//    ... setup attribute here
    glVertexAttribPointer(_attribPosition_vec4,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    return YES;
}


- (BOOL)setModelViewProjectionMatrix:(GLKMatrix4)mvpMatrix4 {
    if (!_isEditing || _uni4MVPMatrix_mtx4 < 0) {
        return NO;
    }
    glUniformMatrix4fv(_uni4MVPMatrix_mtx4, 1, GL_FALSE, mvpMatrix4.m);
    return YES;
}


- (BOOL)setDiffuseColor:(GLKVector4)colorVec4 {
    if (!_isEditing || _uniDiffuseColor_vec4 < 0) {
        return NO;
    }
    glUniform4fv(_uniDiffuseColor_vec4, 1, colorVec4.v);
    return YES;
}


#pragma mark - lighting
- (BOOL)setLightUniformsWithInfo:(CELightInfo *)lightInfos atIndex:(int)index {
    if (!_isEditing || index > _uniLightInfos.count) {
        return NO;
    }
    CELightUniforms *lightUniforms = _uniLightInfos[index];
    glUniform1i(lightUniforms.isEnabled_b, lightInfos.isEnabled ? 1 : 0);
    if (lightInfos.isEnabled) {
        glUniform1i(lightUniforms.lightType_i, lightInfos.lightType);
        glUniform4fv(lightUniforms.lightPosition_vec4, 1, lightInfos.lightPosition.v);
        glUniform3fv(lightUniforms.lightDirection_vec3, 1, lightInfos.lightDirection.v);
        glUniform3fv(lightUniforms.lightColor_vec3, 1, lightInfos.lightColor.v);
        glUniform1f(lightUniforms.attenuation_f, lightInfos.attenuation);
        glUniform1f(lightUniforms.spotCosCutoff_f, lightInfos.spotCosCutOff);
        glUniform1f(lightUniforms.spotExponent_f, lightInfos.spotExponent);
        
        GLint uniform = [self uniformIndex:@"LIGHTDIRECTIONINPUT"];
        if (uniform) {
            glUniform3fv(uniform, 1, lightInfos.lightDirection.v);
        }
    }
    return NO;
}


- (BOOL)setNormalAttribute:(CEVBOAttribute *)attribute {
    if (!_isEditing ||
        _attribNormal_vec3 < 0) {
        CEWarning(@"Fail to setup normal attribute");
        return NO;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_attribNormal_vec3);
        _hasEnabledNormal = NO;
        return YES;
        
    } else if (attribute.name != CEVBOAttributeNormal ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        CEWarning(@"Fail to setup normal attribute");
        return NO;
    }
    
    if (!_hasEnabledNormal) {
        glEnableVertexAttribArray(_attribNormal_vec3);
        _hasEnabledNormal = YES;
    }
    //    ... setup attribute here
    glVertexAttribPointer(_attribNormal_vec3,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    return YES;
}


- (BOOL)setModelViewMatrix:(GLKMatrix4)mvMatrix4 {
    if (!_isEditing || _uniMVMatrix_mtx4 < 0) {
        return NO;
    }
    glUniformMatrix4fv(_uniMVMatrix_mtx4, 1, GL_FALSE, mvMatrix4.m);
    return YES;
}


- (BOOL)setNormalMatrix:(GLKMatrix3)normalMatrix3 {
    if (!_isEditing || _uniNormalMatrix_mtx3 < 0) {
        return NO;
    }
    glUniformMatrix3fv(_uniNormalMatrix_mtx3, 1, GL_FALSE, normalMatrix3.m);
    return YES;
}


- (BOOL)setEyeDirection:(GLKVector3)eyeDirectionVec3 {
    if (!_isEditing || _uniEyeDirection_vec3 < 0) {
        return NO;
    }
    glUniform3fv(_uniEyeDirection_vec3, 1, eyeDirectionVec3.v);
    return YES;
}


- (BOOL)setSpecularColor:(GLKVector3)specularColor {
    if (!_isEditing || _uniSpecularColor_vec3 < 0) {
        return NO;
    }
    glUniform3fv(_uniSpecularColor_vec3, 1, specularColor.v);
    return YES;
}

- (BOOL)setAmbientColor:(GLKVector3)ambientColor {
    if (!_isEditing || _uniAmbientColor_vec3 < 0) {
        return NO;
    }
    glUniform3fv(_uniAmbientColor_vec3, 1, ambientColor.v);
    return YES;
}

- (BOOL)setShininessExponent:(GLfloat)shininessExponent {
    if (!_isEditing || _uniShininessExponent_f < 0) {
        return NO;
    }
    glUniform1f(_uniShininessExponent_f, shininessExponent);
    return YES;
}


#pragma mark - texture
- (BOOL)setTextureCoordinateAttribute:(CEVBOAttribute *)attribute {
    if (!_isEditing ||
        _attribTextureCoord_vec2 < 0) {
        CEWarning(@"Fail to setup texture attribute");
        return NO;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_attribTextureCoord_vec2);
        _hasEnableTexture = NO;
        return YES;
        
    } else if (attribute.name != CEVBOAttributeTextureCoord ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        CEWarning(@"Fail to setup texture attribute");
        return NO;
    }
    
    if (!_hasEnableTexture) {
        glEnableVertexAttribArray(_attribTextureCoord_vec2);
        _hasEnableTexture = YES;
    }
    //    ... setup attribute here
    glVertexAttribPointer(_attribTextureCoord_vec2,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    return YES;
}

- (BOOL)setDiffuseTexture:(GLuint)textureId {
    if (!_isEditing || _uniDiffuseTexture_tex < 0) {
        return NO;
    }
    
    glActiveTexture(GL_TEXTURE0 + CETextureUnitModel);
    glBindTexture(GL_TEXTURE_2D, textureId);
    GLuint currentTextureId = _textureIds[CETextureUnitModel];
    if (currentTextureId != textureId) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glUniform1i(_uniDiffuseTexture_tex, CETextureUnitModel);
        _textureIds[CETextureUnitModel] = textureId;
    }
    
    return YES;
}


#pragma mark - normal map
- (BOOL)setTangentAttribute:(CEVBOAttribute *)attribute {
    if (!_isEditing ||
        _attribTangent_vec3 < 0) {
        CEWarning(@"Fail to setup tangent attribute");
        return NO;
    }
    if (!attribute) {
        glDisableVertexAttribArray(_attribTangent_vec3);
        _hasEnableTangent = NO;
        return YES;
        
    } else if (attribute.name != CEVBOAttributeTangent ||
               attribute.primaryCount <= 0 ||
               attribute.elementStride <= 0) {
        CEWarning(@"Fail to setup texture attribute");
        return NO;
    }
    
    if (!_hasEnableTangent) {
        glEnableVertexAttribArray(_attribTangent_vec3);
        _hasEnableTangent = YES;
    }
    //    ... setup attribute here
    glVertexAttribPointer(_attribTangent_vec3,
                          attribute.primaryCount,
                          attribute.primaryType,
                          GL_FALSE,
                          attribute.elementStride,
                          CE_BUFFER_OFFSET(attribute.elementOffset));
    return YES;
}


- (BOOL)setLightPosition:(GLKVector3)lightPosition {
    if (!_isEditing || _uniLightPosition_vec3 < 0) {
        return NO;
    }
    glUniform3fv(_uniLightPosition_vec3, 1, lightPosition.v);
    return YES;
}


- (BOOL)setNormalMapTexture:(GLuint)textureId {
    if (!_isEditing || _uniNormalMapTexture_tex < 0) {
        return NO;
    }
    GLuint currentTextureId = _textureIds[CETextureUnitNormalMap];
    if (currentTextureId != textureId) {
        glActiveTexture(GL_TEXTURE0 + CETextureUnitNormalMap);
        glBindTexture(GL_TEXTURE_2D, textureId);
        glUniform1i(_uniNormalMapTexture_tex, CETextureUnitNormalMap);
        _textureIds[CETextureUnitNormalMap] = textureId;
    }
    
    return YES;
}


#pragma mark - shadow map
- (BOOL)setDepthBiasModelViewProjectionMatrix:(GLKMatrix4)depthBiasMVPMatrix4 {
    if (!_isEditing || _uniDepthBiasMVP_mtx4 < 0) {
        return NO;
    }
    glUniformMatrix4fv(_uniDepthBiasMVP_mtx4, 1, GL_FALSE, depthBiasMVPMatrix4.m);
    return YES;
}


- (BOOL)setShadowDarkness:(GLfloat)shadowDarkness {
    if (!_isEditing || _uniShadowDarkness_f < 0) {
        return NO;
    }
    glUniform1f(_uniShadowDarkness_f, shadowDarkness);
    return YES;
}


- (BOOL)setShadowMapTexture:(GLuint)textureId {
    if (!_isEditing || _uniShadowMap_tex < 0) {
        return NO;
    }
    GLuint currentTextureId = _textureIds[CETextureUnitShadowMap];
    if (currentTextureId != textureId) {
        glActiveTexture(GL_TEXTURE0 + CETextureUnitShadowMap);
        glBindTexture(GL_TEXTURE_2D, textureId);
        glUniform1i(_uniShadowMap_tex, CETextureUnitShadowMap);
        _textureIds[CETextureUnitShadowMap] = textureId;
    }
    
    return YES;
}


#pragma mark - transparency
- (BOOL)setTransparency:(GLfloat)transparency {
    if (!_isEditing || _uniTransparency_f < 0) {
        return NO;
    }
    glUniform1f(_uniTransparency_f, transparency);
    return YES;
}



@end








