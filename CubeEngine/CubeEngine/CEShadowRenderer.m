//
//  CEShadowRenderer.m
//  CubeEngine
//
//  Created by chance on 4/30/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#import "CEShadowRenderer.h"
#import "CEScene_Rendering.h"
#import "CEProgram.h"
#import "CELight_Rendering.h"
#import "CEModel_Rendering.h"
#import "CECamera_Rendering.h"

NSString *const kShadowVertexShader = CE_SHADER_STRING
(
 attribute highp vec4 VertexPosition;
 attribute highp vec3 VertexNormal;
 
 uniform mat4 MVPMatrix;
 uniform mat4 MVMatrix;
 uniform mat4 DepthBiasMVP;
 uniform mat3 NormalMatrix;
 
 varying vec3 Normal;
 varying vec4 Position;
 varying vec4 ShadowCoord;
 
 void main () {
     Normal = normalize(NormalMatrix * VertexNormal);
     Position = MVMatrix * VertexPosition;
     ShadowCoord = DepthBiasMVP * VertexPosition;
     gl_Position = MVPMatrix * VertexPosition;
 }
);

NSString *const kShadowFragmentSahder = CE_SHADER_STRING
(
 precision mediump float;
 
 struct LightInfo {
     bool IsEnabled;
     int LightType; // 0:none 1:directional 2:point 3:spot
     vec4 LightPosition;
     vec3 LightDirection;
     vec3 LightColor;
     vec3 AmbientColor;
     float SpecularIntensity;
     float Shiniess;
     float Attenuation;
     float SpotConsCutoff;
     float SpotExponent;
 };
 uniform LightInfo Lights[LIGHT_COUNT];
 
 uniform vec4 BaseColor;
 uniform vec3 EyeDirection;
 uniform int LightCount;
 
 uniform sampler2D ShadowMapTexture;
 
 varying vec3 Normal;
 varying vec4 Position;
 varying vec4 ShadowCoord;
 
 void main() {
     vec3 scatteredLight = vec3(0.0);
     vec3 reflectedLight = vec3(0.0);
     
     // loop over all light and calculate light effect
     bool hasLightEnabled = false;
     for (int i = 0; i < LightCount; i++) {
         if (!Lights[i].IsEnabled) {
             continue;
         }
         hasLightEnabled = true;
         
         vec3 halfVector;
         vec3 lightDirection = Lights[i].LightDirection;
         float attenuation = 1.0;
         
         // for locol lights, compute per-fragment direction, halfVector and attenuation
         if (Lights[i].LightType > 1) {
             lightDirection = vec3(Lights[i].LightPosition) - vec3(Position);
             float lightDistance = length(lightDirection);
             lightDirection = lightDirection / lightDistance; // normalize light direction
             
             attenuation = 1.0 / (1.0 + Lights[i].Attenuation * lightDistance + Lights[i].Attenuation * lightDistance * lightDistance);
             if (Lights[i].LightType == 3) { // spot light
                 // lightDirection: current position to light position Direction
                 // Lights[i].LightDirection: source light direction, ref as ConeDirection
                 float spotCos = dot(lightDirection, Lights[i].LightDirection);
                 if (spotCos < Lights[i].SpotConsCutoff) {
                     attenuation = 0.0;
                 } else {
                     attenuation *= pow(spotCos, Lights[i].SpotExponent);
                 }
             }
             halfVector = normalize(lightDirection + EyeDirection);
             
         } else {
             halfVector = normalize(Lights[i].LightDirection + EyeDirection);
         }
         
         // calculate diffuse and specular
         float diffuse = max(0.0, dot(Normal, lightDirection));
         float specular = max(0.0, dot(Normal, halfVector));
         
         specular = (diffuse == 0.0) ? 0.0 : pow(specular, Lights[i].Shiniess);
         scatteredLight += Lights[i].AmbientColor * attenuation + Lights[i].LightColor * diffuse * attenuation;
         reflectedLight += Lights[i].LightColor * specular * attenuation;
     }
     
     if (hasLightEnabled) {
         // test shadow mapping
         float depthValue = texture2D(ShadowMapTexture, vec2(ShadowCoord.x/ShadowCoord.w, ShadowCoord.y/ShadowCoord.w)).z;
         if (depthValue != 1.0 && depthValue < (ShadowCoord.z / ShadowCoord.w) - 0.005) {
             scatteredLight *= 0.5;
             reflectedLight *= 0.5;
         }
         
         vec3 rgb = min(BaseColor.rgb * scatteredLight + reflectedLight, vec3(1.0));
         gl_FragColor = vec4(rgb, BaseColor.a);
     } else {
         gl_FragColor = BaseColor;
     }
 }
);


