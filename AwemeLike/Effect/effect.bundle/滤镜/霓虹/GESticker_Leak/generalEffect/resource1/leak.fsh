precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D decorationTexture;
#define _EXECUTE_BLEND_(blendFunction, base, blend) vec4(((1.0-base.a)*blend.rgb + (1.0-blend.a)*base.rgb + blend.a*base.a*blendFunction(clamp(blend.rgb/blend.a,0.0,1.0), clamp(base.rgb/base.a,0.0,1.0), 1.0)) * (1.0 / (blend.a + (base.a * (1.0-blend.a)))), (blend.a + base.a*(1.0-blend.a)));
vec3 blendScreen(vec3  a, vec3  b, float f) { return b+a-b*a; }
vec4 blendScreen(vec4 base, vec4 blend) { return _EXECUTE_BLEND_(blendScreen, base, blend ); }

void main()
{
    vec4 color1 = texture2D(inputImageTexture,textureCoordinate);
    vec4 color2 = texture2D(decorationTexture,textureCoordinate);
    gl_FragColor =  blendScreen(color1,color2);
}