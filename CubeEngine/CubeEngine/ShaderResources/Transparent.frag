
uniform float Transparency;

void ApplyTransparent(vec4 inputColor) {
    inputColor.a = Transparency;
}