@implementation CEShadowRenderer {
    CEProgram *_program;
    NSArray *_lightUniformInfos;
    
    GLint _attribVec4Position;
    GLint _attribVec3Normal;
    
    GLint _uniMtx4MVPMatrix;
    GLint _uniMtx4MVMatrix;
    GLint _uniMtx3NormalMatrix;
    
    GLint _uniVec4BaseColor;
    GLint _uniVec3EyeDirection;
    GLint _uniIntLightCount;
    
    // shadow map
    GLint _uniMtx4DepthBiasMVP;
    GLint _uniTexShadowMapTexture;
}


- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


- (BOOL)setupRenderer {
    if (_program.initialized) return YES;
    int maxLightCount = [CEScene currentScene].maxLightCount;
    NSString *fragmentShader = [kShadowFragmentSahder stringByReplacingOccurrencesOfString:@"LIGHT_COUNT" withString:[NSString stringWithFormat:@"%d", maxLightCount]];
    _program = [[CEProgram alloc] initWithVertexShaderString:kShadowVertexShader
                                        fragmentShaderString:fragmentShader];
    [_program addAttribute:@"VertexPosition"];
    [_program addAttribute:@"VertexNormal"];
    BOOL isOK = [_program link];
    if (isOK) {
        _attribVec4Position     = [_program attributeIndex:@"VertexPosition"];
        _uniMtx4MVPMatrix       = [_program uniformIndex:@"MVPMatrix"];
        
        
        _attribVec3Normal       = [_program attributeIndex:@"VertexNormal"];
        _uniMtx3NormalMatrix    = [_program uniformIndex:@"NormalMatrix"];
        _uniIntLightCount       = [_program uniformIndex:@"LightCount"];
        _uniVec4BaseColor       = [_program uniformIndex:@"BaseColor"];
        _uniMtx4MVMatrix        = [_program uniformIndex:@"MVMatrix"];
        _uniVec3EyeDirection    = [_program uniformIndex:@"EyeDirection"];
        
        _uniMtx4DepthBiasMVP    = [_program uniformIndex:@"DepthBiasMVP"];
        _uniTexShadowMapTexture = [_program uniformIndex:@"ShadowMapTexture"];
        
        // get uniform infos
        NSMutableArray *uniformInfos = [NSMutableArray arrayWithCapacity:maxLightCount];
        for (int i = 0; i < maxLightCount; i++) {
            CELightUniformInfo *info = [CELightUniformInfo new];
            info.lightType_i = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightType", i]];
            if (info.lightType_i < 0) continue;
            info.isEnabled_b = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].IsEnabled", i]];
            if (info.isEnabled_b < 0) continue;
            info.lightPosition_vec4 = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightPosition", i]];
            if (info.lightPosition_vec4 < 0) continue;
            info.lightDirection_vec3 = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightDirection", i]];
            if (info.lightDirection_vec3 < 0) continue;
            info.lightColor_vec3 = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].LightColor", i]];
            if (info.lightColor_vec3 < 0) continue;
            info.ambientColor_vec3 = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].AmbientColor", i]];
            if (info.ambientColor_vec3 < 0) continue;
            info.specularIntensity_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpecularIntensity", i]];
            if (info.specularIntensity_f < 0) continue;
            info.shiniess_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].Shiniess", i]];
            if (info.shiniess_f < 0) continue;
            info.attenuation_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].Attenuation", i]];
            if (info.attenuation_f < 0) continue;
            info.spotCosCutoff_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpotConsCutoff", i]];
            if (info.spotCosCutoff_f < 0) continue;
            info.spotExponent_f = [_program uniformIndex:[NSString stringWithFormat:@"Lights[%d].SpotExponent", i]];
            if (info.spotExponent_f < 0) continue;
            
            [uniformInfos addObject:info];
        }
        _lightUniformInfos = [uniformInfos copy];
        
    } else {
        // print error info
        NSString *progLog = [_program programLog];
        CEError(@"Program link log: %@", progLog);
        NSString *fragLog = [_program fragmentShaderLog];
        CEError(@"Fragment shader compile log: %@", fragLog);
        NSString *vertLog = [_program vertexShaderLog];
        CEError(@"Vertex shader compile log: %@", vertLog);
        _program = nil;
        NSAssert(0, @"Fail to Compile Program");
    }
    
    return isOK;
}


