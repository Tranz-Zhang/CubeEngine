

attribute lowp vec3 test1_value1;
uniform lowp mat3 test1_value2;
uniform mediump mat3 test_common;

varying lowp vec3 LightDirection;
varying lowp vec3 EyeDirectionOut;
varying lowp float Attenuation;
varying lowp vec3 Normal;

void CEVertex_TestFunction1(vec4 inputColor) {
    // one of these methods should be executed
    vec3 inputColor_test2 = vec3(inputColor);
    #link CEVertex_TestFunction3(inputColor_test2);
    
    some code here for test 1;
    
#link CEFrag_ApplyShadowEffect();
}


