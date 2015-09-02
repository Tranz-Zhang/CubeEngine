// ================ vertexShader ================
struct LightInfo {
    bool IsEnabled;
    lowp int LightType;
    mediump vec4 LightPosition;
    lowp vec3 LightDirection;
    mediump vec3 LightColor;
    mediump float Attenuation;
    mediump float SpotConsCutoff;
    mediump float SpotExponent;
};

attribute highp vec4 VertexPosition;
attribute lowp vec3 VertexNormal;

uniform mediump mat4 MVPMatrix;
uniform lowp mat3 NormalMatrix;
uniform lowp vec3 EyeDirection;
uniform LightInfo MainLight;
uniform lowp mat4 MVMatrix;

varying lowp vec3 LightDirection;
varying lowp vec3 EyeDirectionOut;
varying lowp float Attenuation;
varying lowp vec3 Normal;

void main() {
    //#link CEVertex_ApplyBaseLightEffect();
    {
        //#link CEVertex_PointLightCalculation(LightDirection, Attenuation);
        {
            LightDirection = vec3(MainLight.LightPosition) - vec3(MVMatrix * VertexPosition);
            float lightDistance = length(LightDirection);
            LightDirection = LightDirection / lightDistance;
            Attenuation = 1.0 / (1.0 + MainLight.Attenuation * lightDistance + MainLight.Attenuation * lightDistance * lightDistance);
        }
        EyeDirectionOut = EyeDirection;
        Normal = normalize(NormalMatrix * VertexNormal);
    }
    gl_Position = MVPMatrix * VertexPosition;
}



// ================ fragmentShader ================
struct LightInfo {
    bool IsEnabled;
    lowp int LightType;
    mediump vec4 LightPosition;
    lowp vec3 LightDirection;
    mediump vec3 LightColor;
    mediump float Attenuation;
    mediump float SpotConsCutoff;
    mediump float SpotExponent;
};

uniform mediump vec4 DiffuseColor;
uniform mediump vec3 SpecularColor;
uniform mediump vec3 AmbientColor;
uniform mediump float ShininessExponent;
uniform LightInfo MainLight;

varying lowp vec3 LightDirection;
varying lowp vec3 EyeDirectionOut;
varying lowp float Attenuation;
varying lowp vec3 Normal;

void main() {
    vec4 inputColor = DiffuseColor;
    //#link CEFrag_ApplyBaseLightEffect(inputColor);
    {
        lowp vec3 reflectDir = normalize(-reflect(LightDirection, normal));
        float diffuse = max(0.0, dot(Normal, LightDirection));
        float specular = max(0.0, dot(reflectDir, EyeDirectionOut));
        specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);
        vec3 scatteredLight [3] = AmbientColor * Attenuation + MainLight.LightColor * diffuse * Attenuation;
        vec3 reflectedLight = SpecularColor * specular * Attenuation;
        inputColor = min(inputColor * scatteredLight + reflectedLight, vec4(1.0));
    }
    gl_FragColor = inputColor;
}