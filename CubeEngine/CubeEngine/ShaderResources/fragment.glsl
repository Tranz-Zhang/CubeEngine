precision mediump float;

//  material
uniform vec4 DiffuseColor;

// texture
#ifdef CE_ENABLE_TEXTURE //                                                     >> texture
uniform lowp sampler2D DiffuseTexture;
#endif //
#if defined(CE_ENABLE_TEXTURE) || defined(CE_ENABLE_NORMAL_MAPPING)
varying vec2 TextureCoordOut;
#endif //                                                                       << texture

// lighting
#ifdef CE_ENABLE_LIGHTING //                                                    >> lighting
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

#ifdef CE_ENABLE_NORMAL_MAPPING //                                              >> normal mapping
uniform sampler2D NormalMapTexture;
#else //                                                                        >> classic lighting
varying lowp vec3 Normal;
#endif //                                                                       << normal mapping & classic lighting


// shadow mapping
#ifdef CE_ENABLE_SHADOW_MAPPING //                                              >> shadow mapping
uniform float ShadowDarkness;
uniform sampler2D ShadowMapTexture;
varying vec4 ShadowCoord;
#endif //                                                                       << shadow mapping

vec3 ApplyLightingEffect(vec3 inputColor) {
    lowp vec3 normal;
#ifdef CE_ENABLE_NORMAL_MAPPING //                                              >> normal mapping
    normal = texture2D(NormalMapTexture, TextureCoordOut).rgb * 2.0 - 1.0;
    normal = normalize(normal);
#else //                                                                        >> classic lighting
    normal = Normal;
#endif //                                                                       << normal mapping & classic lighting
    
    lowp vec3 reflectDir = normalize(-reflect(LightDirection, normal));
    float diffuse = max(0.0, dot(normal, LightDirection));
    float specular = max(0.0, dot(reflectDir, EyeDirectionOut));
    specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
    vec3 scatteredLight = AmbientColor * Attenuation + MainLight.LightColor * diffuse * Attenuation;
    vec3 reflectedLight = SpecularColor * specular * Attenuation;
    
    // apply shadow mapping
#ifdef CE_ENABLE_SHADOW_MAPPING //                                              >> shadow mapping
    float depthValue = texture2D(ShadowMapTexture, vec2(ShadowCoord.x/ShadowCoord.w, ShadowCoord.y/ShadowCoord.w)).z;
    if (depthValue != 1.0 && depthValue < (ShadowCoord.z / ShadowCoord.w) - 0.005) {
        scatteredLight *= ShadowDarkness;
        reflectedLight *= ShadowDarkness;
    }
#endif //                                                                       << shadow mapping
    
    return min(inputColor * scatteredLight + reflectedLight, vec3(1.0));
}

#endif //                                                                       << lighting

#ifdef CE_RENDER_TRANSPARENT_OBJECT //                                          >> transparent
uniform float Transparency;
#endif //                                                                       << transparent

void main() {
    // input color
    vec4 inputColor;
#ifdef CE_ENABLE_TEXTURE //                                                     >> texture
    inputColor = texture2D(DiffuseTexture, TextureCoordOut);
#else
    inputColor = DiffuseColor;
#endif //                                                                       << texture
    
#ifdef CE_RENDER_ALPHA_TESTED_OBJECT //                                         >> alpha test
    if (inputColor.a < 0.5) discard;
#endif //                                                                       << alpha test
    
    // process color
    vec4 processedColor;
#ifdef CE_ENABLE_LIGHTING //                                                    << lighting
    vec3 lightingColor = ApplyLightingEffect(inputColor.rgb);
    processedColor = vec4(lightingColor.rgb, inputColor.a);
#else
    processedColor = inputColor;
#endif //                                                                       >> lighting
    
    // final blending
#ifdef CE_RENDER_TRANSPARENT_OBJECT //                                          >> transparent
    processedColor.a = Transparency;
#endif //                                                                       << transparent
    
    gl_FragColor = processedColor;
}


