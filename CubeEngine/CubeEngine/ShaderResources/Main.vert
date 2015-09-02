
uniform mat4 MVPMatrix;
attribute highp vec4 VertexPosition;

void main () {
    #link CEVertex_ApplyBaseLightEffect();
    
    gl_Position = MVPMatrix * VertexPosition;
}
