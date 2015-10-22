
attribute highp vec4 VertexPosition;
uniform highp mat4 DepthBiasMVP;
varying highp vec4 ShadowCoord;

void ApplyShadowMap() {
    ShadowCoord = DepthBiasMVP * VertexPosition;
}
