precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D blurImageTexture;
varying vec2 textureCoordinate;
float blendScreen(float base, float blend) {
    return 1.0-((1.0-base)*(1.0-blend));
}

vec4 blendScreen(vec4 base, vec4 blend) {
    return vec4(blendScreen(base.r,blend.r),blendScreen(base.g,blend.g),blendScreen(base.b,blend.b),base.a);
}

void main(void) 
{
    vec4 centerColor = texture2D(inputImageTexture,textureCoordinate);
    vec4 blurColor = texture2D(blurImageTexture,textureCoordinate);
    float maskVal = blurColor.a*0.457;
    //blurColor = vec4(blurColor.a);
    blurColor.a =1.0;
    vec4 result = mix(centerColor,blurColor,1.0-maskVal);

    vec4 blendColor = result;
    vec4 baseColor = centerColor;
    //result = blendScreen(baseColor,blendColor);
    result = mix(blendScreen(baseColor,blendColor),result,0.25);
    result = mix(result,centerColor,0.4);

    gl_FragColor = result;
    //gl_FragColor.a = centerColor.a;
    //gl_FragColor = blurColor;
}
