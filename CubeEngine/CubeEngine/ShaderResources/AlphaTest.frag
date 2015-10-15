
void CEFrag_AlphaTest(vec4 inputColor) {
    if (inputColor.a < 0.5) discard;
}
