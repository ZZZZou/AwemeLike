precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
const float alphaFactor = 1.0;

float blendOverlay(float base, float blend) {
    return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
}

vec3 blendOverlay(vec3 base, vec3 blend) {
    return vec3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
}

vec3 blendFunc(vec3 base, vec3 blend, float opacity) {
    return (blendOverlay(base, blend) * opacity + base * (1.0 - opacity));
}

void main()
{
    vec4 fgColor = texture2D(inputImageTexture2, textureCoordinate);
    vec4 bgColor = texture2D(inputImageTexture, textureCoordinate);
    
    if (fgColor.a == 0.0) {
        gl_FragColor = bgColor;
    } else {
        vec3 color = blendOverlay(bgColor.rgb, fgColor.rgb);
        gl_FragColor = vec4(color, 1.0);
    }
}
