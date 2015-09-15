
precision mediump float;

uniform mediump vec4 DiffuseColor;

void main() {
    vec4 inputColor = DiffuseColor;
    #link CEFrag_ApplyTexture(inputColor);
    #link CEFrag_ApplyBaseLightEffect(inputColor);
    
    gl_FragColor = inputColor;
}

