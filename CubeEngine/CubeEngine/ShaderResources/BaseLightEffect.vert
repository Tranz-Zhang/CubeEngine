
attribute lowp vec3 VertexNormal;
uniform lowp mat3 NormalMatrix;
uniform lowp vec3 EyeDirection; // in eye space

varying lowp vec3 Normal;
varying lowp vec3 LightDirection;
varying lowp vec3 EyeDirectionOut;
varying lowp float Attenuation;

void BaseLightEffect() {
    // one of these methods should be executed
    #link DirectionLightCalculation(LightDirection, Attenuation);
    #link PointLightCalculation(LightDirection, Attenuation);
    #link SpotLightCalculation(LightDirection, Attenuation);
    
    EyeDirectionOut = EyeDirection;
    Normal = normalize(NormalMatrix * VertexNormal);
    
    #link CEVertex_ApplyShadowMap();
}

