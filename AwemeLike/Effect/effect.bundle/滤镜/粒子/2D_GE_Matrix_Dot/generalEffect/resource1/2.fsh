precision highp float;
varying vec2        TexCoord;       // Texture coordiantes
uniform sampler2D   u_latestEffectTexture;           // FBO texture
uniform vec2        FBS;            // Frame Buffer Size

// http://developer.download.nvidia.com/assets/gamedev/files/sdk/11/FXAA_WhitePaper.pdf
// Luminance Conversion
float FxaaLuma(vec3 rgb) {
    return rgb.y * (0.587/0.299) + rgb.x;
}

void main() {
    float FXAA_SPAN_MAX     = 8.0;
    float FXAA_REDUCE_MUL   = 1.0/8.0;
    float FXAA_REDUCE_MIN   = 1.0/128.0;
    
    vec3 rgbNW  = texture2D(u_latestEffectTexture, TexCoord+(vec2(-1.0,-1.0) / FBS)).xyz;
    vec3 rgbNE  = texture2D(u_latestEffectTexture, TexCoord+(vec2(1.0,-1.0) / FBS)).xyz;
    vec3 rgbSW  = texture2D(u_latestEffectTexture, TexCoord+(vec2(-1.0,1.0) / FBS)).xyz;
    vec3 rgbSE  = texture2D(u_latestEffectTexture, TexCoord+(vec2(1.0,1.0) / FBS)).xyz;
    vec4 rgbM   = texture2D(u_latestEffectTexture, TexCoord);
    
    float lumaNW = FxaaLuma(rgbNW);
    float lumaNE = FxaaLuma(rgbNE);
    float lumaSW = FxaaLuma(rgbSW);
    float lumaSE = FxaaLuma(rgbSE);
    float lumaM  = FxaaLuma(rgbM.xyz);
    
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
    
    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    
    float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) *
                          (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
              max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
                  dir * rcpDirMin)) / FBS;
    
    vec3 rgbA = 0.5 * (texture2D(u_latestEffectTexture, TexCoord.xy + dir * (1.0 / 3.0 - 0.5)).xyz +
                       texture2D(u_latestEffectTexture, TexCoord.xy + dir * (2.0 / 3.0 - 0.5)).xyz);
    vec3 rgbB = rgbA * 0.5 + 0.25 *
    (texture2D(u_latestEffectTexture, TexCoord.xy + dir * -0.5).xyz +
     texture2D(u_latestEffectTexture, TexCoord.xy + dir * 0.5).xyz);
    
    float lumaB = FxaaLuma(rgbB);
    
    if((lumaB < lumaMin) || (lumaB > lumaMax)){
        gl_FragColor = vec4(rgbA, rgbM.a);
    }else{
        gl_FragColor = vec4(rgbB, rgbM.a);
    }
}
