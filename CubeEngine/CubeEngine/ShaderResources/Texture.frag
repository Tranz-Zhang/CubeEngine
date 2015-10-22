
uniform lowp sampler2D DiffuseTexture;
varying vec2 TextureCoordOut;

void ApplyTexture(vec4 inputColor) {
    inputColor = texture2D(DiffuseTexture, TextureCoordOut);
}

