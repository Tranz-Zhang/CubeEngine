//
//  CEShaders.h
//  CubeEngine
//
//  Created by chance on 5/20/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#ifndef CubeEngine_CEShaders_h
#define CubeEngine_CEShaders_h

NSString *const kVertexShader = CE_SHADER_STRING
(
 // basic info
 uniform mat4 MVPMatrix;
 attribute highp vec4 VertexPosition;
 
 \n#ifdef CE_ENABLE_LIGHTING\n //                                               >> lighting
 struct LightInfo {
     bool IsEnabled;
     mediump int LightType; // 0:none 1:directional 2:point 3:spot
     mediump vec4 LightPosition;  // in eye space
     mediump vec3 LightDirection; // in eye space
     mediump vec3 LightColor;
     mediump float Attenuation;
     mediump float SpotConsCutoff;
     mediump float SpotExponent;
 };
 uniform LightInfo MainLight;

 \n#ifdef CE_ENABLE_NORMAL_MAPPING\n //                                         >> normal mapping
 attribute highp vec3 VertexNormal;
 attribute lowp vec3 VertexTangent;
 uniform vec3 EyeDirection; // in eye space
 uniform mat3 NormalMatrix;
 varying vec3 LightDirection;
 varying vec3 HalfVector;
 varying float Attenuation;

 \n#else\n //                                                                   >> classic lighting
 attribute highp vec3 VertexNormal;
 uniform mat4 MVMatrix;
 uniform mat3 NormalMatrix;
 uniform vec3 EyeDirection;
 varying vec3 Normal;
 varying vec3 LightDirection;
 varying vec3 HalfVector;
 varying float Attenuation;
 
 \n#endif\n //                                                                  << normal mapping & classic lighting
 
 
 // shadow mapping
 \n#ifdef CE_ENABLE_SHADOW_MAPPING\n //                                         >> shadow mapping
 uniform mat4 DepthBiasMVP;
 varying vec4 ShadowCoord;
 \n#endif\n //                                                                  << shadow mapping
 
 \n#endif\n //                                                                  << lighting
  
 // texture
 \n#ifdef CE_ENABLE_TEXTURE\n //                                                >> texture
 attribute highp vec2 TextureCoord;
 varying vec2 TextureCoordOut;
 \n#endif\n //                                                                  << texture
 
 void main () {
     // lighting
     \n#ifdef CE_ENABLE_LIGHTING\n //                                           >> lighting
     \n#ifdef CE_ENABLE_NORMAL_MAPPING\n //                                     >> normal mapping
     vec3 n = normalize(NormalMatrix * VertexNormal);
     vec3 t = normalize(NormalMatrix * VertexTangent);
     vec3 b = cross(n, t);
     vec3 tempVec;
     
     tempVec.x = dot(MainLight.LightDirection, t);
     tempVec.y = dot(MainLight.LightDirection, b);
     tempVec.z = dot(MainLight.LightDirection, n);
     LightDirection = normalize(tempVec);
     
     tempVec.x = dot(EyeDirection, t);
     tempVec.y = dot(EyeDirection, b);
     tempVec.z = dot(EyeDirection, n);
     vec3 eyeDirection_tangentSpace = normalize(tempVec);
     HalfVector = normalize(LightDirection + eyeDirection_tangentSpace);
     Attenuation = 1.0;
     
     \n#else\n //                                                               >> classic lighting
     Normal = normalize(NormalMatrix * VertexNormal);
     // for locol lights, compute per fragment direction, halfVector and attenuation
     if (MainLight.LightType > 1) {
         LightDirection = vec3(MainLight.LightPosition) - vec3(MVMatrix * VertexPosition);
         float lightDistance = length(LightDirection);
         LightDirection = LightDirection / lightDistance; // normalize light direction
         
         Attenuation = 1.0 / (1.0 + MainLight.Attenuation * lightDistance + MainLight.Attenuation * lightDistance * lightDistance);
         if (MainLight.LightType == 3) { // spot light
             // lightDirection: current position to light position Direction
             // MainLight.LightDirection: source light direction, ref as ConeDirection
             float spotCos = dot(LightDirection, MainLight.LightDirection);
             if (spotCos < MainLight.SpotConsCutoff) {
                 Attenuation = 0.0;
             } else {
                 Attenuation *= pow(spotCos, MainLight.SpotExponent);
             }
         }
         HalfVector = normalize(LightDirection + EyeDirection);
         
     } else { // directional light
         LightDirection = MainLight.LightDirection;
         HalfVector = normalize(MainLight.LightDirection + EyeDirection);
         Attenuation = 1.0;
     }
     \n#endif\n //                                                              << normal mapping & classic lighting
     
         
     // shadow mapping
     \n#ifdef CE_ENABLE_SHADOW_MAPPING\n //                                     >> shadow mapping
     ShadowCoord = DepthBiasMVP * VertexPosition;
     \n#endif\n //                                                              << shadow mapping
     
     \n#endif\n //                                                              << lighting
     
     // texture
     \n#ifdef CE_ENABLE_TEXTURE\n //                                            >> texture
     TextureCoordOut = TextureCoord;
     \n#endif\n //                                                              << texture
     
     gl_Position = MVPMatrix * VertexPosition;
 }
);


