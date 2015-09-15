
uniform float ShadowDarkness;
uniform sampler2D ShadowMapTexture;
varying highp vec4 ShadowCoord;

void CEFrag_ApplyShadowMap(vec3 scatteredLight, vec3 reflectedLight) {
    float depthValue = texture2D(ShadowMapTexture, vec2(ShadowCoord.x/ShadowCoord.w, ShadowCoord.y/ShadowCoord.w)).z;
    if (depthValue != 1.0 && depthValue < (ShadowCoord.z / ShadowCoord.w) - 0.005) {
        scatteredLight *= ShadowDarkness;
        reflectedLight *= ShadowDarkness;
    }
}
