
attribute lowp vec2 TextureCoord;
varying vec2 TextureCoordOut;

void CEVertex_ApplyTexture() {
    TextureCoordOut = TextureCoord;
}
