//
//  CEShader_test.h
//  CubeEngine
//
//  Created by chance on 7/8/15.
//  Copyright (c) 2015 ByChance. All rights reserved.
//

#ifndef CubeEngine_CEShader_test_h
#define CubeEngine_CEShader_test_h


NSString *const kVertexShader_test = CE_SHADER_STRING
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
 
 uniform vec3 LIGHTDIRECTIONINPUT;
 varying lowp vec3 HALFVECTOR;
 varying lowp vec3 LIGHTDIRECTION;
 
 \n#endif\n // end of lighting
 
 void main () {
     // lighting
     \n#ifdef CE_ENABLE_LIGHTING\n
     Normal = normalize(NormalMatrix * VertexNormal);
     Position = MVMatrix * VertexPosition;
     
     LIGHTDIRECTION = LIGHTDIRECTIONINPUT;
     HALFVECTOR = normalize(LIGHTDIRECTIONINPUT + vec3(0.0, 0.0, 1.0));
     
     \n#endif\n // end of lighting
     
     gl_Position = MVPMatrix * VertexPosition;
 }
 );


NSString *const kFragmentSahder_test = CE_SHADER_STRING
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
 
 varying lowp vec3 HALFVECTOR;
 varying lowp vec3 LIGHTDIRECTION;
 
 vec3 ApplyLightingEffect(vec3 inputColor) {
     vec3 scatteredLight = vec3(0.0);
     vec3 reflectedLight = vec3(0.0);
     
     // loop over all light and calculate light effect
     for (int i = 0; i < LightCount; i++) {
         if (!Lights[i].IsEnabled) {
             continue;
         }
         
         vec3 lightDirection = Lights[i].LightDirection;//LIGHTDIRECTION;
         vec3 eyeDirection = EyeDirection;
         vec3 normal = Normal;
         float attenuation = 1.0;
         
         vec3 halfVector = normalize(lightDirection + eyeDirection); //HALFVECTOR;
         
         // calculate diffuse and specular
         float diffuse = max(0.0, dot(normal, lightDirection));
         float specular = max(0.0, dot(normal, halfVector));
         
         specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
         scatteredLight += AmbientColor * attenuation + Lights[i].LightColor * diffuse * attenuation;
         reflectedLight += SpecularColor * specular * attenuation;
     }
     
     return min(inputColor * scatteredLight + reflectedLight, vec3(1.0));
 }
 
 \n#endif\n
 // end of lighting

 
 void main() {
     //---------------------- input color ----------------------
     vec4 inputColor = DiffuseColor;
     
     //--------------------- process color ---------------------
     vec4 processedColor;
     \n#ifdef CE_ENABLE_LIGHTING\n
     vec3 lightingColor = ApplyLightingEffect(inputColor.rgb);
     processedColor = vec4(lightingColor.rgb, inputColor.a);
     \n#else\n
         processedColor = inputColor;
     \n#endif\n
     
     gl_FragColor = processedColor;
 }
 );


#endif
