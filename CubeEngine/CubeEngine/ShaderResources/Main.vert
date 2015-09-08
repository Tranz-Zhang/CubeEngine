
uniform mat4 MVPMatrix;
attribute highp vec4 VertexPosition;

//*
void main () {
    #link CEVertex_ApplyBaseLightEffect();
    
    gl_Position = MVPMatrix * VertexPosition;
}
//*/

/*
uniform float colorList[3];

void main() {
    vec4 inputColor = vec4(1.0);
    #link CEVertex_TestFunction1(inputColor, colorList);
    
    #link CEVertex_TestFunction2();
    
    vec3 color = vec3(inputColor);
    #link CEVertex_TestFunction3(color);
    
    gl_Position = MVPMatrix * VertexPosition;
}
//*/