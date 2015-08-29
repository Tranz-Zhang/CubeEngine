
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

attribute highp vec4 test2_value1;
uniform lowp mat3 test2_value2;
uniform mediump mat3 test_common;

void CEVertex_TestFunction2(vec4 inputColor) {
    // start coding for test2
    vec3 myColor = vec3(1.0);
    myColor = nil;....
    adsfjadsfopasdf
    asdfjoasdfj
    some code here for test 2;
}
