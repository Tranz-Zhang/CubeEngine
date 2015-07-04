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

 // lighting
 \n#ifdef CE_ENABLE_LIGHTING\n
  attribute lowp vec3 VertexNormal;
 uniform mat4 MVMatrix;
 uniform mat3 NormalMatrix;
 varying lowp vec3 Normal;
 varying vec4 Position;
 
 // normal mapping
 \n#ifdef CE_ENABLE_NORMAL_MAPPING\n
 attribute lowp vec3 VertexTangent;
 uniform vec3 LightPosition;
 varying vec3 TestLightDir;
 varying vec3 TestEyeDir;
 \n#endif\n // end of normal mapping
 
 \n#endif\n // end of lighting
 
 // texture
 \n#ifdef CE_ENABLE_TEXTURE\n
 attribute highp vec2 TextureCoord;
 varying vec2 TextureCoordOut;
 \n#endif\n
 
 // shadow mapping
 \n#ifdef CE_ENABLE_SHADOW_MAPPING\n
 uniform mat4 DepthBiasMVP;
 varying vec4 ShadowCoord;
 \n#endif\n
 
 
 void main () {
     // lighting
     \n#ifdef CE_ENABLE_LIGHTING\n
     Normal = normalize(NormalMatrix * VertexNormal);
     Position = MVMatrix * VertexPosition;
     
     // normal mapping
     \n#ifdef CE_ENABLE_NORMAL_MAPPING\n
     TestEyeDir = vec3(MVMatrix * VertexPosition);
     TextureCoordOut = TextureCoord;
     vec3 n = normalize(NormalMatrix * VertexNormal);
     vec3 t = normalize(NormalMatrix * VertexTangent);
     vec3 b = cross(n, t);
     vec3 v;
     v.x = dot(LightPosition, t);
     v.y = dot(LightPosition, b);
     v.z = dot(LightPosition, n);
     TestLightDir = normalize(v);
     v.x = dot(TestEyeDir, t);
     v.y = dot(TestEyeDir, b);
     v.z = dot(TestEyeDir, n);
     TestEyeDir = normalize(v);
     \n#endif\n // end of normal mapping
     
     \n#endif\n // end of lighting
     
     // texture
     \n#ifdef CE_ENABLE_TEXTURE\n
     TextureCoordOut = TextureCoord;
     \n#endif\n
     
     // shadow mapping
     \n#ifdef CE_ENABLE_SHADOW_MAPPING\n
     ShadowCoord = DepthBiasMVP * VertexPosition;
     \n#endif\n
     
     gl_Position = MVPMatrix * VertexPosition;
 }
 );


NSString *const kFragmentSahder = CE_SHADER_STRING
(
 precision mediump float;
 
 //  material
 uniform vec4 DiffuseColor;
 
 
 // texture
 \n#ifdef CE_ENABLE_TEXTURE\n
 uniform lowp sampler2D DiffuseTexture;
 varying vec2 TextureCoordOut;
 \n#endif\n
 // end of texture
 
 
 // lighting
 \n#ifdef CE_ENABLE_LIGHTING\n
 uniform vec3 SpecularColor;
 uniform vec3 AmbientColor;
 uniform float ShininessExponent;
 
 struct LightInfo {
     bool IsEnabled;
     int LightType; // 0:none 1:directional 2:point 3:spot
     vec4 LightPosition;
     vec3 LightDirection;
     vec3 LightColor;
     float Attenuation;
     float SpotConsCutoff;
     float SpotExponent;
 };
 uniform LightInfo Lights[CE_LIGHT_COUNT];
 uniform lowp vec3 EyeDirection;
 uniform int LightCount;
 varying lowp vec3 Normal;
 varying vec4 Position;
 
 // normal mapping
 \n#ifdef CE_ENABLE_NORMAL_MAPPING\n
 uniform sampler2D NormalMapTexture;
 varying vec3 TestLightDir;
 varying vec3 TestEyeDir;
 \n#endif\n // end of normal mapping
 
 // shadow mapping
\n#ifdef CE_ENABLE_SHADOW_MAPPING\n
 uniform float ShadowDarkness;
 uniform sampler2D ShadowMapTexture;
 varying vec4 ShadowCoord;
\n#endif\n
 
 vec3 ApplyLightingEffect(vec3 inputColor) {
     vec3 scatteredLight = vec3(0.0);
     vec3 reflectedLight = vec3(0.0);
     
     // loop over all light and calculate light effect
     bool hasLightEnabled = false;
     for (int i = 0; i < LightCount; i++) {
         if (!Lights[i].IsEnabled) {
             continue;
         }
         hasLightEnabled = true;
         
         lowp vec3 halfVector;
         
         \n#ifdef CE_ENABLE_NORMAL_MAPPING\n // normal mapping
         vec3 lightDirection = TestLightDir;
         vec3 eyeDirection = TestEyeDir;
         vec3 normal = texture2D(NormalMapTexture, TextureCoordOut).rgb * 2.0 - 1.0;
         \n#else\n
         vec3 lightDirection = Lights[i].LightDirection;
         vec3 eyeDirection = EyeDirection;
         vec3 normal = Normal;
         \n#endif\n // end of normal mapping
         
         float attenuation = 1.0;
         
         // for local lights, compute per-fragment direction, halfVector and attenuation
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
         float diffuse = max(0.0, dot(normal, lightDirection));
         float specular = max(0.0, dot(normal, halfVector));
         
         specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
         scatteredLight += AmbientColor * attenuation + Lights[i].LightColor * diffuse * attenuation;
         reflectedLight += SpecularColor * specular * attenuation;
     }
     
     // apply shadow mapping
    \n#ifdef CE_ENABLE_SHADOW_MAPPING\n
     float depthValue = texture2D(ShadowMapTexture, vec2(ShadowCoord.x/ShadowCoord.w, ShadowCoord.y/ShadowCoord.w)).z;
     if (depthValue != 1.0 && depthValue < (ShadowCoord.z / ShadowCoord.w) - 0.005) {
         scatteredLight *= ShadowDarkness;
         reflectedLight *= ShadowDarkness;
     }
    \n#endif\n
     
     return min(inputColor * scatteredLight + reflectedLight, vec3(1.0));
 }
 
\n#endif\n
 // end of lighting

 
 \n#ifdef CE_RENDER_TRANSPARENT_OBJECT\n // TRANSPARENT OBJECT
 uniform float Transparency;
 \n#endif\n
 
 void main() {
     //---------------------- input color ----------------------
     vec4 inputColor;
     \n#ifdef CE_ENABLE_TEXTURE\n
     inputColor = texture2D(DiffuseTexture, TextureCoordOut);
     \n#else\n
     inputColor = DiffuseColor;
     \n#endif\n
     
     \n#ifdef CE_RENDER_ALPHA_TESTED_OBJECT\n // ALPHA TESTED OBJECT
     if (inputColor.a < 0.5) discard;
     \n#endif\n
     
     //--------------------- process color ---------------------
     vec4 processedColor;
     \n#ifdef CE_ENABLE_LIGHTING\n
         vec3 lightingColor = ApplyLightingEffect(inputColor.rgb);
         processedColor = vec4(lightingColor.rgb, inputColor.a);
     \n#else\n
         processedColor = inputColor;
     \n#endif\n
     
     //--------------------- final blending ---------------------
     \n#ifdef CE_RENDER_TRANSPARENT_OBJECT\n // TRANSPARENT OBJECT
     processedColor.a = Transparency;
     \n#endif\n
     
     gl_FragColor = processedColor;
 }
);


#endif
