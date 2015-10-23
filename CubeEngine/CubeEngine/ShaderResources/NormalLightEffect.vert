
attribute lowp vec3 VertexNormal;
attribute lowp vec3 VertexTangent;
attribute lowp vec2 VertexUV;

uniform highp mat3 NormalMatrix;
uniform lowp vec3 EyeDirection; // in eye space

varying lowp vec3 LightDirection;
varying lowp vec3 EyeDirectionOut;
varying lowp float Attenuation;
varying vec2 TextureCoordOut;

void NormalLightEffect() {
    // one of these methods should be executed
#link DirectionLightCalculation(LightDirection, Attenuation);
#link PointLightCalculation(LightDirection, Attenuation);
#link SpotLightCalculation(LightDirection, Attenuation);
    
    vec3 n = NormalMatrix * VertexNormal;
    vec3 t = NormalMatrix * VertexTangent;
    vec3 b = cross(n, t);
    mediump vec3 tempVec;
    
    tempVec.x = dot(LightDirection, t);
    tempVec.y = dot(LightDirection, b);
    tempVec.z = dot(LightDirection, n);
    LightDirection = normalize(tempVec);
    
    tempVec.x = dot(EyeDirection, t);
    tempVec.y = dot(EyeDirection, b);
    tempVec.z = dot(EyeDirection, n);
    EyeDirectionOut = normalize(tempVec);
    
    TextureCoordOut = VertexUV;
#link ApplyShadowMap();
}
