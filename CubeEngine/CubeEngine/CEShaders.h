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
 attribute highp vec3 VertexNormal;
 uniform mat4 MVMatrix;
 uniform mat3 NormalMatrix;
 varying vec3 Normal;
 
 \n#ifdef CE_ENABLE_LIGHTING\n
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
 uniform vec3 EyeDirection;
// varying vec4 Position;
 varying vec3 LightDirection;
 varying vec3 HalfVector;
 varying float Attenuation;
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
//     Position = MVMatrix * VertexPosition;
     
     // for locol lights, compute per-fragment direction, halfVector and attenuation
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
 
 //  material
 uniform vec4 DiffuseColor;
 
 // lighting
 \n#ifdef CE_ENABLE_LIGHTING\n
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
 varying vec3 Normal;
// varying vec4 Position;
 varying vec3 LightDirection;
 varying vec3 HalfVector;
 varying float Attenuation;
 
 // shadow mapping
 \n#ifdef CE_ENABLE_SHADOW_MAPPING\n
 uniform float ShadowDarkness;
 uniform sampler2D ShadowMapTexture;
 varying vec4 ShadowCoord;
 \n#endif\n
 
 vec3 ApplyLightingEffect(vec3 inputColor) {
     // calculate diffuse and specular
     float diffuse = max(0.0, dot(Normal, LightDirection));
     float specular = max(0.0, dot(Normal, HalfVector));
     
     specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
     vec3 scatteredLight = AmbientColor * Attenuation + MainLight.LightColor * diffuse * Attenuation;
     vec3 reflectedLight = SpecularColor * specular * Attenuation;
     
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
