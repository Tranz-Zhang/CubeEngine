
struct LightInfo {
    bool IsEnabled;
    lowp int LightType; // 0:none 1:directional 2:point 3:spot
    mediump vec4 LightPosition;  // in eye space
    lowp vec3 LightDirection; // in eye space
    mediump vec3 LightColor;
    mediump float Attenuation;
    mediump float SpotConsCutoff;
    mediump float SpotExponent;
};
uniform LightInfo MainLight;

void DirectionLightCalculation(vec3 LightDirection, float Attenuation) {
    LightDirection = MainLight.LightDirection;
    Attenuation = 1.0;
}