- (void)setLights:(NSSet *)lights {
    if (_lights != lights) {
        _lights = [lights copy];
        int idx = 0;
        for (CELight *light in _lights) {
            if (idx < _lightUniformInfos.count) {
                light.uniformInfo = _lightUniformInfos[idx];
            }
            idx++;
        }
    }
}


- (void)renderObjects:(NSSet *)objects {
    if (!_program || !_camera) {
        CEError(@"Invalid renderer environment");
        return;
    }
    
    // setup shadow mapping
//    CELight *shadowLight;
//    for (CELight *light in _lights) {
//        if(light.enableShadow) {
//            shadowLight = light;
//            break;
//        }
//    }
    
    for (CEModel *model in objects) {
        [self recursiveRenderModel:model];
    }
}


- (void)recursiveRenderModel:(CEModel *)model {
    if (model.vertexBuffer) {
        [self renderModel:model];
    }
    for (CEModel *child in model.childObjects) {
        [self recursiveRenderModel:child];
    }
}


- (void)renderModel:(CEModel *)model {
    if (!model.vertexBuffer) {
        CEError(@"Empty vertexBuffer");
        return;
    }
    
    // setup vertex buffer
    if (![model.vertexBuffer setupBuffer] ||
        (model.indicesBuffer && ![model.indicesBuffer setupBuffer])) {
        return;
    }
    // prepare for rendering
    if (![model.vertexBuffer prepareAttribute:CEVBOAttributePosition withProgramIndex:_attribVec4Position] ||
        ![model.vertexBuffer prepareAttribute:CEVBOAttributeNormal withProgramIndex:_attribVec3Normal]){
        return;
    }
    if (model.indicesBuffer && ![model.indicesBuffer bindBuffer]) {
        return;
    }
    [_program use];
    
    // setup lighting uniforms !!!: must setup light before mvp matrix;
    glUniform1i(_uniIntLightCount, (GLint)_lights.count);
    for (CELight *light in _lights) {
        [light updateUniformsWithCamera:_camera];
//        if (light.enabled && light.shadowMapBuffer) {
//            glBindTexture(GL_TEXTURE_2D, light.shadowMapBuffer.textureId);
//            glUniform1i(_uniTexShadowMapTexture, 0);
//            GLKMatrix4 biasMatrix = GLKMatrix4Make(0.5, 0.0, 0.0, 0.0,
//                                                   0.0, 0.5, 0.0, 0.0,
//                                                   0.0, 0.0, 0.5, 0.0,
//                                                   0.5, 0.5, 0.5, 1.0);
//            GLKMatrix4 depthMVP = GLKMatrix4Multiply(light.lightViewMatrix, model.transformMatrix);
//            depthMVP = GLKMatrix4Multiply(light.lightProjectionMatrix, depthMVP);
//            depthMVP = GLKMatrix4Multiply(biasMatrix, depthMVP);
//            glUniformMatrix4fv(_uniMtx4DepthBiasMVP, 1, GL_FALSE, depthMVP.m);
//        }
    }
    
    // setup other uniforms
    glUniform4f(_uniVec4BaseColor, model.vec3BaseColor.r, model.vec3BaseColor.g,
                model.vec3BaseColor.b, model.vec3BaseColor.a);
    // we use eye space to do the calculation, so the eye direction is always (0, 0, 1)
    glUniform3f(_uniVec3EyeDirection, 0.0, 0.0, 1.0);
    
    // setup MVP matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_camera.viewMatrix, model.transformMatrix);
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_camera.projectionMatrix, modelViewMatrix);
    glUniformMatrix4fv(_uniMtx4MVPMatrix, 1, GL_FALSE, projectionMatrix.m);
    glUniformMatrix4fv(_uniMtx4MVMatrix, 1, GL_FALSE, modelViewMatrix.m);
    
    // setup normal matrix
    GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(modelViewMatrix);
    normalMatrix = GLKMatrix3InvertAndTranspose(normalMatrix, NULL);
    glUniformMatrix3fv(_uniMtx3NormalMatrix, 1, GL_FALSE, normalMatrix.m);
    
    glBindFramebuffer(GL_FRAMEBUFFER, [CEScene currentScene].renderCore.defaultFramebuffer);
    if (model.indicesBuffer) { // glDrawElements
        glDrawElements(GL_TRIANGLES, model.indicesBuffer.indicesCount, model.indicesBuffer.indicesDataType, 0);
        
    } else { // glDrawArrays
        glDrawArrays(GL_TRIANGLES, 0, model.vertexBuffer.vertexCount);
    }
}


@end