NSString *const kFragmentSahder = CE_SHADER_STRING
(
 precision mediump float;
 
 //  material
 uniform vec4 DiffuseColor;
 
 
 // texture
 \n#ifdef CE_ENABLE_TEXTURE\n //                                                >> texture
 uniform lowp sampler2D DiffuseTexture;
 varying vec2 TextureCoordOut;
 \n#endif\n //                                                                  << texture
 
 
 // lighting
 \n#ifdef CE_ENABLE_LIGHTING\n //                                               >> lighting
 uniform vec3 SpecularColor;
 uniform vec3 AmbientColor;
 uniform float ShininessExponent;
 
 struct LightInfo {
     bool IsEnabled;
     mediump int LightType; // 0:none 1:directional 2:point 3:spot
     mediump vec4 LightPosition;  // in eys space
     mediump vec3 LightDirection; // in eye space
     mediump vec3 LightColor;
     mediump float Attenuation;
     mediump float SpotConsCutoff;
     mediump float SpotExponent;
 };
 uniform LightInfo MainLight;

 \n#ifdef CE_ENABLE_NORMAL_MAPPING\n //                                         >> normal mapping
 uniform sampler2D NormalMapTexture;
 varying vec3 LightDirection;
 varying vec3 HalfVector;
 varying float Attenuation;
 
 \n#else\n //                                                                   >> classic lighting
 varying vec3 Normal;
 varying vec3 LightDirection;
 varying vec3 HalfVector;
 varying float Attenuation;
 
 \n#endif\n //                                                                  << normal mapping & classic lighting
 
 
 // shadow mapping
 \n#ifdef CE_ENABLE_SHADOW_MAPPING\n //                                         >> shadow mapping
 uniform float ShadowDarkness;
 uniform sampler2D ShadowMapTexture;
 varying vec4 ShadowCoord;
 \n#endif\n //                                                                  << shadow mapping
 
 vec3 ApplyLightingEffect(vec3 inputColor) {
     \n#ifdef CE_ENABLE_NORMAL_MAPPING\n //                                     >> normal mapping
     
     vec3 normal = texture2D(NormalMapTexture, TextureCoordOut).rgb * 2.0 - 1.0;
     float diffuse = max(0.0, dot(normal, LightDirection));
     float specular = max(0.0, dot(normal, HalfVector));
     specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
     vec3 scatteredLight = AmbientColor * Attenuation + MainLight.LightColor * diffuse * Attenuation;
     vec3 reflectedLight = SpecularColor * specular * Attenuation;
     
     \n#else\n //                                                               >> classic lighting
     float diffuse = max(0.0, dot(Normal, LightDirection));
     float specular = max(0.0, dot(Normal, HalfVector));
     specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
     vec3 scatteredLight = AmbientColor * Attenuation + MainLight.LightColor * diffuse * Attenuation;
     vec3 reflectedLight = SpecularColor * specular * Attenuation;
     
     \n#endif\n //                                                              << normal mapping & classic lighting
     
     // apply shadow mapping
     \n#ifdef CE_ENABLE_SHADOW_MAPPING\n //                                     >> shadow mapping
     float depthValue = texture2D(ShadowMapTexture, vec2(ShadowCoord.x/ShadowCoord.w, ShadowCoord.y/ShadowCoord.w)).z;
     if (depthValue != 1.0 && depthValue < (ShadowCoord.z / ShadowCoord.w) - 0.005) {
         scatteredLight *= ShadowDarkness;
         reflectedLight *= ShadowDarkness;
     }
     \n#endif\n //                                                              << shadow mapping
     
     return min(inputColor * scatteredLight + reflectedLight, vec3(1.0));
 }
 
 \n#endif\n //                                                                  << lighting
 
 \n#ifdef CE_RENDER_TRANSPARENT_OBJECT\n //                                     >> transparent
 uniform float Transparency;
 \n#endif\n //                                                                  << transparent
 
 void main() {
     // input color
     vec4 inputColor;
     \n#ifdef CE_ENABLE_TEXTURE\n //                                            >> texture
     inputColor = texture2D(DiffuseTexture, TextureCoordOut);
     \n#else\n
         inputColor = DiffuseColor;
     \n#endif\n //                                                              << texture
     
     \n#ifdef CE_RENDER_ALPHA_TESTED_OBJECT\n //                                >> alpha test
     if (inputColor.a < 0.5) discard;
     \n#endif\n //                                                              << alpha test
     
     // process color
     vec4 processedColor;
     \n#ifdef CE_ENABLE_LIGHTING\n //                                           << lighting
     vec3 lightingColor = ApplyLightingEffect(inputColor.rgb);
     processedColor = vec4(lightingColor.rgb, inputColor.a);
     \n#else\n
         processedColor = inputColor;
     \n#endif\n //                                                              >> lighting
     
     // final blending
     \n#ifdef CE_RENDER_TRANSPARENT_OBJECT\n //                                 >> transparent
     processedColor.a = Transparency;
     \n#endif\n //                                                              << transparent
     
     gl_FragColor = processedColor;
 }
);


#endif
