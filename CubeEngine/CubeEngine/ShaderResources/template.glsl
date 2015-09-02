// structs
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

// attributes
highp vec4 VertexPosition;
highp vec4 test2_value1;
lowp vec3 test1_value1;

// uniforms
mediump mat4 MVPMatrix;
mediump LightInfo mainLight;
highp vec4 test3_value1;
mediump mat3 test_common;
lowp mat3 test2_value2;
lowp mat3 test1_value2;

// varyings
lowp vec3 LightDirection;
lowp vec3 EyeDirectionOut;
lowp float Attenuation;
lowp vec3 Normal;

void main() {
    vec4 inputColor;
    //Link: CEVertex_TestFunction1(vec4)
    {
        // one of these methods should be executed
        vec3 inputColor_test2 = vec3(inputColor);
        //Link: CEVertex_TestFunction3(vec3)
        {
            // start coding for test2
            vec3 myColor = inputColor_test2;
            myColor = nil;....
            MyinputColor);
            (inputColor_test2);
            inputColor_test2+1 = 2;
            XXXXXXXXXXXXXXXXXXXXXXX
            AAAAAAAAAAAAAAAAAAAAAAA
        }
        
        some code here for test 1;
        
        //removed-link CEFrag_ApplyShadowEffect();
    }
    
    //Link: CEVertex_TestFunction2(vec4)
    {
        // start coding for test2
        vec3 myColor = vec3(1.0);
        myColor = nil;....
        adsfjadsfopasdf
        asdfjoasdfj
        some code here for test 2;
    }
    
    vec3 inputColorXX = vec3(inputColor);
    //Link: CEVertex_TestFunction3(vec3)
    {
        // start coding for test2
        vec3 myColor = inputColorXX;
        myColor = nil;....
        MyinputColor);
        (inputColorXX);
        inputColorXX+1 = 2;
        XXXXXXXXXXXXXXXXXXXXXXX
        AAAAAAAAAAAAAAAAAAAAAAA
    }
    
    gl_Position = MVPMatrix * VertexPosition;
}
