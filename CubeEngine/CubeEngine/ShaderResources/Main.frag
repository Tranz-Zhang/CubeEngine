
precision mediump float;

uniform mediump vec4 DiffuseColor;

void main() {
    vec4 inputColor = DiffuseColor;
#link ApplyTexture(inputColor);
#link AlphaTest(inputColor);
#link BaseLightEffect(inputColor);
#link NormalLightEffect(inputColor);
#link ApplyTransparent(inputColor);
    
    gl_FragColor = inputColor;
}

