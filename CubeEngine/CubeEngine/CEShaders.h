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
  attribute highp vec3 VertexNormal;
 uniform mat4 MVMatrix;
 uniform mat3 NormalMatrix;
 varying vec3 Normal;
 varying vec4 Position;
 \n#endif\n
 
 // shadow mapping
 \n#ifdef CE_ENABLE_SHADOW_MAPPING\n
 uniform mat4 DepthBiasMVP;
 varying vec4 ShadowCoord;
 \n#endif\n
 
 // texture
 \n#ifdef CE_ENABLE_TEXTURE\n
 attribute highp vec2 TextureCoord;
 varying vec2 TextureCoordOut;
 \n#endif\n
 
 void main () {
     // lighting
     \n#ifdef CE_ENABLE_LIGHTING\n
     Normal = normalize(NormalMatrix * VertexNormal);
     Position = MVMatrix * VertexPosition;
     \n#endif\n
     
     // shadow mapping
     \n#ifdef CE_ENABLE_SHADOW_MAPPING\n
     ShadowCoord = DepthBiasMVP * VertexPosition;
     \n#endif\n
     
     // texture
     \n#ifdef CE_ENABLE_TEXTURE\n
     TextureCoordOut = TextureCoord;
     \n#endif\n
     
     gl_Position = MVPMatrix * VertexPosition;
 }
 );


NSString *const kFragmentSahder = CE_SHADER_STRING
(
 precision mediump float;
 
 //  basic info
 uniform vec4 BaseColor;
 
 // lighting
 \n#ifdef CE_ENABLE_LIGHTING\n
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
 uniform LightInfo Lights[CE_LIGHT_COUNT];
 uniform vec3 EyeDirection;
 uniform int LightCount;
 varying vec3 Normal;
 varying vec4 Position;
 
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
 
 
// texture
\n#ifdef CE_ENABLE_TEXTURE\n
 uniform lowp sampler2D DiffuseTexture;
 varying vec2 TextureCoordOut;
\n#endif\n
// end of texture
 
 \n#ifdef CE_RENDER_TRANSPARENT_OBJECT\n // TRANSPARENT OBJECT
 uniform float Transparency;
 \n#endif\n
 
 void main() {
     //---------------------- input color ----------------------
     vec4 inputColor;
     \n#ifdef CE_ENABLE_TEXTURE\n
     inputColor = texture2D(DiffuseTexture, TextureCoordOut);
     \n#else\n
     inputColor = BaseColor;
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
