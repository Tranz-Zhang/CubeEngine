
// basic info
uniform mat4 MVPMatrix;
attribute highp vec4 VertexPosition;

#ifdef CE_ENABLE_LIGHTING //                                                    >> lighting
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

// common properties from classic ligting and normal mapping
attribute lowp vec3 VertexNormal;
uniform lowp mat3 NormalMatrix;
uniform lowp mat4 MVMatrix;
uniform lowp vec3 EyeDirection; // in eye space
varying lowp vec3 LightDirection;
varying lowp vec3 EyeDirectionOut;
varying lowp float Attenuation;

// properties different from classic lighting and normal mapping
#ifdef CE_ENABLE_NORMAL_MAPPING //                                              >> normal mapping
attribute lowp vec3 VertexTangent;
#else //                                                                        >> classic lighting
varying lowp vec3 Normal;
#endif //                                                                       << normal mapping & classic lighting

// shadow mapping
#ifdef CE_ENABLE_SHADOW_MAPPING //                                              >> shadow mapping
uniform mat4 DepthBiasMVP;
varying vec4 ShadowCoord;
#endif //                                                                       << shadow mapping

#endif //                                                                       << lighting

// texture
#if defined(CE_ENABLE_TEXTURE) || defined(CE_ENABLE_NORMAL_MAPPING) //          >> texture
attribute lowp vec2 TextureCoord;
varying vec2 TextureCoordOut;
#endif //                                                                       << texture

void main () {
    // lighting
#ifdef CE_ENABLE_LIGHTING //                                                    >> lighting
    // for locol lights, compute per fragment direction, halfVector and attenuation
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
        
    } else { // directional light
        LightDirection = MainLight.LightDirection;
        Attenuation = 1.0;
    }
    
#ifdef CE_ENABLE_NORMAL_MAPPING //                                              >> normal mapping
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
    
#else //                                                                        >> classic lighting
    EyeDirectionOut = EyeDirection;
    Normal = normalize(NormalMatrix * VertexNormal);
#endif //                                                                       << normal mapping & classic lighting
    
    // shadow mapping
#ifdef CE_ENABLE_SHADOW_MAPPING //                                              >> shadow mapping
    ShadowCoord = DepthBiasMVP * VertexPosition;
#endif //                                                                       << shadow mapping
    
#endif //                                                                       << lighting
    
    // texture
#if defined(CE_ENABLE_TEXTURE) || defined(CE_ENABLE_NORMAL_MAPPING) //          >> texture
    TextureCoordOut = TextureCoord;
#endif //                                                                       << texture
    
    gl_Position = MVPMatrix * VertexPosition;
}


