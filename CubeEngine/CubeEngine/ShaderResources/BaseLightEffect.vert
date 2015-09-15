
attribute lowp vec3 VertexNormal;
uniform lowp mat3 NormalMatrix;
uniform lowp vec3 EyeDirection; // in eye space

varying lowp vec3 LightDirection;
varying lowp vec3 EyeDirectionOut;
varying lowp float Attenuation;
varying lowp vec3 Normal;

void CEVertex_ApplyBaseLightEffect() {
    // one of these methods should be executed
    #link CEVertex_DirectionLightCalculation(LightDirection, Attenuation);
    #link CEVertex_PointLightCalculation(LightDirection, Attenuation);
    #link CEVertex_SpotLightCalculation(LightDirection, Attenuation);
    
    EyeDirectionOut = EyeDirection;
    Normal = normalize(NormalMatrix * VertexNormal);

    #link CEVertex_ApplyShadowMapp();
}

