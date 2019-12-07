precision highp float;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

varying highp vec2 textureCoordinate;
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    highp vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    highp vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    highp float d = q.x - min(q.w, q.y);
    highp float e = 1.0e-10;
    vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    return hsv;
}

vec3 ContrastSaturationBrightness(  vec3 color,   float brt,   float sat,   float con)
{
    const   float AvgLumR = 0.5;
    const   float AvgLumG = 0.5;
    const   float AvgLumB = 0.5;
    
    const   vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
    
    vec3 AvgLumin = vec3(AvgLumR, AvgLumG, AvgLumB);
    vec3 brtColor = color * brt;
    vec3 intensity = vec3(dot(brtColor, LumCoeff));
    vec3 satColor = mix(intensity, brtColor, sat);
    vec3 conColor = mix(AvgLumin, satColor, con);
    
    return conColor;
}

float skinDetection(vec3 hsv)
{
    float skinPossibility = 1.0;
    if ((0.18 <= hsv.x && hsv.x <= 0.89) || hsv.z <= 0.2)
    {
        skinPossibility = 0.0;
    }
    if (0.16 < hsv.x && hsv.x < 0.18)
    {
        skinPossibility = min(skinPossibility, (0.18 - hsv.x) / 0.02);
    }
    if (0.89 < hsv.x && hsv.x < 0.91)
    {
        skinPossibility = min(skinPossibility, 1.0 - (0.91 - hsv.x) / 0.02);
    }
    if (0.2 < hsv.z && hsv.x < 0.3)
    {
        skinPossibility = min(skinPossibility, 1.0 - (0.3 - hsv.z) / 0.1);
    }
    return skinPossibility;
}

void main()
{
    float blurOpacity = 0.48;
    float factor1 = 2.782;
    float factor2 = 1.131;
    float factor3 = 1.158;
    float factor4 = 2.901;
    float factor5 = 0.979;
    float factor6 = 0.639;
    float factor7 = 0.963;
    
    vec4 inputColor = texture2D(inputImageTexture2, textureCoordinate);
    
    vec3 hsv = rgb2hsv(inputColor.rgb);
    float skinPossibility = skinDetection(hsv);
    
    vec4 blurColor = texture2D(inputImageTexture, textureCoordinate);
    skinPossibility = blurOpacity * skinPossibility;
    
    //lighten dark color
    float cDistance = distance(vec3(0.0, 0.0, 0.0), max(blurColor.rgb - inputColor.rgb, 0.0)) * factor1;
    vec3 brightColor = ContrastSaturationBrightness(inputColor.rgb, factor2, 1.0, factor3);
    vec3 mix11Color = mix(inputColor.rgb, brightColor.rgb, cDistance);
    
    //darken light color
    float dDistance = distance(vec3(0.0, 0.0, 0.0), max(inputColor.rgb-blurColor.rgb, 0.0)) * factor4;
    vec3 darkColor = ContrastSaturationBrightness(inputColor.rgb, factor5, 1.0, factor6);
    vec3 mix115Color = mix(mix11Color.rgb, darkColor.rgb, dDistance);
    vec3 mix12Color;
    
    vec3 mix116Color = mix(inputColor.rgb, mix115Color.rgb, factor7);
    mix12Color = mix(mix116Color.rgb, blurColor.rgb, skinPossibility);
    
    float filterOpacity = 0.63687;//0.923*0.69;
    gl_FragColor = vec4(mix(inputColor.rgb, mix12Color.rgb, filterOpacity), 1.0);
}
