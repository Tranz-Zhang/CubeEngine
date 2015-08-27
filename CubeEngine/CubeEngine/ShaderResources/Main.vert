
uniform mat4 MVPMatrix;
attribute highp vec4 VertexPosition;

void main () {
    vec4 inputColor;
    #link CEVertex_TestFunction1(inputColor);
    
    #link CEVertex_TestFunction2(inputColor);
    
    vec3 inputColorXX = vec3(inputColor);
    #link CEVertex_TestFunction3(inputColorXX);
    
    gl_Position = MVPMatrix * VertexPosition;
}
