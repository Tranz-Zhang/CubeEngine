
uniform vec3 SpecularColor;
uniform vec3 AmbientColor;
uniform float ShininessExponent;

struct LightInfo {
    bool IsEnabled;
    lowp int LightType; // 0:none 1:directional 2:point 3:spot
    mediump vec4 LightPosition;  // in eys space
    lowp vec3 LightDirection; // in eye space
    mediump vec3 LightColor;
    mediump float Attenuation;
    mediump float SpotConsCutoff;
    mediump float SpotExponent;
};
uniform LightInfo MainLight;

varying lowp vec3 LightDirection;
varying lowp vec3 EyeDirectionOut;
varying lowp float Attenuation;
varying lowp vec3 Normal;

void CEFrag_ApplyBaseLightEffect(vec4 inputColor) {
    lowp vec3 reflectDir = normalize(-reflect(LightDirection, normal));
    float diffuse = max(0.0, dot(normal, LightDirection));
    float specular = max(0.0, dot(reflectDir, EyeDirectionOut));
    specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
    vec3 scatteredLight = AmbientColor * Attenuation + MainLight.LightColor * diffuse * Attenuation;
    vec3 reflectedLight = SpecularColor * specular * Attenuation;
    
#link CEFrag_ApplyShadowEffect(scatteredLight, reflectedLight);
    
    inputColor = min(inputColor * scatteredLight + reflectedLight, vec4(1.0));
}

