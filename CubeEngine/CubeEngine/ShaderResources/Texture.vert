
attribute lowp vec2 VertexUV;
varying vec2 TextureCoordOut;

void ApplyTexture() {
    TextureCoordOut = VertexUV;
}
