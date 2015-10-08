
attribute lowp vec2 VertexUV;
varying vec2 TextureCoordOut;

void CEVertex_ApplyTexture() {
    TextureCoordOut = VertexUV;
}
